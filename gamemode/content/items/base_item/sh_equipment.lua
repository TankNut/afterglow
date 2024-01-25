function ITEM:IsEquipment()
	return #self:GetProperty("Equipment") > 0
end

function ITEM:IsEquipped()
	return self:GetProperty("Equipped")
end

function ITEM:GetModelData(ply)
	return
end

function ITEM:OnEquip(loaded)
	self:FireEvent("EquipmentChanged")

	if SERVER and not loaded and self:GetModelData(self.Player) != nil then
		self.Player:UpdateAppearance()
	end
end

function ITEM:OnUnequip()
	self:FireEvent("EquipmentChanged")

	if SERVER and self:GetModelData(self.Player) != nil then
		self.Player:UpdateAppearance()
	end
end

-- Has to be shared defined for actions to work... lol
function ITEM:TryEquip(ply, slot)
	if table.HasValue(self:GetProperty("Equipment"), slot) then
		self:SetProperty("Equipped", slot)
	end
end

function ITEM:TryUnequip(ply)
	self:SetProperty("Equipped", nil)
end
