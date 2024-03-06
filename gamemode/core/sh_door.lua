-- This library uses NW and not NetVar because of PVS issues, don't try to change it
module("Door", package.seeall)

local entity = FindMetaTable("Entity")

Types = Types or table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

All = All or {}
Groups = Groups or {}

function AddFunction(name, callback)
	entity[name] = function(self, ...)
		assert(self:IsDoor(), name .. " called on non-door entity")

		return callback(self, ...)
	end
end

function Iterator()
	return pairs(All)
end

hook.Add("OnEntityCreated", "Door", function(ent)
	if hook.Run("EntityIsDoor", ent) then
		ent._Door = true
		All[ent] = ent:GetClass()

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

	if All[ent] then
		All[ent] = nil
	end
end)

if SERVER then
	IsOpenCallbacks = {
		["prop_door_rotating"] = function(self) return self:GetInternalVariable("m_eDoorState") != 0 end,
		["func_door_rotating"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end,
		["func_door"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end
	}

	-- Only semi-reliable way of doing this
	hook.Add("Think", "Door", function()
		for door, class in Iterator() do
			local open = IsOpenCallbacks[class](door)

			if door:IsDoorOpen() != open then
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
			if not ent._DoorSetup then
				ent:SetNWBool("DoorLocked", bit.Check(value, 2048))
				ent._DoorSetup = true
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
		elseif key == "forceclose" then
			ent:SetNWBool("DoorForce", tobool(value))
		end
	end)
end

function entity:IsDoor()
	return tobool(self._Door)
end

AddFunction("IsPropDoor", function(self) return self:GetClass() == "prop_door_rotating" end)

AddFunction("GetMasterDoor", function(self)
	if self:GetClass() == "prop_door_rotating" then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self
	else
		return self
	end
end)

AddFunction("GetOtherDoor", function(self)
	if self:GetClass() == "prop_door_rotating" then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self:GetNWEntity("DoorChild", NULL)
	else
		return self
	end
end)

AddFunction("IsDoorOpen", function(self) return self:GetNWBool("DoorOpen", false) end)
AddFunction("IsDoorLocked", function(self) return self:GetMasterDoor():GetNWBool("DoorLocked", false) end)
AddFunction("IsDoorUsable", function(self) return self:GetMasterDoor():GetNWBool("DoorUsable", false) end)
AddFunction("IsDoorToggled", function(self) return self:GetMasterDoor():GetNWBool("DoorToggle", false) end)
AddFunction("IsDoorOpenable", function(self) return self:IsDoorUsable() and not self:IsDoorLocked() end)

AddFunction("GetDoorAutoClose", function(self) return self:GetMasterDoor():GetNWFloat("DoorAutoClose", -1) end)

if SERVER then
	local function wrap(ent, force, name, param, activator)
		if force and ent:IsDoorLocked() then
			ent:UnlockDoor()
			ent:GetMasterDoor():Fire(name, param, 0, activator)
			ent:LockDoor()
		else
			ent:GetMasterDoor():Fire(name, param, 0, activator)
		end
	end

	AddFunction("SetDoorOpen", function(self, bool, force, awayFrom) if bool then self:OpenDoor(force, awayFrom) else self:CloseDoor(force) end end)
	AddFunction("OpenDoor", function(self, force, awayFrom) wrap(self, force, "open", awayFrom and "!activator" or "", awayFrom) end)
	AddFunction("CloseDoor", function(self, force) wrap(self, force, "close") end)
	AddFunction("ToggleDoor", function(self, force) wrap(self, force, "toggle") end)

	AddFunction("SetDoorLock", function(self, bool) if bool then self:LockDoor() else self:UnlockDoor() end end)
	AddFunction("LockDoor", function(self) self:GetMasterDoor():Fire("lock") end)
	AddFunction("UnlockDoor", function(self) self:GetMasterDoor():Fire("unlock") end)
	AddFunction("ToggleDoorLock", function(self) if self:IsDoorLocked() then self:UnlockDoor() else self:LockDoor() end end)

	AddFunction("SetDoorUsable", function(self, bool)
		assert(not self:IsPropDoor(), "prop_door_rotating cannot have it's usable state changed")

		if self:IsDoorUsable() == bool then
			return
		end

		if bool then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 256))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 256))
		end
	end)

	AddFunction("SetDoorToggled", function(self, bool)
		assert(not self:IsPropDoor(), "prop_door_rotating cannot have it's toggle state changed")

		if self:IsDoorToggled() == bool then
			return
		end

		if bool then
			self:SetKeyValue("spawnflags", bit.SetFlag(self:GetSpawnFlags(), 32))
		else
			self:SetKeyValue("spawnflags", bit.UnsetFlag(self:GetSpawnFlags(), 32))
		end
	end)

	AddFunction("SetDoorAutoClose", function(self, time)
		if not time then
			time = -1
		end

		if self:IsPropDoor() then
			local door = self:GetMasterDoor()

			door:SetKeyValue("returndelay", time)
			door:SetNWFloat("DoorSpeed", time)
		else
			self:SetKeyValue("wait", time)
			self:SetNWFloat("DoorSpeed", time)
		end
	end)
end