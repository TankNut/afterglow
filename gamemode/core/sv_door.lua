Door.IsOpenCallbacks = {
	["prop_door_rotating"] = function(self) return self:GetInternalVariable("m_eDoorState") != 0 end,
	["func_door_rotating"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end,
	["func_door"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end
}

local entity = FindMetaTable("Entity")

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

function Door.QueueSave()
	timer.Create("DoorSave", 10, 1, function()
		Door.SaveData()
	end)
end

Door.LoadData = coroutine.Bind(function()
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

				if Door.Vars[index] then
					door:SetDoorValue(index, value)
				end
			end
		end

		door.InitialDoorValues = initial
		door.DoorValues = values
	end
end)

hook.Add("InitPostEntity", "Door", Door.LoadData)

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
