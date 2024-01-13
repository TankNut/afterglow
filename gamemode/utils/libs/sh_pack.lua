module("pack", package.seeall)

Precision = 3

PointerTypes = {
	[TYPE_TABLE] = true,
	[TYPE_STRING] = true
}

EncodeTypes = {
	[TYPE_NIL] = function() return "?" end,
	[TYPE_BOOL] = function(val)
		return val and "t" or "f"
	end,
	[TYPE_TABLE] = function(tab)
		if IsColor(tab) then
			return EncodeTypes[TYPE_COLOR](tab)
		end

		local ret = "{"

		local cache = {}
		local cacheindex = 1

		local expected = 1
		local broken = false

		local function HandleCache(val)
			local encoded = Encode(val)

			if PointerTypes[TypeID(val)] then
				local cached = cache[encoded]

				if cached then
					encoded = "(" .. cached .. ";"
				else
					cache[encoded] = cacheindex
					cacheindex = cacheindex + 1
				end
			end

			return encoded
		end

		for k, v in pairs(tab) do
			if not broken then
				if k == expected then
					expected = expected + 1

					ret = ret .. HandleCache(v)
				else
					broken = true

					ret = ret .. "$"
					ret = ret .. HandleCache(k) .. HandleCache(v)
				end
			else
				ret = ret .. HandleCache(k) .. HandleCache(v)
			end
		end

		return ret .. "}"
	end,
	[TYPE_STRING] = function(str)
		local escaped, count = string.gsub(str, ";", "\\;")

		if count == 0 then
			return "'" .. escaped
		else
			return "\"" .. escaped .. "\""
		end
	end,
	[TYPE_COLOR] = function(col)
		return string.format("c%i,%i,%i,%i", col.r, col.g, col.b, col.a)
	end,
	[TYPE_VECTOR] = function(vec)
		return string.format("v%s,%s,%s", math.Round(vec.x, Precision), math.Round(vec.y, Precision), math.Round(vec.z, Precision))
	end,
	[TYPE_ANGLE] = function(ang)
		return string.format("a%s,%s,%s", math.Round(ang.p % 360, Precision), math.Round(ang.y % 360, Precision), math.Round(ang.r % 360, Precision))
	end,
	[TYPE_NUMBER] = function(num)
		if num == 0 then
			return "0"
		elseif num % 1 != 0 then
			return "n" .. num
		else
			return string.format("%s%x", num > 0 and "+" or "-", math.abs(num))
		end
	end,
	[TYPE_ENTITY] = function(ent)
		return string.format("e%s", IsValid(ent) and ent:EntIndex() or "#")
	end
}

DecodeTypes = {
	["?"] = function() return 1, nil end, -- Nil
	["t"] = function() return 1, true end, -- True
	["f"] = function() return 1, false end, -- False
	["("] = function(str, cache) -- Table pointer
		local finish = string.find(str, ";")

		return finish, cache[tonumber(string.sub(str, 1, finish - 1))]
	end,
	["{"] = function(str) -- Table
		local strindex = 1
		local ret = {}

		local cache = {}

		local tabindex = 1
		local broken = false

		local function HandleCache(val) -- Builds the cache that pointers refer back to
			local index, decoded = Decode_raw(val, cache)

			if PointerTypes[TypeID(decoded)] then
				table.insert(cache, decoded)
			end

			return index, decoded
		end

		while true do
			local char = string.sub(str, strindex, strindex)

			if char == "}" then
				break
			end

			if char == "$" then
				broken = true
				strindex = strindex + 1

				continue
			end

			if broken then
				local keyindex, key = HandleCache(string.sub(str, strindex))
				local valindex, val = HandleCache(string.sub(str, strindex + keyindex + 1))

				ret[key] = val

				strindex = strindex + keyindex + valindex + 2
			else
				local index, val = HandleCache(string.sub(str, strindex))

				ret[tabindex] = val

				tabindex = tabindex + 1
				strindex = strindex + index + 1
			end
		end

		return strindex + 1, ret
	end,
	["'"] = function(str) -- Unescaped string
		local finish = string.find(str, ";")

		return finish, string.sub(str, 1, finish - 1)
	end,
	["\""] = function(str) -- Escaped string
		local finish = string.find(str, "\";")

		return finish + 1, string.gsub(string.sub(str, 1, finish - 1), "\\;", ";")
	end,
	["c"] = function(str) -- Color
		local finish = string.find(str, ";")
		local args = string.Explode(",", string.sub(str, 1, finish - 1))

		return finish, Color(args[1], args[2], args[3], args[4])
	end,
	["v"] = function(str) -- Vector
		local finish = string.find(str, ";")
		local args = string.Explode(",", string.sub(str, 1, finish - 1))

		return finish, Vector(args[1], args[2], args[3])
	end,
	["a"] = function(str) -- Angle
		local finish = string.find(str, ";")
		local args = string.Explode(",", string.sub(str, 1, finish - 1))

		return finish, Angle(args[1], args[2], args[3])
	end,
	["0"] = function(str) -- 0
		return 1, 0
	end,
	["+"] = function(str) -- Positive int
		local finish = string.find(str, ";")

		return finish, tonumber(string.sub(str, 1, finish - 1), 16)
	end,
	["-"] = function(str) -- Negative int
		local finish = string.find(str, ";")

		return finish, -tonumber(string.sub(str, 1, finish - 1), 16)
	end,
	["n"] = function(str) -- Float
		local finish = string.find(str, ";")

		return finish, tonumber(string.sub(str, 1, finish - 1))
	end,
	["e"] = function(str) -- Entity
		if str[1] == "#" then
			return 2, NULL
		end

		local finish = string.find(str, ";")

		return finish, Entity(string.sub(str, 1, finish - 1))
	end
}

function Encode(data)
	local callback = EncodeTypes[TypeID(data)]

	if not callback then
		callback = EncodeTypes[TYPE_NIL]
	end

	return callback(data) .. ";"
end

function Decode_raw(str, cache)
	local identifier = string.sub(str, 1, 1)
	local callback = DecodeTypes[identifier]

	if not callback then
		error("No decode type for " .. identifier)
	end

	return callback(string.sub(str, 2), cache)
end

function Decode(str)
	if not isstring(str) or #str == 0 then
		return
	end

	local _, res = Decode_raw(str)

	return res
end

Default = Encode({})
