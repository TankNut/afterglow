local meta = FindMetaTable("Player")

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

