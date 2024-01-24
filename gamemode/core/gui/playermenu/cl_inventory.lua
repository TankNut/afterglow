local function func(self)
	self.PlayerView = self:Add("afterglow_liveview")
	self.PlayerView:Dock(RIGHT)
	self.PlayerView:DockMargin(5, 0, 0, 0)
	self.PlayerView:SetWide(200)
	self.PlayerView:SetEntity(LocalPlayer())

	self.Inventory = self:Add("afterglow_inventorypanel")
	self.Inventory:Dock(FILL)
	self.Inventory:Setup(LocalPlayer():GetInventory())
end

hook.Add("PopulatePlayerMenu", "Inventory", function(pnl)
	pnl:AddMenu(2, "Inventory", func)
end)
