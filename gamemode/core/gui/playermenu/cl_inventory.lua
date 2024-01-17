local function func(self)
end

hook.Add("PopulatePlayerMenu", "Inventory", function(pnl)
	pnl:AddMenu(2, "Inventory", func)
end)
