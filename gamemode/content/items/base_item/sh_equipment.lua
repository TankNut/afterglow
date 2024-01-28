function ITEM:IsEquipment()
	return #self:GetProperty("Equipment") > 0
end

function ITEM:IsEquipped()
	return self:GetProperty("Equipped")
end

function ITEM:CanEquip()
	return true
end

function ITEM:CanUnequip()
	return true
end

function ITEM:GetModelData(ply, data)
end

if SERVER then
	function ITEM.TryEquip(self, ply, slot)
		if not table.HasValue(self:GetProperty("Equipment"), slot) then
			return
		end

		if ply:WaitFor(2, "Equipping...", {self}) and self:CanEquip() then
			self:SetProperty("Equipped", slot)
		end
	end

	function ITEM.TryUnequip(self, ply)
		if ply:WaitFor(2, "Unequipping...", {self}) and self:CanUnequip() then
			self:SetProperty("Equipped", nil)
		end
	end
end
