local PANEL = {}
DEFINE_BASECLASS("afterglow_basepanel")

function PANEL:Init()
	self:SetSize(400, 450)

	self:SetAllowEscape(true)
	self:SetDrawTopBar(true)
	self:SetDraggable(true)

	self.ModelPanel = self:Add("afterglow_itemmodelpanel")
	self.ModelPanel:Dock(TOP)
	self.ModelPanel:SetTall(200)

	self.ButtonPanel = self:Add("DPanel")
	self.ButtonPanel:Dock(BOTTOM)
	self.ButtonPanel:DockMargin(0, 5, 0, 0)
	self.ButtonPanel:SetPaintBackground(false)
	self.ButtonPanel:SetTall(22 * 3 + 15)

	self.RightPanel = self.ButtonPanel:Add("DPanel")
	self.RightPanel:Dock(RIGHT)
	self.RightPanel:DockMargin(0, 0, 5, 5)
	self.RightPanel:SetPaintBackground(false)
	self.RightPanel:SetWide(100)

	self.DestroyButton = self.RightPanel:Add("DButton")
	self.DestroyButton:Dock(BOTTOM)
	self.DestroyButton:DockMargin(0, 5, 0, 0)
	self.DestroyButton:SetText("Destroy")

	self.DropButton = self.RightPanel:Add("DButton")
	self.DropButton:Dock(BOTTOM)
	self.DropButton:DockMargin(0, 5, 0, 0)
	self.DropButton:SetText("Drop")

	self.ActionButton = self.RightPanel:Add("DButton")
	self.ActionButton:Dock(BOTTOM)
	self.ActionButton:DockMargin(0, 5, 0, 0)
	self.ActionButton:SetText("Actions")

	self.TitleScribe = self:Add("scribe_label")
	self.TitleScribe:DockMargin(5, 2, 5, 0)
	self.TitleScribe:Dock(TOP)

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:DockMargin(5, 0, 5, 0)
	self.Scroll:Dock(FILL)

	self.Scribe = self.Scroll:Add("scribe_label")

	self.Scroll:AddItem(self.Scribe)

	self.DataScribe = self.ButtonPanel:Add("scribe_label")
	self.DataScribe:Dock(FILL)
	self.DataScribe:DockMargin(5, 2, 5, 5)
	self.DataScribe:SetAlignment(TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

function PANEL:Populate(item)
	self.Item = item

	self:SetTitle(item:GetName())

	self.ModelPanel:SetModel(item:GetProperty("Model"))
	self.ModelPanel:SetOrbitDistance(self.ModelPanel.Entity:GetModelRadius() + 75)

	self.ModelPanel:SetLookAng(item:GetProperty("InspectAngle"))
	self.ModelPanel:SetFOV(item:GetProperty("InspectFOV"))

	self:InvalidateLayout(true)

	self.TitleScribe:SetText(string.format("<giant>%s", item:GetName()))
	self.TitleScribe:SizeToContentsY()

	self.Scroll:InvalidateLayout(true)

	self.Scribe:SetWide(self.Scroll:GetWide() - 15)
	self.Scribe:SetText(string.format("\n<cnormal>%s", item:GetDescription()))
	self.Scribe:SizeToContentsY()

	self.DataScribe:SetText(string.format("<cdisabled><tiny>Weight: %s kg\nTags: %s", item:GetWeight(), table.concat(item:GetTags(), ", ")))
end

vgui.Register("afterglow_itempopup", PANEL, "afterglow_basepanel")

Interface.Register("ItemPopup", function(item)
	local panel = vgui.Create("afterglow_itempopup")

	panel:Populate(item)
	panel:MakePopup()
	panel:Center()

	return panel
end)
