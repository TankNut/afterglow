CLASS.Name = "It"
CLASS.Description = "Describe something from a 3rd person perspective."

CLASS.Commands = {"it"}

CLASS.Range = 400
CLASS.MuffledRange = 150

CLASS.Tabs = TAB_IC

CLASS.Color = Color(131, 196, 251)


if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>** %s **", self.Color, data.Text), string.format("<c=%s>(%s) ** %s **", self.Color, data.Name, data.Text)
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
