function ITEM:SaveData()
	if self:IsTempItem() then
		return
	end

	local query = mysql:Update("rp_items")
		query:Update("custom_data", pack.Encode(self.CustomData))
		query:WhereEqual("id", self.ID)
	query:Execute()
end

function ITEM:SaveLocation()
	if self:IsTempItem() then
		return
	end

	local query = mysql:Update("rp_items")
		query:Update("store_type", self.StoreType)
		query:Update("store_id", self.StoreID)

	if self.StoreType == ITEM_WORLD then
		query:Update("world_map", game.GetMap())
		query:Update("world_position", pack.Encode({
			Pos = self.Entity:GetPos(),
			Ang = self.Entity:GetAngles(),
			Frozen = not self.Entity:GetPhysicsObject():IsMotionEnabled()
		}))
	else
		query:Update("world_map", "")
		query:Update("world_position", pack.Default)
	end

	query:WhereEqual("id", self.ID)
	query:Execute()
end

function ITEM:Destroy()
	self:SetInventory(nil, true)

	local query = mysql:Delete("rp_items")
		query:WhereEqual("id", self.ID)
	query:Execute()
end
