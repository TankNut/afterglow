local charflag = console.AddCommand("rpa_combine_flag_set", function(ply, targets, flag)
	local flagTable = Combine.Flag.GetOrDefault(flag)
	local name = flagTable.Name

	for _, target in pairs(targets) do
		target:SetCombineFlag(flag)

		console.Feedback(ply, "NOTICE", "You've set %s's combine flag to %s.", target:GetVisibleName(), name)
		console.Feedback(target, "NOTICE", "%s has set your combine flag to %s.", ply, name)
	end
end)

charflag:SetDescription("Sets someone's combine flag.")
charflag:AddParameter(console.Player())
charflag:AddOptional(console.CombineFlag(), nil, "None")
charflag:SetAccess(Command.IsAdmin)
