-- This library uses NW and not Netvar because of PVS issues, don't try to change it
Door = Door or {}
Door.Types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

Door.All = Door.All or {}
Door.Vars = Door.Vars or {}

local entity = FindMetaTable("Entity")

function Door.AddSaveVar(name, get, set)
	Door.Vars[name] = {
		Get = get,
		Set = set
	}
end

function Door.Iterator()
	return pairs(Door.All)
end

if SERVER then
	function Door.QueueSave()
		if not Door.Initialized then
			return
		end

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

	function GM:EntityIsDoor(ent)
		return tobool(Door.Types[ent:GetClass()])
	end
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

	hook.Add("AcceptInput", "Door", function(ent, name)
		if not ent:IsDoor() then
			return
		end

		name = name:lower()

		if name == "lock" or name == "unlock" then
			ent:SetNWBool("DoorLocked", name == "lock")
		end
	end)

	hook.Add("EntityKeyValue", "Door", function(ent, key, value)
		if not ent:IsDoor() then
			return
		end

		key = key:lower()

		if key == "spawnflags" then
			if not Initialized then
				ent:SetNWBool("DoorLocked", bit.Check(value, 2048))
			end

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
		Initialized = true

		local data = Data.GetMapData("doors", {})

		for door in Door.Iterator() do
			local initial = {}
			local values = {}

			local id = door:MapCreationID()

			for key, callbacks in pairs(Door.Vars) do
				initial[key] = callbacks.Get(door)
			end

			if id != -1 and data[id] then
				for index, value in pairs(data[id]) do
					values[index] = value
					Door.Vars[index].Set(door, value)
				end
			end

			door.InitialDoorValues = initial
			door.DoorValues = values
		end
	end))
end

function entity:IsDoor() return tobool(self._IsDoor) end
function entity:IsPropDoor() return self:GetClass() == "prop_door_rotating" end
function entity:IsMasterDoor() return not IsValid(self:GetOwner()) end

if SERVER then
	function entity:GetInitialDoorValue(key)
		return self.InitialDoorValues[key]
	end

	function entity:ResetDoorValues(save)
		for key, value in pairs(self.InitialDoorValues) do
			Door.Vars[key].Set(self, value)
		end

		if save then
			table.Empty(self.DoorValues)

			Door.QueueSave()
		end
	end

	function entity:ResetDoorSaveValue(key)
		self:SetDoorSaveValue(key, self:GetInitialDoorValue(key))
	end

	function entity:SetDoorSaveValue(key, value)
		if not self:CreatedByMap() then
			return
		end

		local ent = self:GetMasterDoor()

		Door.Vars[key].Set(ent, value)

		if value == self:GetInitialDoorValue(key) then
			ent.DoorValues[key] = nil
		else
			ent.DoorValues[key] = value
		end

		Door.QueueSave()
	end
end

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
function entity:GetDoorLocked() return self:GetMasterDoor():GetNWBool("DoorLocked", false) end
function entity:GetDoorUsable() return self:GetMasterDoor():GetNWBool("DoorUsable", false) end
function entity:GetDoorToggled() return self:GetMasterDoor():GetNWBool("DoorToggle", false) end
function entity:GetDoorOpenable() return self:GetDoorUsable() and not self:GetDoorLocked() end

function entity:GetDoorAutoClose() return self:GetMasterDoor():GetNWFloat("DoorAutoClose", -1) end
function entity:GetDoorSpeed() return self:GetNWFloat("DoorSpeed", 0) end
function entity:GetDoorDamage() return self:GetNWFloat("DoorDamage", 0) end
function entity:GetDoorForceMove() return self:GetNWBool("DoorForce", false) end

if SERVER then
	local function wrap(ent, force, name, param, activator)
		if force and ent:GetDoorLocked() then
			ent:UnlockDoor()
			ent:GetMasterDoor():Fire(name, param, 0, activator)
			ent:LockDoor()
		else
			ent:GetMasterDoor():Fire(name, param, 0, activator)
		end
	end

	function entity:SetDoorOpen(bool, force, awayFrom) if bool then self:OpenDoor(force, awayFrom) else self:CloseDoor(force) end end
	function entity:OpenDoor(force, awayFrom) wrap(self, force, "open", awayFrom and "!activator" or "", awayFrom) end
	function entity:CloseDoor(force) wrap(self, force, "close") end
	function entity:ToggleDoor(force) wrap(self, force, "toggle") end

	function entity:SetDoorLocked(bool) if bool then self:LockDoor() else self:UnlockDoor() end end
	function entity:LockDoor() self:GetMasterDoor():Fire("lock") end
	function entity:UnlockDoor() self:GetMasterDoor():Fire("unlock") end
	function entity:ToggleDoorLock() self:SetDoorLocked(not self:GetDoorLocked()) end

	function entity:SetDoorUsable(bool)
		if self:IsPropDoor() then
			return
		end

		if bool then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 256))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 256))
		end
	end

	function entity:SetDoorToggled(bool)
		if self:IsPropDoor() then
			return
		end

		if bool then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 32))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 32))
		end
	end

	function entity:SetDoorAutoClose(time)
		if not time then
			time = -1
		end

		if self:IsPropDoor() then
			local door = self:GetMasterDoor()

			door:SetKeyValue("returndelay", time)
			door:SetNWFloat("DoorAutoClose", time)
		else
			self:SetKeyValue("wait", time)
			self:SetNWFloat("DoorAutoClose", time)
		end
	end

	function entity:SetDoorSpeed(speed)
		self:SetKeyValue("speed", speed)
		self:SetNWFloat("DoorSpeed", speed)

		if self:IsPropDoor() then
			local other = self:GetOtherDoor()

			if IsValid(other) then
				other:SetKeyValue("speed", speed)
				other:SetNWFloat("DoorSpeed", speed)
			end
		end
	end

	function entity:SetDoorDamage(damage)
		self:SetKeyValue("dmg", damage)
		self:SetNWFloat("DoorDamage", damage)

		if self:IsPropDoor() then
			local other = self:GetOtherDoor()

			if IsValid(other) then
				other:SetKeyValue("dmg", damage)
				other:SetNWFloat("DoorDamage", damage)
			end
		end
	end

	function entity:SetDoorForceMove(bool)
		self:SetKeyValue("forceclosed", bool and 1 or 0)
		self:SetNWBool("DoorForce", bool)

		if self:IsPropDoor() then
			local other = self:GetOtherDoor()

			if IsValid(other) then
				other:SetKeyValue("forceclosed", bool and 1 or 0)
				other:SetNWBool("DoorForce", bool)
			end
		end
	end
end

Door.AddSaveVar("Locked", entity.GetDoorLocked, entity.SetDoorLocked)
Door.AddSaveVar("Usable", entity.GetDoorUsable, entity.SetDoorUsable)

Door.AddSaveVar("Toggled", entity.GetDoorToggled, entity.SetDoorToggled)
Door.AddSaveVar("AutoClose", entity.GetDoorAutoClose, entity.SetDoorAutoClose)
Door.AddSaveVar("Speed", entity.GetDoorSpeed, entity.SetDoorSpeed)
Door.AddSaveVar("Damage", entity.GetDoorDamage, entity.SetDoorDamage)
Door.AddSaveVar("ForceMove", entity.GetDoorForceMove, entity.SetDoorForceMove)
