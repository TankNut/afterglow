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
		old:RemoveItem(self)
	end

	if inventory then
		inventory:AddItem(self)
	end

	if SERVER then
		if old then
			netstream.Send(inventory and inventory:DiffReceivers(old) or old:GetReceivers(), "ItemRemove", self.ID)
		end

		if inventory then
			netstream.Send(inventory:GetReceivers(), "ItemAdd", {Inventory = inventory.ID, Name = self.ClassName, ID = self.ID, Data = self.CustomData})
		end

		if inventory and not loaded then
			self:SaveLocation()
		end
	end
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

			ent:SetModel(self.Model)
			ent:SetSkin(self.Skin)

			for _, v in pairs(ent:GetBodyGroups()) do
				if v.num <= 1 or not self.Bodygroups[v.name] then
					continue
				end

				ent:SetBodygroup(v.id, self.Bodygroups[v.name])
			end

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
