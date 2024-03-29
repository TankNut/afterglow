local boolValues = {
	f = false
}

Console.Parser("Bool", function(ply, args, last, options)
	local val = table.remove(args, 1)
	local bool = boolValues[val]

	if bool == nil then
		bool = tobool(val)
	end

	return true, bool
end)

Console.Parser("String", function(ply, args, last, options)
	return true, last and table.concat(args, " ") or table.remove(args, 1)
end)

Console.Parser("Number", function(ply, args, last, options)
	local num = tonumber(table.remove(args, 1))

	if num == nil then
		return false, "Not a number."
	end

	return true, num
end)

Console.Parser("Time", function(ply, args, last, options)
	local duration = Duration.Parse(table.remove(args, 1), options.Format)

	if duration == nil then
		return false, "Invalid duration."
	end

	return true, duration
end)

Console.Parser("Player", function(ply, args, last, options)
	local match = last and table.concat(args, " ") or table.remove(args, 1)

	return Command.FindPlayer(ply, match, options)
end)

Console.Parser("Language", function(ply, args, last, options)
	local lang = table.remove(args, 1):lower()

	if not Language.Get(lang) then
		return false, "Invalid language."
	end

	return true, lang
end)

Console.Parser("Badge", function(ply, args, last, options)
	local badge = table.remove(args, 1):lower()
	local data = Badge.Get(badge)

	if not data then
		return false, "Invalid badge."
	end

	if options.CustomOnly and data.Automated then
		return false, "You cannot select this badge."
	end

	return true, badge
end)

Console.Parser("UserGroup", function(ply, args, last, options)
	local group = table.remove(args, 1):lower()

	if not Admin.Ranks[group] then
		return false, "Invalid usergroup."
	end

	if IsValid(ply) then
		if options.CheckImmunity and not ply:CheckUserGroup(group) then
			return false, "You cannot select this usergroup."
		end

		if options.NoSelfSelect and group == ply:GetUserGroup() then
			return false, "You cannot select your own usergroup."
		end
	end

	return true, group
end)

Console.Parser("CharacterFlag", function(ply, args, last, options)
	local flag = table.remove(args, 1):lower()

	if not CharacterFlag.Get(flag) then
		return false, "Invalid flag."
	end

	return true, flag
end)

Console.Parser("Template", function(ply, args, last, options)
	local template = table.remove(args, 1):lower()

	if not Template.Get(template) then
		return false, "Invalid template."
	end

	return true, template
end)
