local meta = FindMetaTable("Entity")


function meta:GetInventory()
	return Inventory.Get(self:GetNetVar("InventoryID"))
end


function meta:GetItems(class, allowChildren)
	return self:GetInventory():GetItems(class, allowChildren)
end


function meta:GetFirstItem(class, allowChildren)
	return self:GetInventory():GetFirstItem(class, allowChildren)
end


function meta:GetItemAmount(class)
	return self:GetInventory():GetAmount(class)
end


function meta:HasItem(class, amount)
	return self:GetInventory():HasItem(class, amount)
end


function meta:InventoryWeight()
	return self:GetInventory():GetWeight()
end


function meta:InventoryMaxWeight()
	local weight = self:GetCharacterFlagAttribute("MaxWeight")

	return weight
end


if SERVER then
	function meta:SetInventory(inventory)
		self:SetNetVar("InventoryID", inventory.ID)
	end
end
