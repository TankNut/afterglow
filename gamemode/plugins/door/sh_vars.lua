function Door.AddVar(name, data)
	Door.Vars[name] = {
		Mode = data.Mode or DOOR_SEPARATE,
		NoProp = data.NoProp,
		Saved = data.Saved,
		Order = data.Edit and data.Edit.order or 0,
		Edit = data.Edit,
		Get = data.Get,
		Set = data.Set
	}
end

Door.AddVar("Locked", {
	Mode = DOOR_MASTER,
	Get = function(self) return self:GetNWBool("DoorLocked", false) end,
	Set = function(self, value) self:Fire(tobool(value) and "lock" or "unlock") end
})

Door.AddVar("Usable", {
	NoProp = true,
	Saved = true,
	Edit = {
		title = "+Use Opens",
		type = "Boolean",
		order = 0
	},
	Get = function(self) return self:GetNWBool("DoorUsable", false) end,
	Set = function(self, value)
		value = tobool(value)

		if value then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 256))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 256))
		end

		self:SetNWBool("DoorUsable", value)
	end
})

Door.AddVar("Touchable", {
	NoProp = true,
	Saved = true,
	Edit = {
		title = "Touch Opens",
		type = "Boolean",
		order = 1
	},
	Get = function(self) return self:GetNWBool("DoorTouchOpen", false) end,
	Set = function(self, value)
		value = tobool(value)

		if value then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 1024))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 1024))
		end

		self:SetNWBool("DoorTouchOpen", value)
	end
})

Door.AddVar("Toggle", {
	NoProp = true,
	Saved = true,
	Edit = {
		title = "Toggle Open",
		type = "Boolean",
		order = 2
	},
	Get = function(self) return self:GetNWBool("DoorToggle", false) end,
	Set = function(self, value)
		value = tobool(value)

		if value then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 32))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 32))
		end

		self:SetNWBool("DoorToggle", value)
	end
})

Door.AddVar("AutoCloseToggle", {
	Mode = DOOR_BOTH,
	Saved = function(self, value)
		self:SetDoorSaveValue("AutoClose", self:GetNWFloat("DoorAutoClose", -1))
	end,
	Edit = {
		title = "Auto Close",
		type = "Boolean",
		order = 3
	},
	Get = function(self) return self:GetNWFloat("DoorAutoClose", -1) != -1 end,
	Set = function(self, value)
		value = tobool(value) and 1 or -1

		self:SetNWFloat("DoorAutoClose", value)

		if self:IsPropDoor() then
			self:SetKeyValue("returndelay", value)
		else
			self:SetKeyValue("wait", value)
		end
	end
})

Door.AddVar("AutoClose", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Close Timer",
		type = "Float",
		min = 1,
		max = 60,
		order = 4
	},
	Get = function(self) return self:GetNWFloat("DoorAutoClose", -1) end,
	Set = function(self, value)
		if self:GetNWFloat("DoorAutoClose", -1) != -1 then
			self:SetNWFloat("DoorAutoClose", value)

			if self:IsPropDoor() then
				self:SetKeyValue("returndelay", value)
			else
				self:SetKeyValue("wait", value)
			end
		end
	end
})

Door.AddVar("Speed", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Speed",
		type = "Float",
		min = 1,
		max = 500,
		order = 5
	},
	Get = function(self) return self:GetNWFloat("DoorSpeed", 0) end,
	Set = function(self, value)
		self:SetKeyValue("speed", value)
		self:SetNWFloat("DoorSpeed", value)
	end
})

Door.AddVar("ForceClose", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Force Closed",
		type = "Boolean",
		order = 6
	},
	Get = function(self) return self:GetNWFloat("DoorForce", false) end,
	Set = function(self, value)
		value = tobool(value)

		self:SetKeyValue("forceclosed", value and 1 or 0)
		self:SetNWBool("DoorForce", value)
	end
})

Door.AddVar("Damage", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Damage per Frame",
		type = "Float",
		min = 0,
		max = 200,
		order = 7
	},
	Get = function(self) return self:GetNWFloat("DoorDamage", 0) end,
	Set = function(self, value)
		self:SetKeyValue("dmg", value)
		self:SetNWFloat("DoorDamage", value)
	end
})

Door.AddVar("Group", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Group",
		type = "Generic",
		order = -1
	},
	Get = function(self) return self:GetNWString("DoorGroup", "") end,
	Set = function(self, value)
		self:SetNWString("DoorGroup", value:Trim())
	end,
})

Door.AddVar("Buyable", {
	Saved = true,
	Edit = {
		title = "Buyable",
		type = "Boolean",
		category = "Ownership",
		order = 0,
	},
	Get = function(self) return self:GetNWBool("DoorBuyable", false) end,
	Set = function(self, value)
		self:SetNWBool("DoorBuyable", tobool(value))
	end,
})

Door.AddVar("BuyGroup", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Group",
		type = "Generic",
		category = "Ownership",
		order = 1,
	},
	Get = function(self) return self:GetNWString("DoorBuyGroup", "") end,
	Set = function(self, value)
		self:SetNWBool("DoorBuyGroup", value:Trim())
	end,
})

Door.AddVar("BuyPrice", {
	Mode = DOOR_BOTH,
	Saved = true,
	Edit = {
		title = "Price",
		type = "Int",
		category = "Ownership",
		min = 0,
		max = 100,
		order = 2,
	},
	Get = function(self) return self:GetNWInt("DoorBuyPrice", 0) end,
	Set = function(self, value)
		self:SetNWInt("DoorBuyPrice", value)
	end,
})
