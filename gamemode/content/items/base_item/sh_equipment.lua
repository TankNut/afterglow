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

local stub = ITEM.GetModelData

function ITEM:OnEquip(loaded)
	if SERVER and not loaded and self.GetModelData != stub then
		self.Player:UpdateAppearance()
	end
end

function ITEM:OnUnequip()
	if SERVER and self.GetModelData != stub then
		self.Player:UpdateAppearance()
	end
end

if SERVER then
	function ITEM:OnSpawn()
	end

	function ITEM:Equip(slot)
		local ply = self.Player
		local existing = ply:GetEquipment(slot)

		if existing then
			existing:Unequip(true)
		end

		local equipment = ply:GetEquipmentCache()
			equipment[slot] = self.ID

		ply:SetEquipmentCache(equipment)

		self:SetProperty("Equipped", slot)
	end

	function ITEM:Unequip(noEquipmentCache)
		local ply = self.Player
		local slot = self:IsEquipped()

		if not noEquipmentCache then
			local equipment = ply:GetEquipmentCache()
				equipment[slot] = nil

			ply:SetEquipmentCache(equipment)
		end

		self:SetProperty("Equipped", nil)
	end

	function ITEM:TryEquip(ply, slot)
		if not table.HasValue(self:GetProperty("Equipment"), slot) then
			return
		end

		local existing = ply:GetEquipment(slot)

		if ply:WaitFor(existing and 4 or 2, "Equipping...", {self}) and self:CanEquip() then
			self:Equip(slot)
		end
	end

	function ITEM:TryUnequip(ply)
		if ply:WaitFor(2, "Unequipping...", {self}) and self:CanUnequip() then
			self:Unequip()
		end
	end
end
