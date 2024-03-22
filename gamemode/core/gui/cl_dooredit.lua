local PANEL = {}

function PANEL:Init()
	self:SetSize(320, 400)
	self:DockPadding(10, 10, 10, 10)

	self:SetAllowEscape(true)
	self:SetDrawTopBar(true)
	self:SetTitle("Door Editing")
	self:SetDraggable(true)

	self.Properties = self:Add("RPDoorProperties")
	self.Properties:Dock(FILL)

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(door)
	self.Properties:Setup(door)
end

derma.DefineControl("RPDoorEdit", "A panel for editing door data", PANEL, "RPBasePanel")

Interface.Register("DoorEdit", function(door)
	local panel = vgui.Create("RPDoorEdit")

	panel:Setup(door)

	return panel
end)
