local give = console.AddCommand("rpa_language_give", function(ply, targets, lang, speaking)
	local name = Language.GetName(lang)
	local ability = speaking and "speak" or "understand"

	for _, target in pairs(targets) do
		if target:CanSpeakLanguage(lang) or (not speaking and target:CanUnderstandLanguage(lang)) then
			console.Feedback(ply, "ERROR", "%s already %ss %s.", target:GetCharacterName(), ability, name)

			continue
		end

		target:AddLanguage(lang, speaking)

		console.Feedback(ply, "NOTICE", "You've given %s the ability to %s %s.", target:GetCharacterName(), ability, name)
		console.Feedback(target, "NOTICE", "%s has given you the ability to %s %s.", ply, ability, name)
	end
end)

give:SetDescription("Gives a character the ability to speak or understand a specific language.")
give:AddParameter(console.Player())
give:AddParameter(console.Language())
give:AddOptional(console.Bool({}, "Speaking"), true)
give:SetAccess(Command.IsAdmin)

local take = console.AddCommand("rpa_language_take", function(ply, targets, lang)
	local name = Language.GetName(lang)

	for _, target in pairs(targets) do
		if not target:CanUnderstandLanguage(lang) then
			console.Feedback(ply, "ERROR", "%s doesn't know %s.", target:GetCharacterName(), name)

			continue
		end

		local ability = ply:CanSpeakLanguage(lang) and "speak" or "understand"

		target:RemoveLanguage(lang)

		console.Feedback(ply, "NOTICE", "You've taken the ability to %s %s from %s.", ability, name, target:GetCharacterName())
		console.Feedback(target, "NOTICE", "%s has removed your ability to %s %s.", ply, ability, name)
	end
end)

take:SetDescription("Removes the ability to understand a specific language from a character.")
take:AddParameter(console.Player())
take:AddParameter(console.Language())
take:SetAccess(Command.IsAdmin)

local reset = console.AddCommand("rpa_language_reset", function(ply, targets)
	for _, target in pairs(targets) do
		target:SetLanguages(target:GetCharacterFlagAttribute("DefaultLanguages"))
		target:CheckLanguage()

		console.Feedback(ply, "NOTICE", "You've reset %s's languages.", target:GetCharacterName())
		console.Feedback(target, "NOTICE", "%s has reset your languages.", ply)
	end
end)

reset:SetDescription("Resets a character's languages to the default for their character flag.")
reset:AddParameter(console.Player())
reset:SetAccess(Command.IsAdmin)

local function verify(ply, tab)
	for k, lang in pairs(tab) do
		if k == 1 and lang == "" then
			return {}
		end

		if not Language.Get(lang) then
			console.Feedback(ply, "ERROR", "Unknown language: %s", lang)
			return false
		end
	end

	return tab
end

local set = console.AddCommand("rpa_language_set", function(ply, targets, languages, hearing)
	languages = verify(ply, string.Explode("[^%a]+", languages, true))

	if not languages then
		return
	end

	hearing = verify(ply, string.Explode("[^%a]+", hearing, true))

	if not hearing then
		return
	end

	local data = {}

	for _, v in pairs(languages) do
		data[v] = true
	end

	for _, v in pairs(hearing) do
		data[v] = false
	end

	for _, target in pairs(targets) do
		target:SetLanguages(data)
		target:CheckLanguage()

		console.Feedback(ply, "NOTICE", "You've set %s's languages.", target:GetCharacterName(), names)
		console.Feedback(target, "NOTICE", "%s has set your languages.", ply, names)
	end
end)

set:SetDescription("Sets a character's languages to a specific set.")
set:AddParameter(console.Player())
set:AddOptional(console.String({}, "Languages"), "", "none")
set:AddOptional(console.String({}, "Hearing only"), "", "none")
set:SetAccess(Command.IsAdmin)
