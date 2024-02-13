module("Language", package.seeall)

Lookup = {}

for _, v in pairs(Config.Get("Languages")) do
	Lookup[v[1]] = v
end

function FormatUnknown(str, lang)
	lang = Lookup[lang]

	if lang[4] then
		return lang[3]
	end

	local lastCharacter = string.Right(str, 1)
	local form = "says"

	if lastCharacter == "?" then
		form = "asks"
	elseif lastCharacter == "!" then
		form = "exclaims"
	end

	return form .. " something in " .. (lang[3] or lang[2])
end

local meta = FindMetaTable("Player")

function meta:HasLanguage(lang)
	if self:GetOmniLingual() then
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

		if not Lookup[active] then
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
	Private = true,
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
