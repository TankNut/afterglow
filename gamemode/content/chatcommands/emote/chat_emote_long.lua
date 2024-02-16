CLASS.Name = "Emote (Long)"
CLASS.Description = "Perform an action. (Extended range)"

CLASS.Commands = {"lme"}

CLASS.Cast = true

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC

CLASS.Color = Color(131, 196, 251)

if CLIENT then
	function CLASS:OnReceive(data)
		local text = data.Text

		if not string.match(text, "^[,.']") then
			text = " " .. text
		end

		return string.format("<c=%s>** %s%s", self.Color, data.Name, text), string.format("<c=%s>[L] ** %s%s", self.Color, data.Name, text)
	end
else
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetCharacterName(),
			Text = text
		}
	end
end
