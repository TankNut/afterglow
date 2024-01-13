if CLIENT then
	netstream.Hook("ItemAdd", function(payload)
		Item.GetOrInstance(payload.Name, payload.ID, payload.Data):SetInventory(Inventory.Get(payload.Inventory))
	end)

	netstream.Hook("ItemRemove", function(id)
		local item = Item.Get(id)

		if item then
			item:SetInventory(nil)
		end
	end)

	netstream.Hook("InventoryCreated", function(payload)
		local inventory = Inventory.New(payload.StoreType, payload.StoreID, payload.ID)

		for _, v in pairs(payload.Items) do
			inventory:AddItem(Item.GetOrInstance(v.Name, v.ID, v.Data), true)
		end
	end)

	netstream.Hook("InventoryRemoved", Inventory.Remove)
end
