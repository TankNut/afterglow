local PANEL = {}

function PANEL:Init()
	self:DockMargin(0, 0, 0, 10)
	self:Dock(TOP)
	self:SetPaintBackground(false)

	local left = self:Add("DPanel")

	left:DockMargin(0, 0, 10, 0)
	left:Dock(LEFT)
	left:SetWide(120)
	left:SetPaintBackground(false)

	self.Label = left:Add("DLabel")
	self.Label:Dock(FILL)
	self.Label:SetFont("afterglow.labelgiant")
	self.Label:SetText("")
	self.Label:SetContentAlignment(9)

	self.Canvas = self:Add("DPanel")
	self.Canvas:Dock(FILL)
	self.Canvas:SetPaintBackground(false)
end

function PANEL:SetTitle(title)
	self.Label:SetText(title)
end

derma.DefineControl("RPCharCreateEntry", "A simple layout panel for character creation options", PANEL, "DPanel")
