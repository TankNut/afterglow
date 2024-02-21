local PANEL = {}

function PANEL:Init()
	self:SetSize(200, 200)
	self:DockPadding(10, 10, 10, 10)

	self:SetAllowEscape(true)
	self:SetDrawTopBar(true)
	self:SetTitle("Badges")

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(ply)
	for _, badge in pairs(ply:GetBadges()) do
		local row = self:Add("DPanel")

		row:DockMargin(0, 0, 0, 6)
		row:Dock(TOP)
		row:SetTall(16)
		row:SetPaintBackground(false)

		local image = row:Add("DImage")

		image:Dock(LEFT)
		image:SetWide(16)
		image:SetMaterial(badge.Material)

		local text = row:Add("DLabel")

		text:DockMargin(6, 0, 0, 0)
		text:Dock(FILL)
		text:SetFont("afterglow.labelsmall")
		text:SetText(badge.Name)
	end
end

derma.DefineControl("RPBadgeList", "A list of badges for a single player", PANEL, "RPBasePanel")

Interface.Register("BadgeList", function(ply)
	local panel = vgui.Create("RPBadgeList")

	panel:Setup(ply)

	return panel
end)
