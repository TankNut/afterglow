CLASS.Name = "Say"
CLASS.Description = "Speak."

CLASS.Commands = {"say"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 400
CLASS.MuffledRange = 150

CLASS.Tabs = TAB_IC

CLASS.Color = Color(91, 166, 221)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == Config.Get("BaseLanguage") then
				return string.format("<c=%s>%s: %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s>[%s] %s: %s", self.LanguageColor, Language.Lookup[data.Lang][2], data.Name, data.Text)
			end
		end
	end
else
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

		local form = Language.FormatUnknown(text, lang)

		Chat.Send(self.Name, {
			Name = ply:GetCharacterName(),
			Form = form
		}, invalid)
	end
end
