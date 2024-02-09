DEFINE_BASECLASS("base_item")

ITEM.Category = "Clothing"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Armor = 0

function ITEM:CanEquip()
	return self.Player:GetCharacterFlagAttribute("AllowClothing")
end

function ITEM:GetArmor()
	return self:GetProperty("Armor")
end

function ITEM:OnEquip()
	BaseClass.OnEquip(self)

	if SERVER and self:GetArmor() > 0 then
		self.Player:UpdateArmor()
	end
end

function ITEM:OnUnequip()
	BaseClass.OnUnequip(self)

	if SERVER and self:GetArmor() > 0 then
		self.Player:UpdateArmor()
	end
end
