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

local reset = console.AddCommand("rpa_resetlanguages", function(ply, targets)
	local cache = {}

	for _, target in pairs(targets) do
		target:SetLanguages(target:GetCharacterFlagAttribute("DefaultLanguages"))
		target:CheckLanguage()

		local flag = target:GetCharacterFlag()
		local names = cache[flag]

		if not names then
			names = target:GetLanguages()

			for k, lang in pairs(names) do
				names[k] = Language.GetName(lang)
			end

			names = table.concat(names, ", ")
			cache[flag] = names
		end

		if #names < 1 then
			names = "none"
		end

		console.Feedback(ply, "NOTICE", "You've reset %s's languages to (%s).", target:GetCharacterName(), names)
		console.Feedback(target, "NOTICE", "%s has reset your languages to (%s).", ply, names)
	end
end)

reset:SetDescription("Resets a character's languages to the default for their character flag.")
reset:AddParameter(console.Player())
reset:SetAccess(Command.IsAdmin)

local set = console.AddCommand("rpa_setlanguages", function(ply, targets, languages)
	languages = string.Explode("[^%a]+", languages, true)

	for k, lang in pairs(languages) do
		if k == 1 and lang == "" then
			languages = {}
			break
		end

		if not Language.Get(lang) then
			console.Feedback(ply, "ERROR", "Unknown language: %s", lang)

			return
		end
	end

	local names = {}

	for k, lang in pairs(languages) do
		names[k] = Language.GetName(lang)
	end

	names = table.concat(names, ", ")

	if #names < 1 then
		names = "none"
	end

	languages = table.Lookup(languages)

	for _, target in pairs(targets) do
		target:SetLanguages(languages)
		target:CheckLanguage()

		console.Feedback(ply, "NOTICE", "You've set %s's languages to (%s).", target:GetCharacterName(), names)
		console.Feedback(target, "NOTICE", "%s has set your languages to (%s).", ply, names)
	end
end)

set:SetDescription("Sets a character's languages to a specific set of languages.")
set:AddParameter(console.Player())
set:AddOptional(console.String({}, "Languages"), "", "none")
set:SetAccess(Command.IsAdmin)
