CLASS.Name = "ERROR"

CLASS.Color = Color(200, 0, 0)
CLASS.ConsoleColor = Color(255, 0, 0)


if CLIENT then
	function CLASS:OnReceive(data, colors)
		return string.format("<c=%s>Error: %s", self.Color, data.Text), string.format("<c=%s>Error: %s", self.ConsoleColor, data.Text)
	end
end
