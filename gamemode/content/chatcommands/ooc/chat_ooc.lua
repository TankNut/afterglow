CLASS.Name = "OOC"
CLASS.Description = "Global out-of-character chat."

CLASS.Commands = {"ooc"}
CLASS.Aliases = {"//"}

CLASS.Tabs = TAB_OOC

CLASS.Color = Color(200, 0, 0)

if CLIENT then
	function CLASS:OnReceive(data)
		return string.format("<c=%s>[OOC]</c> <c=%s>%s</c>: %s", self.Color, data.Color, data.Name, data.Text)
	end
end

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetVisibleName(),
			Color = team.GetColor(ply:Team()),
			Text = text
		}
	end
end
