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
			if data.Lang == LocalPlayer():GetCharacterFlagAttribute("BaseLanguage") then
				return string.format("<c=%s><i>%s: [WHISPER] %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s><i>(%s) %s: [WHISPER] %s", self.LanguageColor, Language.GetName(data.Lang), data.Name, data.Text)
			end
		end
	end
end


if SERVER then
	function CLASS:FormatUnknownLanguage(str, lang)
		local override = Language.GetOverride(lang, "Whisper")

		if override then
			return override
		end

		return "whispers something in " .. Language.GetUnknown(lang)
	end


	function CLASS:Parse(ply, lang, cmd, text)
		local targets = self:GetTargets(ply)

		local valid = {}
		local invalid = {}

		for _, target in pairs(targets) do
			if target == ply or ply:CanUnderstandLanguage(lang) then
				table.insert(valid, target)
			else
				table.insert(invalid, target)
			end
		end

		-- No reason to check for an empty table since we're always sending the valid version to ourselves
		Chat.Send(self.Name, {
			Name = ply:GetCharacterName(),
			Lang = lang,
			Text = text
		}, valid)

		if not table.IsEmpty(invalid) then
			local form = self:FormatUnknownLanguage(text, lang)

			Chat.Send(self.Name, {
				Name = ply:GetCharacterName(),
				Form = form
			}, invalid)
		end
	end
end
