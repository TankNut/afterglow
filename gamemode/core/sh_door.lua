-- This library uses NW and not Netvar because of PVS issues, don't try to change it
DOOR_SEPARATE = 0
DOOR_MASTER = 1
DOOR_BOTH = 2

Door = Door or {}
Door.Types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

Door.All = Door.All or {}
Door.Vars = Door.Vars or {}

local entity = FindMetaTable("Entity")

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
	Saved = true,
	Edit = {
		title = "Group",
		type = "Generic",
		order = -1
	},
	Get = function(self) return self:GetNWString("DoorGroup", "") end,
	Set = function(self, value)
		self:SetNWString("DoorGroup", value)
	end,
})

function Door.Iterator()
	return pairs(Door.All)
end

function entity:GetDoorValue(key)
	local data = Door.Vars[key]

	if data.Mode == DOOR_SEPARATE then
		return data.Get(self)
	elseif data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
		return data.Get(self:GetMasterDoor())
	end
end

if SERVER then
	function entity:SetDoorValue(key, value)
		local data = Door.Vars[key]

		if data.Mode == DOOR_SEPARATE then
			data.Set(self, value)
		elseif data.Mode == DOOR_MASTER then
			data.Set(self:GetMasterDoor(), value)
		elseif data.Mode == DOOR_BOTH then
			data.Set(self, value)

			if self:GetOtherDoor() != self then
				data.Set(self:GetOtherDoor(), value)
			end
		end
	end

	function entity:GetDoorSaveValue(key)
		local data = Door.Vars[key]

		if not data.Saved then
			return
		end

		if data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
			self = self:GetMasterDoor()
		end

		return self.DoorValues[key] or self.InitialDoorValues[key]
	end

	function entity:SetDoorSaveValue(key, value)
		local data = Door.Vars[key]

		if not data.Saved then
			return
		end

		if data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
			self = self:GetMasterDoor()
		end

		self.DoorValues[key] = value

		Door.QueueSave()
	end

	function Door.QueueSave()
		timer.Create("DoorSave", 10, 1, function()
			Door.SaveData()
		end)
	end

	function Door.SaveData()
		timer.Remove("DoorSave")

		local data = {}

		for door in Door.Iterator() do
			local id = door:MapCreationID()

			if id != -1 then
				local doorData = {}

				for key, value in pairs(door.DoorValues) do
					if door.InitialDoorValues[key] == value then
						continue
					end

					doorData[key] = value
				end

				if not table.IsEmpty(doorData) then
					data[id] = doorData
				end
			end
		end

		Data.SetMapData("doors", data)
	end
end

function GM:EntityIsDoor(ent)
	return tobool(Door.Types[ent:GetClass()])
end

hook.Add("OnEntityCreated", "Door", function(ent)
	if hook.Run("EntityIsDoor", ent) then
		ent._IsDoor = true
		Door.All[ent] = ent:GetClass()

		if SERVER then
			timer.Simple(0, function()
				local owner = ent:GetOwner()

				if IsValid(owner) then
					owner:SetNWEntity("DoorChild", ent)
				end
			end)
		end
	end
end)

hook.Add("EntityRemoved", "Door", function(ent, fullUpdate)
	if fullUpdate then
		return
	end

	if Door.All[ent] then
		Door.All[ent] = nil
	end
end)

