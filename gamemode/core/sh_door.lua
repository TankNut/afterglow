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
		assert(self:IsDoor(), "Door function called on non-door entity")

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
end

function entity:IsDoor()
	return tobool(self._Door)
end

AddFunction("IsDoorOpen", function(self)
	return self:GetNWBool("DoorOpen", false)
end)

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

if SERVER then
	AddFunction("OpenDoor", function(self, awayFrom)
		local door = self:GetMasterDoor()

		if door:GetClass() == "prop_door_rotating" and awayFrom then
			door:Fire("OpenAwayFrom", "!activator", 0, awayFrom)
		else
			door:Fire("Open")
		end
	end)

	AddFunction("CloseDoor", function(self)
		self:GetMasterDoor():Fire("Close")
	end)

	AddFunction("LockDoor", function(self)
		self:GetMasterDoor():Fire("lock")
	end)

	AddFunction("UnlockDoor", function(self)
		self:GetMasterDoor():Fire("unlock")
	end)
end
