local boolValues = {
	f = false
}

local function arg(args, last)
	local str = last and table.concat(args, " ") or table.remove(args, 1)

	return str or ""
end

Console.Parser("Bool", function(ply, args, last, options)
	local val = arg(args, last)
	local bool = boolValues[val]

	if bool == nil then
		bool = tobool(val)
	end

	return true, bool
end)

Console.Parser("String", function(ply, args, last, options)
	return true, arg(args, last)
end)

Console.Parser("Number", function(ply, args, last, options)
	local num = tonumber(arg(args, last))

	if num == nil then
		return false, "Not a number."
	end

	return true, num
end)

Console.Parser("Time", function(ply, args, last, options)
	local duration = Duration.Parse(arg(args, last), options.Format)

	if duration == nil then
		return false, "Invalid duration."
	end

	return true, duration
end)

Console.Parser("Player", function(ply, args, last, options)
	return Command.FindPlayer(ply, arg(args, last), options)
end)

Console.Parser("Language", function(ply, args, last, options)
	local lang = arg(args, last):lower()

	if not Language.Get(lang) then
		return false, "Invalid language."
	end

	return true, lang
end)

Console.Parser("Badge", function(ply, args, last, options)
	local badge = arg(args, last):lower()
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
	local group = arg(args, last):lower()

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
	local flag = arg(args, last):lower()

	if not CharacterFlag.Get(flag) then
		return false, "Invalid flag."
	end

	return true, flag
end)

Console.Parser("Template", function(ply, args, last, options)
	local template = arg(args, last):lower()

	if not Template.Get(template) then
		return false, "Invalid template."
	end

	return true, template
end)

if CLIENT then
	local function itemList(class)
		local format = "  %s (%s)"

		if #class > 0 then
			Console.PrintLine(string.format("Available items: (Filter: %s)", class))

			for item in SortedPairs(Item.List) do
				local itemTable = Item.GetTable(item)

				if string.find(item, class, 1, true) and hook.Run("CanSpawnItem", LocalPlayer(), itemTable) then
					Console.PrintLine(string.format(format, item, itemTable.Name))
				end
			end
		else
			Console.PrintLine("Available items:")

			for item in SortedPairs(Item.List) do
				local itemTable = Item.GetTable(item)

				if hook.Run("CanSpawnItem", LocalPlayer(), itemTable) then
					Console.PrintLine(string.format(format, item, itemTable.Name))
				end
			end
		end
	end

	Netstream.Hook("ItemList", itemList)
end

Console.Parser("Item", function(ply, args, last, options)
	local item = arg(args, last):lower()

	if not Item.Exists(item) or not hook.Run("CanSpawnItem", ply, Item.GetTable(item)) then
		if options.List then
			if CLIENT then
				itemList(item)
			else
				Netstream.Send("ItemList", ply, item)
			end
		end

		return false, "Invalid item."
	end

	return true, item
end)
