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

	netstream.Hook("ItemData", function(payload)
		local item = Item.Get(payload.ID)

		if item then
			item:SetProperty(payload.Key, payload.Value)
		end
	end)

	netstream.Hook("InventoryCreated", function(payload)
		local inventory = Inventory.New(payload.StoreType, payload.StoreID, payload.ID)

		for _, v in pairs(payload.Items) do
			inventory:AddItem(Item.GetOrInstance(v.Name, v.ID, v.Data), true)
		end
	end)

	netstream.Hook("InventoryRemoved", Inventory.Remove)
else
	netstream.Hook("ItemAction", function(ply, payload)
		local item = Item.Get(payload.ID)

		if not item or not item:CanInteract(ply) then
			return
		end

		item:FireAction(ply, payload.Name, payload.Value)
	end)
end
