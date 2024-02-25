module("Language", package.seeall)

local meta = FindMetaTable("Player")

List = table.Copy(Config.Get("Languages"))
Lookup = {}


for _, v in pairs(List) do
	Lookup[v[1]] = v
end


function Get(command)
	return Lookup[command]
end

function GetName(command)
	return Get(command)[2]
end

function GetUnknown(command)
	local lang = Get(command)

	return lang[3] or lang[2]
end

function GetOverride(command, index)
	local override = Get(command)[4]

	if override and override[index] then
		override = override[index]

		return isstring(override) and override or table.Random(override)
	end
end


function FromConfig(data)
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

		if not Lookup[active] or not languages[active] then
			for _, v in pairs(Config.Get("Languages")) do
				if languages[v[1]] then
					self:SetActiveLanguage(v[1])

					return
				end
			end

			self:SetActiveLanguage()
		end
	end

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
end


function GM:CanSpeakLanguage(ply, lang)
	return ply:GetLanguages()[lang] == true
end

function GM:CanUnderstandLanguage(ply, lang)
	return ply:GetLanguages()[lang] != nil
end


if SERVER then
	hook.Add("PostLoadCharacter", "Language", function(ply, id)
		ply:CheckLanguage()
	end)

	hook.Add("PreCreateCharacter", "Language", function(ply, fields)
		fields.languages = Config.Get("DefaultLanguages")
	end)
end
