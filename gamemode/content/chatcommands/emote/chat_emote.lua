CLASS.Name = "Emote"
CLASS.Description = "Perform an action."

CLASS.Commands = {"me"}
CLASS.Aliases = {":"}

CLASS.Range = 400
CLASS.MuffledRange = 150

CLASS.Tabs = TAB_IC

CLASS.Color = Color(131, 196, 251)

if CLIENT then
	function CLASS:OnReceive(data)
		local text = data.Text

		if not string.match(text, "^[,.']") then
			text = " " .. text
		end

		return string.format("<c=%s>** %s%s", self.Color, data.Name, text)
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
