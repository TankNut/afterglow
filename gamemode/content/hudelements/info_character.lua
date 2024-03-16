CLASS.Name = "Character Info"

CLASS.Optional = true
CLASS.Default = true

function CLASS:Initialize()
	self:UpdateInfo(true)
end

function CLASS:UpdateInfo(force)
	local ply = self.Player

	if not force and self.LastName == ply:GetVisibleName() and self.LastTeam == ply:Team() then
		return
	end

	self.LastName = ply:GetVisibleName()
	self.LastTeam = ply:Team()

	local color = Hud.Skin.Text.Normal

	self.NameScribe = Scribe.Parse(string.format("<giant><ol><c=%s>%s", color, self.LastName))
	self.TeamScribe = Scribe.Parse(string.format("<giant><ol><c=%s>%s", color, team.GetName(self.LastTeam)))
end

function CLASS:Paint(w, h)
	self:UpdateInfo()

	local offset = 20
	local margin = 2

	local x, y = offset, h - offset

	local scribeW = math.max(self.NameScribe:GetWide(), self.TeamScribe:GetWide())
	local scribeH = self.NameScribe:GetTall() + self.TeamScribe:GetTall()

	local boxW = math.max(scribeW + margin * 2, 220)
	local boxH = scribeH + margin * 2

	surface.SetDrawColor(ColorAlpha(Hud.Skin.Colors.FillDark, 200))
	self:DrawAlignedRect(x, y, boxW, boxH, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	self.NameScribe:Draw(x + boxW - margin, y - boxH + margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	self.TeamScribe:Draw(x + boxW - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end
