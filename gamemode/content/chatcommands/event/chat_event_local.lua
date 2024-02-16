CLASS.Name = "Local Event"
CLASS.Description = "Describe a local event."

CLASS.Commands = {"lev"}

CLASS.Range = 800

CLASS.Tabs = TAB_IC

CLASS.Color = Color(255, 117, 48)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>[EVENT] ** %s", self.Color, data.Text), string.format("<c=%s>[LOCAL EVENT](%s) ** %s", self.Color, data.Name, data.Text)
	end
else
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetCharacterName(),
			Text = text
		}
	end
end
