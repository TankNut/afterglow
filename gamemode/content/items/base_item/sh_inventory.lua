function ITEM:GetInventory()
	return Inventory.Get(self.InventoryID)
end

function ITEM:SetInventory(inventory, loaded)
	if IsValid(self.Entity) then
		self.Entity.Item = nil
		self.Entity:Remove()
	end

	local old = self:GetInventory()

	if old then
		if self:IsEquipped() then
			self:Unequip()
		end

		old:RemoveItem(self)
	end

	if inventory then
		inventory:AddItem(self)

		if self:IsEquipped() then
			hook.Run("ItemEquipped", self.Player, self, loaded)
		end
	end

	if SERVER then
		if old then
			netstream.Send("ItemRemove", inventory and inventory:DiffReceivers(old) or old:GetReceivers(), self.ID)
		end

		if inventory then
			netstream.Send("ItemAdd", inventory:GetReceivers(), {Inventory = inventory.ID, Name = self.ClassName, ID = self.ID, Data = self.CustomData})
		end

		if inventory and not loaded then
			self:SaveLocation()
		end
	end
end

function ITEM:GetAppearance()
	return {
		Model = self:GetProperty("Model"),
		Skin = self:GetProperty("Skin"),
		Bodygroups = self:GetProperty("Bodygroups")
	}
end

if SERVER then
	function ITEM:SetWorldPos(pos, ang, loaded)
		if not loaded then
			-- Setting loaded to true here regardless so we don't try to SaveLocation right before doing it again in here
			self:SetInventory(nil, true)
		end

		self.StoreType = ITEM_WORLD
		self.StoreID = 0

		local ent = self.Entity

		if not IsValid(self.Entity) then
			self.Entity = ents.Create("ent_item")

			ent = self.Entity
			ent.Item = self

			Appearance.Apply(self.Entity, self:GetAppearance())

			ent:SetRenderMode(RENDERMODE_TRANSALPHA)

			ent:Spawn()
			ent:Activate()
		end

		ent:SetPos(pos)
		ent:SetAngles(ang)

		if not loaded then
			self:SaveLocation()
		end

		return ent
	end
end
