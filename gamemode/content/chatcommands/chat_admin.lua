CLASS.Name = "Admin"
CLASS.Description = "Global out-of-character chat."

CLASS.Commands = {"a", "admin"}
CLASS.Aliases = {"@"}

CLASS.Tabs = TAB_ADMIN

CLASS.NameColor = Color(255, 107, 218)
CLASS.TextColor = Color(255, 156, 230)


if CLIENT then
	function CLASS:OnReceive(data)
		local prefix = LocalPlayer():IsAdmin() and "ADMIN" or "TO ADMINS"

		return string.format("<c=%s>%s:</c> <c=%s>[%s] %s", self.NameColor, data.Name, self.TextColor, prefix, data.Text)
	end
end


if SERVER then
	function CLASS:GetTargets(ply, data)
		return table.Add({ply}, player.GetByUserGroup("admin"))
	end

	function CLASS:Parse(ply, lang, cmd, text)
		return {
			Name = ply:GetCharacterName(),
			Text = ply:IsAdmin() and text or "! " .. text
		}
	end
end
