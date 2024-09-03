Language = Language or {}
Language.List = table.Copy(Config.Get("Languages"))
Language.Lookup = {}

for _, v in pairs(Language.List) do
	Language.Lookup[v[1]] = v
end

local meta = FindMetaTable("Player")

Character.AddVar("ActiveLanguage", {
	Field = "active_language",
	Private = true,
	Accessor = "ActiveLanguage"
})

Character.AddVar("Languages", {
	Private = true,
	Accessor = "Languages",
	Default = {}
})

function Language.Get(command)
	return Language.Lookup[command]
end

function Language.GetName(command)
	return Language.Get(command)[2]
end

function Language.GetUnknown(command)
	local lang = Language.Get(command)

	return lang[3] or lang[2]
end

function Language.GetOverride(command, index)
	local override = Language.Get(command)[4]

	if override and override[index] then
		override = override[index]

		return isstring(override) and override or table.Random(override)
	end
end

function Language.FromConfig(data)
	local langs = {}

	for _, lang in pairs(data) do
		langs[lang[1]] = lang[2]
	end

	return langs
end

function meta:CanSpeakLanguage(lang)
	return hook.Run("CanSpeakLanguage", self, lang)
end

function meta:CanUnderstandLanguage(lang)
	return hook.Run("CanUnderstandLanguage", self, lang)
end

if SERVER then
	function meta:CheckLanguage()
		local languages = self:GetLanguages()
		local active = self:GetActiveLanguage()

		if not Language.Lookup[active] or not languages[active] then
			for _, v in pairs(Language.List) do
				if languages[v[1]] then
					self:SetActiveLanguage(v[1])

					return
				end
			end

			self:SetActiveLanguage()
		end
	end

	hook.Add("PostLoadCharacter", "Language", function(ply, id)
		ply:CheckLanguage()
	end)

	function meta:GiveLanguage(lang, speak)
		speak = speak or false

		local languages = self:GetLanguages()

		languages[lang] = speak

		self:SetLanguages(languages)

		if not self:GetActiveLanguage() and speak then
			self:SetActiveLanguage(lang)
		end
	end

	function meta:TakeLanguage(lang)
		local languages = self:GetLanguages()

		languages[lang] = nil

		self:SetLanguages(languages)

		if self:GetActiveLanguage() == lang then
			self:CheckLanguage()
		end
	end

	hook.Add("PreCreateCharacter", "Language", function(ply, fields)
		local field = Character.VarToField("Languages")

		if not fields[field] then
			fields[field] = Config.Get("DefaultLanguages")
		end
	end)
end
