CLASS.Name = "It (Long)"
CLASS.Description = "Describe something from a 3rd person perspective. (Extended range)"

CLASS.Commands = {"lit"}

CLASS.Cast = true

CLASS.Range = 800
CLASS.MuffledRange = 400

CLASS.Tabs = TAB_IC

CLASS.Color = Color(131, 196, 251)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>** %s **", self.Color, data.Text), string.format("<c=%s>[L](%s) ** %s **", self.Color, data.Name, data.Text)
	end
else
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetCharacterName(),
			Text = text
		}
	end
end
