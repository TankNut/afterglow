local give = console.AddCommand("rpa_givelanguage", function(ply, targets, lang)
	local name = Language.GetName(lang)

	for _, target in pairs(targets) do
		if target:HasLanguage(lang) then
			console.Feedback(ply, "ERROR", "%s already speaks %s.", target:GetCharacterName(), name)

			continue
		end

		target:AddLanguage(lang)

		console.Feedback(ply, "NOTICE", "You've given %s the ability to speak %s.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has given you the ability to speak %s.", ply, name)
	end
end)

give:SetDescription("Gives a player the ability to speak and hear a specific language.")
give:AddParameter(console.Player())
give:AddParameter(console.Language())
give:SetAccess(Command.IsAdmin)
