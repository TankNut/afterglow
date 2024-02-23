local charflag = console.AddCommand("rpa_flag_set", function(ply, targets, flag)
	local flagTable = CharacterFlag.GetOrDefault(flag)
	local name = flagTable.Name

	for _, target in pairs(targets) do
		target:SetCharacterFlag(flag)

		console.Feedback(ply, "NOTICE", "You've set %s's character flag to %s.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has set your character flag to %s.", ply, name)
	end
end)

charflag:SetDescription("Sets someone's character flag.")
charflag:AddParameter(console.Player())
charflag:AddOptional(console.CharacterFlag(), nil, CharacterFlag.Default.Name)
charflag:SetAccess(Command.IsAdmin)
