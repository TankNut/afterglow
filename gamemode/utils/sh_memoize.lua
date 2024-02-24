local resultValue = {}
local weakMeta = {__mode = "k"}


local function createUnpack(...)
	local args = {...}
	local res = {"local t = ... return "}

	for i = 1, #args do
		res[2 + (i-1) * 4] = "t["
		res[3 + (i-1) * 4] = i
		res[4 + (i-1) * 4] = "]"

		if i != #args then
			res[5 + (i-1) * 4] = ","
		end
	end

	local func = CompileString(table.concat(res))

	return function()
		return func(args)
	end
end


function Memoize(func)
	return setmetatable({
		Cache = setmetatable({}, weakMeta),
		Clear = function(self) table.Empty(self.Cache) end,
		Count = 0
	}, {
		__call = function(self, ...)
			local args = {...}
			local node = self.Cache

			for i = 1, #args do
				local key = args[i]

				if not node[key] then
					node[key] = setmetatable({}, weakMeta)
				end

				node = node[key]
			end

			if not node[resultValue] then
				self.Count = self.Count + 1

				node[resultValue] = createUnpack(func(...))
			end

			return node[resultValue]()
		end
	})
end
