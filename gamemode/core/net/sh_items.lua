if CLIENT then
	Netstream.Hook("ItemAdd", function(payload)
		Item.GetOrInstance(payload.Name, payload.ID, payload.Data):SetInventory(Inventory.Get(payload.Inventory))
	end)

	Netstream.Hook("ItemRemove", function(id)
		local item = Item.Get(id)

		if item then
			item:SetInventory(nil)
		end
	end)

	Netstream.Hook("ItemData", function(payload)
		local item = Item.Get(payload.ID)

		if item then
			item:SetProperty(payload.Key, payload.Value)
		end
	end)

	Netstream.Hook("InventoryCreated", function(payload)
		local inventory = Inventory.New(payload.StoreType, payload.StoreID, payload.ID)

		for _, v in pairs(payload.Items) do
			inventory:AddItem(Item.GetOrInstance(v.Name, v.ID, v.Data), true)
		end
	end)

	Netstream.Hook("InventoryRemoved", Inventory.Remove)
end

if SERVER then
	Netstream.Hook("ItemAction", function(ply, payload)
		local item = Item.Get(payload.ID)

		if not item or not item:CanInteract(ply) then
			return
		end

		item:FireAction(ply, payload.Name, payload.Value)
	end)
end
