local entity = FindMetaTable("Entity")

function entity:GetDoorValue(key)
	local data = Doors.Vars[key]

	if data.Mode == DOOR_SEPARATE then
		return data.Get(self)
	elseif data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
		return data.Get(self:GetMasterDoor())
	end
end

if SERVER then
	function entity:SetDoorValue(key, value)
		local data = Doors.Vars[key]

		if data.Mode == DOOR_SEPARATE then
			data.Set(self, value)
		elseif data.Mode == DOOR_MASTER then
			data.Set(self:GetMasterDoor(), value)
		elseif data.Mode == DOOR_BOTH then
			data.Set(self, value)

			local other = self:GetOtherDoor()

			if IsValid(other) and other != self then
				data.Set(other, value)
			end
		end
	end

	function entity:GetDoorSaveValue(key)
		local data = Doors.Vars[key]

		if not data.Saved then
			return
		end

		if data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
			self = self:GetMasterDoor()
		end

		return self.DoorValues[key] or self.InitialDoorValues[key]
	end

	function entity:SetDoorSaveValue(key, value)
		local data = Doors.Vars[key]

		if not data.Saved then
			return
		end

		if data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
			self = self:GetMasterDoor()
		end

		self.DoorValues[key] = value

		Doors.QueueSave()
	end
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
