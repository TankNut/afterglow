CLASS.Name = "Character Info"

CLASS.Optional = true
CLASS.Default = true

function CLASS:Initialize(ply)
	self:UpdateInfo(ply, true)
end

function CLASS:UpdateInfo(ply, force)
	if not force and self.LastName == ply:GetVisibleName() and self.LastTeam == ply:Team() then
		return
	end

	self.LastName = ply:GetVisibleName()
	self.LastTeam = ply:Team()

	local color = Hud.Skin.Text.Normal

	self.Name = scribe.Parse(string.format("<giant><ol><c=%s>%s", color, self.LastName))
	self.Team = scribe.Parse(string.format("<giant><ol><c=%s>%s", color, team.GetName(self.LastTeam)))
end

function CLASS:Paint(ply, w, h)
	self:UpdateInfo(ply)

	local offset = 20
	local margin = 2

	local x, y = offset, h - offset

	local scribeW = math.max(self.Name:GetWide(), self.Team:GetWide())
	local scribeH = self.Name:GetTall() + self.Team:GetTall()

	local boxW = math.max(scribeW + margin * 2, 220)
	local boxH = scribeH + margin * 2

	surface.SetDrawColor(ColorAlpha(Hud.Skin.Colors.FillDark, 200))
	self:DrawAlignedRect(x, y, boxW, boxH, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	self.Name:Draw(x + boxW - margin, y - boxH + margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	self.Team:Draw(x + boxW - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end
