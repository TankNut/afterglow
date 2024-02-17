local charflag = console.AddCommand("rpa_setcharacterflag", function(ply, targets, flag)
	local flagTable = CharacterFlags.GetOrDefault(flag)
	local name = flagTable.Name

	for _, target in pairs(targets) do
		target:SetCharacterFlag(flag)

		console.Feedback(ply, "NOTICE", "You've set %s's character flag to %s.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has set your character flag to %s.", ply, name)
	end
end)

charflag:SetDescription("Sets a character's character flag.")
charflag:AddParameter(console.Player())
charflag:AddOptional(console.CharacterFlag(), nil, CharacterFlags.Default.Name)
charflag:SetAccess(Command.IsAdmin)
