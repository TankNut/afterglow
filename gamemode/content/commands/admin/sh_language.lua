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

give:SetDescription("Gives a character the ability to speak and hear a specific language.")
give:AddParameter(console.Player())
give:AddParameter(console.Language())
give:SetAccess(Command.IsAdmin)

local take = console.AddCommand("rpa_takelanguage", function(ply, targets, lang)
	local name = Language.GetName(lang)

	for _, target in pairs(targets) do
		if not target:HasLanguage(lang) then
			console.Feedback(ply, "ERROR", "%s doesn't speak %s.", target:GetCharacterName(), name)

			continue
		end

		target:RemoveLanguage(lang)

		console.Feedback(ply, "NOTICE", "You've taken the ability to speak %s from %s.", name, target:GetCharacterName())
		console.Feedback(target, "NOTICE", "%s has removed your ability to speak %s.", ply, name)
	end
end)

take:SetDescription("Take the ability to speak and hear a specific language from a character.")
take:AddParameter(console.Player())
take:AddParameter(console.Language())
take:SetAccess(Command.IsAdmin)
