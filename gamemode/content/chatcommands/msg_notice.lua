CLASS.Name = "NOTICE"

CLASS.Color = Color(229, 201, 98)


if CLIENT then
	function CLASS:OnReceive(data, colors)
		return string.format("<c=%s>%s", self.Color, data.Text)
	end
end
