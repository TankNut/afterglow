local setFlag = Console.AddCommand("rpa_combine_flag_set", function(ply, targets, flag)
	local flagTable = Combine.Flag.GetOrDefault(flag)
	local name = flagTable.Name

	for _, target in pairs(targets) do
		local oldName = target:GetVisibleName()

		target:SetCombineFlag(flag)

		if flagTable == Combine.Flag.Default then
			Console.Feedback(ply, "NOTICE", "You've removed %s's combine flag", oldName)
			Console.Feedback(target, "NOTICE", "%s has removed your combine flag.", ply)
		else
			Console.Feedback(ply, "NOTICE", "You've set %s's combine flag to %s.", oldName, name)
			Console.Feedback(target, "NOTICE", "%s has set your combine flag to %s.", ply, name)
		end
	end
end)

setFlag:SetDescription("Sets someone's combine flag.")
setFlag:AddParameter(Console.Player())
setFlag:AddOptional(Console.CombineFlag(), nil, "None")
setFlag:SetAccess(Command.IsAdmin)

local setSquad = Console.AddCommand("rpa_combine_squad_set", function(ply, targets, squad)
	for _, target in pairs(targets) do
		local oldName = target:GetVisibleName()

		target:SetCombineSquad(squad)

		Console.Feedback(ply, "NOTICE", "You've set %s's combine squad to %s.", oldName, squad)
		Console.Feedback(target, "NOTICE", "%s has set your combine squad to %s.", ply, squad)
	end
end)

setSquad:SetDescription("Sets someone's combine squad.")
setSquad:AddParameter(Console.Player())
setSquad:AddOptional(Console.String(), "UNASSIGNED")
setSquad:SetAccess(Command.IsAdmin)

local setSquadID = Console.AddCommand("rpa_combine_squadid_set", function(ply, targets, id)
	for _, target in pairs(targets) do
		local oldName = target:GetVisibleName()

		target:SetCombineSquadID(id)

		Console.Feedback(ply, "NOTICE", "You've set %s's combine squad ID to %s.", oldName, id)
		Console.Feedback(target, "NOTICE", "%s has set your combine squad ID to %s.", ply, id)
	end
end)

setSquadID:SetDescription("Sets someone's combine squad ID.")
setSquadID:AddParameter(Console.Player())
setSquadID:AddOptional(Console.String(), "00")
setSquadID:SetAccess(Command.IsAdmin)
