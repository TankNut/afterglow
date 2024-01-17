local function func(self)
end

hook.Add("PopulatePlayerMenu", "Description", function(pnl)
	pnl:AddMenu(1, "Description", func)
end)
