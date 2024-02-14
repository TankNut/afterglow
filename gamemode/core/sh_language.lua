module("Language", package.seeall)

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

local meta = FindMetaTable("Player")

function meta:IsOmniLingual()
	return self:GetOmniLingual() or self:GetCharacterFlagAttribute("OmniLingual")
end

function meta:HasLanguage(lang)
	if self:IsOmniLingual() then
		return true
	end

	if not Lookup[lang] then
		return false
	end

	return self:GetLanguages()[lang]
end

if SERVER then
	function meta:CheckLanguage()
		local active = self:GetActiveLanguage()

		if not Lookup[active] or not self:HasLanguage(active) then
			local languages = self:GetLanguages()

			for _, v in pairs(Config.Get("Languages")) do
				if languages[v[1]] then
					self:SetActiveLanguage(v[1])

					return
				end
			end

			self:SetActiveLanguage()
		end
	end

	function meta:AddLanguage(lang, switch)
		if not Lookup[lang] then
			return
		end

		local languages = self:GetLanguages()

		languages[lang] = true

		self:SetLanguages(languages)

		if switch or not self:GetActiveLanguage() then
			self:SetActiveLanguage(lang)
		end
	end

	function meta:RemoveLanguage(lang)
		if not Lookup[lang] then
			return
		end

		local languages = self:GetLanguages()

		languages[lang] = nil

		self:SetLanguages(languages)

		if self:GetActiveLanguage() == lang then
			self:CheckLanguage()
		end
	end
end

Character.RegisterVar("OmniLingual", {
	Accessor = "OmniLingual",
	Default = false
})

Character.RegisterVar("ActiveLanguage", {
	Private = true,
	Accessor = "ActiveLanguage"
})

Character.RegisterVar("Languages", {
	Private = true,
	Accessor = "Languages",
	Default = {}
})

if SERVER then
	hook.Add("PostLoadCharacter", "Language", function(ply, id)
		ply:CheckLanguage()
	end)

	hook.Add("PreCreateCharacter", "Language", function(ply, fields)
		fields.languages = Config.Get("DefaultLanguages")
	end)
end
