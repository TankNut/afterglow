CLASS.Name = "Whisper"
CLASS.Description = "Quietly whisper to people close to you."

CLASS.Commands = {"whisper", "w"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 150

CLASS.Tabs = TAB_IC

CLASS.Color = Color(91, 166, 221)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s><i>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == Config.Get("BaseLanguage") then
				return string.format("<c=%s><i>%s: [WHISPER] %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s><i>(%s) %s: [WHISPER] %s", self.LanguageColor, Language.Lookup[data.Lang][2], data.Name, data.Text)
			end
		end
	end
else
	function CLASS:FormatUnknownLanguage(str, lang)
		lang = Language.Lookup[lang]

		local override = lang[4]

		if override then
			return isstring(override) or table.Random(override.Whisper)
		end

		return "whispers something in " .. (lang[3] or lang[2])
	end

	function CLASS:Parse(ply, lang, cmd, text)
		local targets = self:GetTargets(ply)

		local valid = {}
		local invalid = {}

		for _, v in pairs(targets) do
			table.insert(v:HasLanguage(lang) and valid or invalid, v)
		end

		Chat.Send(self.Name, {
			Name = ply:GetCharacterName(),
			Lang = lang,
			Text = text
		}, valid)

		local form = self:FormatUnknownLanguage(text, lang)

		Chat.Send(self.Name, {
			Name = ply:GetCharacterName(),
			Form = form
		}, invalid)
	end
end
