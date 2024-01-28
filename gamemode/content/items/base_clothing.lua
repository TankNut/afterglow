ITEM.Category = "Clothing"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Armor = 0

function ITEM:GetArmor()
	return self:GetProperty("Armor")
end
