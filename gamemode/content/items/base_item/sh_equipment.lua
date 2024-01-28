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
	ITEM.TryEquip = coroutine.Bind(function(self, ply, slot)
		if not table.HasValue(self:GetProperty("Equipment"), slot) then
			return
		end

		if ply:WaitFor(2, "Equipping...", {self}) and self:CanEquip() then
			self:SetProperty("Equipped", slot)
		end
	end)

	ITEM.TryUnequip = coroutine.Bind(function(self, ply)
		if ply:WaitFor(2, "Unequipping...", {self}) and self:CanUnequip() then
			self:SetProperty("Equipped", nil)
		end
	end)
end
