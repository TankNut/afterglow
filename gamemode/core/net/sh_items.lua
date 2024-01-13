if CLIENT then
	netstream.Hook("ItemAdd", function(payload)
		items.GetOrInstance(payload.Name, payload.ID, payload.Data):SetInventory(inventories.Get(payload.Inventory))
	end)

	netstream.Hook("ItemRemove", function(id)
		local item = items.Get(id)

		if item then
			item:SetInventory(nil)
		end
	end)

	netstream.Hook("InventoryCreated", function(payload)
		local inventory = inventories.New(payload.StoreType, payload.StoreID, payload.ID)

		for _, v in pairs(payload.Items) do
			inventory:AddItem(items.GetOrInstance(v.Name, v.ID, v.Data), true)
		end
	end)

	netstream.Hook("InventoryRemoved", function(id)
		inventories.Remove(id)
	end)
end
