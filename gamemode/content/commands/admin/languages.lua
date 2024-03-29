local give = Console.AddCommand("rpa_language_give", function(ply, targets, lang, speaking)
	local name = Language.GetName(lang)
	local ability = speaking and "speak" or "understand"

	for _, target in pairs(targets) do
		if target:CanSpeakLanguage(lang) or (not speaking and target:CanUnderstandLanguage(lang)) then
			Console.Feedback(ply, "ERROR", "%s already %ss %s.", target:GetVisibleName(), ability, name)

			continue
		end

		target:GiveLanguage(lang, speaking)

		Console.Feedback(ply, "NOTICE", "You've given %s the ability to %s %s.", target:GetVisibleName(), ability, name)
		Console.Feedback(target, "NOTICE", "%s has given you the ability to %s %s.", ply, ability, name)
	end
end)

give:SetDescription("Gives someone the ability to speak or understand a specific language.")
give:AddParameter(Console.Player())
give:AddParameter(Console.Language())
give:AddOptional(Console.Bool({}, "Speaking"), true)
give:SetAccess(Command.IsAdmin)

local take = Console.AddCommand("rpa_language_take", function(ply, targets, lang)
	local name = Language.GetName(lang)

	for _, target in pairs(targets) do
		if not target:CanUnderstandLanguage(lang) then
			Console.Feedback(ply, "ERROR", "%s doesn't know %s.", target:GetVisibleName(), name)

			continue
		end

		local ability = ply:CanSpeakLanguage(lang) and "speak" or "understand"

		target:TakeLanguage(lang)

		Console.Feedback(ply, "NOTICE", "You've taken the ability to %s %s from %s.", ability, name, target:GetVisibleName())
		Console.Feedback(target, "NOTICE", "%s has removed your ability to %s %s.", ply, ability, name)
	end
end)

take:SetDescription("Removes the ability to understand a specific language from someone.")
take:AddParameter(Console.Player())
take:AddParameter(Console.Language())
take:SetAccess(Command.IsAdmin)

local reset = Console.AddCommand("rpa_language_reset", function(ply, targets)
	for _, target in pairs(targets) do
		target:SetLanguages(target:GetCharacterFlagAttribute("DefaultLanguages"))
		target:CheckLanguage()

		Console.Feedback(ply, "NOTICE", "You've reset %s's languages.", target:GetVisibleName())
		Console.Feedback(target, "NOTICE", "%s has reset your languages.", ply)
	end
end)

reset:SetDescription("Resets someone's languages to the default for their character flag.")
reset:AddParameter(Console.Player())
reset:SetAccess(Command.IsAdmin)

local function verify(ply, tab)
	for k, lang in pairs(tab) do
		if k == 1 and lang == "" then
			return {}
		end

		if not Language.Get(lang) then
			Console.Feedback(ply, "ERROR", "Unknown language: %s", lang)
			return false
		end
	end

	return tab
end

local set = Console.AddCommand("rpa_language_set", function(ply, targets, languages, hearing)
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

		Console.Feedback(ply, "NOTICE", "You've set %s's languages.", target:GetVisibleName())
		Console.Feedback(target, "NOTICE", "%s has set your languages.", ply)
	end
end)

set:SetDescription("Sets someone's languages to a specific set.")
set:AddParameter(Console.Player())
set:AddOptional(Console.String({}, "Languages"), "", "none")
set:AddOptional(Console.String({}, "Hearing only"), "", "none")
set:SetAccess(Command.IsAdmin)
