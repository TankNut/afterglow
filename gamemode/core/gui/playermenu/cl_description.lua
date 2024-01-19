local function func(self)
	self.Preview = self:Add("afterglow_playerview")
	self.Preview:DockMargin(0, 0, 5, 0)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(200)
	self.Preview:SetPlayer(LocalPlayer())
end

hook.Add("PopulatePlayerMenu", "Description", function(pnl)
	pnl:AddMenu(1, "Description", func)
end)
