local PANEL = {}

AccessorFunc(PANEL, "InventoryPanel", "InventoryPanel")

function PANEL:Init()
	self:SetPaintBackground(false)
	self:Receiver("Item", self.ReceivingItem)
end

function PANEL:ReceivingItem(panels, dropped, index, x, y)
	local panel = panels[1]
	local target = self:GetClosestChild(x, y)

	if IsValid(target) and panel != target then
		self:SetDropTarget(target:GetBounds())
	else
		self:SetDropTarget(0, 0, 0, 0)
	end
end

function PANEL:DrawDragHover(x, y, w, h)
	self:GetSkin():PaintItemHover(x, y, w, h)
end

function PANEL:OnChildAdded(child)
	child:Droppable("Item")
	child:Dock(TOP)
end

function PANEL:PerformLayout()
	local i = 0

	for k, v in pairs(self:GetChildren()) do
		if v:IsVisible() then
			v.VisiblePos = i
			i = i + 1
		end
	end

	self:SizeToChildren(false, true)
end

vgui.Register("afterglow_inventorylist", PANEL, "DPanel")
