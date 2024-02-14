local boolValues = {
	f = false
}

console.Parser("Bool", function(ply, args, last, options)
	local val = table.remove(args, 1)
	local bool = boolValues[val]

	if bool == nil then
		bool = tobool(val)
	end

	return true, bool
end)

console.Parser("String", function(ply, args, last, options)
	return true, last and table.concat(args, " ") or table.remove(args, 1)
end)

console.Parser("Number", function(ply, args, last, options)
	local num = tonumber(table.remove(args, 1))

	if num == nil then
		return false, "Invalid number"
	end

	return true, num
end)

console.Parser("Time", function(ply, args, last, options)
	local duration = duration.Parse(table.remove(args, 1), options.Format)

	if duration == nil then
		return false, "Invalid duration"
	end

	return true, duration
end)

console.Parser("Language", function(ply, args, last, options)
	local lang = table.remove(args, 1):lower()

	if not Language.Get(lang) then
		return false, "Invalid language"
	end

	return true, lang
end)
