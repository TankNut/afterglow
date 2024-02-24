function ITEM:SaveData()
	if self:IsTempItem() then
		return
	end

	local query = mysql:Update("rp_items")
		query:Update("customdata", pack.Encode(self.CustomData))
		query:WhereEqual("id", self.ID)
	query:Execute()
end


function ITEM:SaveLocation()
	if self:IsTempItem() then
		return
	end

	local query = mysql:Update("rp_items")
		query:Update("storetype", self.StoreType)
		query:Update("storeid", self.StoreID)

	if self.StoreType == ITEM_WORLD then
		query:Update("worldmap", game.GetMap())
		query:Update("worldpos", pack.Encode({
			Pos = self.Entity:GetPos(),
			Ang = self.Entity:GetAngles(),
			Frozen = not self.Entity:GetPhysicsObject():IsMotionEnabled()
		}))
	else
		query:Update("worldmap", "")
		query:Update("worldpos", pack.Default)
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
