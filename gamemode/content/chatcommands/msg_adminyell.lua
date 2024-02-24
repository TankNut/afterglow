CLASS.Name = "ADMINYELL"

CLASS.Color = Color(232, 20, 20)


if CLIENT then
	function CLASS:OnReceive(data, colors)
		return string.format("<c=%s><giant>%s", self.Color, data.Text)
	end
end
