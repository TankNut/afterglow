CLASS.Name = "Yell"
CLASS.Description = "Yell something at the top of your lungs."

CLASS.Commands = {"yell", "y"}

CLASS.UseLanguage = true
CLASS.Hearable = true

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC

CLASS.Color = Color(255, 50, 50)
CLASS.LanguageColor = Color(255, 167, 73)

if CLIENT then
	function CLASS:OnReceive(data)
		if data.Form then -- We don't understand them
			return string.format("<c=%s><b>%s %s.", self.LanguageColor, data.Name, data.Form)
		else -- We do understand them
			if data.Lang == LocalPlayer():GetCharacterFlagAttribute("BaseLanguage") then
				return string.format("<c=%s><b>%s: [YELL] %s", self.Color, data.Name, data.Text)
			else
				return string.format("<c=%s><b>(%s) %s: [YELL] %s", self.LanguageColor, Language.GetName(data.Lang), data.Name, data.Text)
			end
		end
	end
else
	function CLASS:FormatUnknownLanguage(str, lang)
		local override = Language.GetOverride(lang, "Yell")

		if override then
			return override
		end

		return string.format("yells something in %s!", Language.GetUnknown(lang))
	end

	function CLASS:Parse(ply, lang, cmd, text)
		local targets = self:GetTargets(ply)

		local valid = {}
		local invalid = {}

		for _, target in pairs(targets) do
			if target == ply or hook.Run("CanHearLanguage", target, lang) then
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