if SERVER then
	Door.IsOpenCallbacks = {
		["prop_door_rotating"] = function(self) return self:GetInternalVariable("m_eDoorState") != 0 end,
		["func_door_rotating"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end,
		["func_door"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end
	}

	-- Only semi-reliable way of doing this
	hook.Add("Think", "Door", function()
		for door, class in Door.Iterator() do
			local open = Door.IsOpenCallbacks[class](door)

			if door:GetDoorOpen() != open then
				door:SetNWBool("DoorOpen", open)
			end
		end
	end)

	hook.Add("AcceptInput", "Door", function(ent, name, activator, caller, value)
		if not ent:IsDoor() then
			return
		end

		name = name:lower()

		if name == "lock" or name == "unlock" then
			ent:SetNWBool("DoorLocked", name == "lock")
		elseif name == "use" and not ent:IsPropDoor() and not value then
			local group = ent:GetDoorValue("Group")

			if group != "" then
				-- Need to not do this
				for door in Door.Iterator() do
					if door != ent and door:GetDoorValue("Group") == group then
						-- Passing true here so we can detect it in the if statement and avoid an infinite server-crashing loop
						door:Fire("Use", true, 0, activator, caller)
					end
				end
			end
		end
	end)

	hook.Add("EntityKeyValue", "Door", function(ent, key, value)
		if not ent:IsDoor() then
			return
		end

		key = key:lower()

		if key == "spawnflags" then
			ent:SetNWBool("DoorLocked", bit.Check(value, 2048))
			ent:SetNWBool("DoorUsable", ent:IsPropDoor() or bit.Check(value, 256))
			ent:SetNWBool("DoorToggle", ent:IsPropDoor() and bit.Check(value, 8192) or bit.Check(value, 32))

			if not ent:IsPropDoor() then
				ent:SetNWBool("DoorTouchOpen", bit.Check(value, 1024))
			end
		elseif key == "returndelay" or key == "wait" then
			ent:SetNWFloat("DoorAutoClose", tonumber(value))
		elseif key == "speed" then
			ent:SetNWFloat("DoorSpeed", tonumber(value))
		elseif key == "dmg" then
			ent:SetNWFloat("DoorDamage", tonumber(value))
		elseif key == "forceclosed" then
			ent:SetNWBool("DoorForce", tobool(value))
		end
	end)

	hook.Add("InitPostEntity", "Door", coroutine.Bind(function()
		local mapData = Data.GetMapData("doors", {})

		for door in Door.Iterator() do
			local initial = {}
			local values = {}

			local id = door:MapCreationID()

			for key, data in pairs(Door.Vars) do
				if data.Saved then
					initial[key] = data.Get(door)
				end
			end

			if id != -1 and mapData[id] then
				for index, value in pairs(mapData[id]) do
					values[index] = value

					door:SetDoorValue(index, value)
				end
			end

			door.InitialDoorValues = initial
			door.DoorValues = values
		end
	end))
end

function entity:IsDoor() return tobool(self._IsDoor) end
function entity:IsPropDoor() return self:GetClass() == "prop_door_rotating" end

function entity:GetMasterDoor()
	if self:GetClass() == "prop_door_rotating" then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self
	else
		return self
	end
end

function entity:GetOtherDoor()
	if self:GetClass() == "prop_door_rotating" then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self:GetNWEntity("DoorChild", NULL)
	else
		return self
	end
end

function entity:GetDoorOpen() return self:GetNWBool("DoorOpen", false) end

if SERVER then
	local function wrap(ent, force, name, param, activator)
		if force and ent:GetDoorValue("Locked") then
			ent:SetDoorValue("Locked", false)
			ent:Fire(name, param, 0, activator)
			ent:SetDoorValue("Locked", true)
		else
			ent:GetMasterDoor():Fire(name, param, 0, activator)
		end
	end

	function entity:SetDoorOpen(bool, force, awayFrom) if bool then self:OpenDoor(force, awayFrom) else self:CloseDoor(force) end end
	function entity:OpenDoor(force, awayFrom) wrap(self, force, awayFrom and "openawayfrom" or "open", awayFrom and "!activator" or "", awayFrom) end
	function entity:CloseDoor(force) wrap(self, force, "close") end
	function entity:ToggleDoor(force) wrap(self, force, "toggle") end
end

hook.Add("GetEditModeOptions", "Door", function(ply, ent, interact)
	if ent:IsDoor() then
		Context.Add("edit_door", {
			Name = "Edit Door",
			Section = 1,
			Client = function()
				Interface.Open("DoorEdit", ent)
			end
		})
	end
end)

if SERVER then
	Netstream.Hook("SetDoorProperty", function(ply, payload)
		if not ply:GetEditMode() then
			return
		end

		local door = payload.Door

		if not IsValid(door) or not door:IsDoor() then
			return
		end

		local key = payload.Key
		local data = Door.Vars[key]

		if not data or not data.Edit then
			return
		end

		if data.NoProp and door:IsPropDoor() then
			return
		end

		local value = payload.Value

		door:SetDoorValue(key, value)

		if data.Saved then
			if isfunction(data.Saved) then
				data.Saved(door, value)
			else
				door:SetDoorSaveValue(key, value)
			end
		end
	end)
end
