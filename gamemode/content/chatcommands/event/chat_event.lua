CLASS.Name = "Event"
CLASS.Description = "Describe a global event."

CLASS.Commands = {"ev"}

CLASS.Tabs = TAB_IC

CLASS.Color = Color(0, 191, 255)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>[EVENT] ** %s", self.Color, data.Text), string.format("<c=%s>[EVENT](%s) ** %s", self.Color, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetVisibleName(),
			Text = text
		}
	end
end
