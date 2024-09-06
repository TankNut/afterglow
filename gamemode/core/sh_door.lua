-- Doors use NW and not Netvar because of PVS issues, don't try to change it
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
Door.AccessTypes = Door.AccessTypes or {}

local entity = FindMetaTable("Entity")

function Door.Iterator()
	return pairs(Door.All)
end

function Door.AddAccessType(name, data)
	Door.AccessTypes[name] = {
		Title = data.Title or name,
		Callback = data.Callback or function(self, ply) return true end,
		Color = data.Color or color_white,
		OnSuccess = data.OnSuccess or function(self, ply) end,
		OnDenied = data.OnDenied or function(self, ply) end,
		DoorTitle = data.DoorTitle,
		DoorSubtitle = data.DoorSubtitle
	}
end

Door.AddAccessType("Default", {
	Color = Color(0, 255, 0)
})

Door.AddAccessType("Buyable", {
	Color = Color(255, 255, 100),
	DoorSubtitle = function(self, door)
		if door:GetDoorValue("Title") == "" then
			return ""
		end

		return "This door is owned"
	end
})

function Door.GetAccessType(door)
	return Door.AccessTypes[door:GetDoorValue("Access")] or Door.AccessTypes.Default
end

function Door.CheckAccess(door, ply)
	return Door.GetAccessType(door).Callback(door, ply)
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

function entity:GetDoorValue(key)
	local data = Door.Vars[key]

	if data.Mode == DOOR_SEPARATE then
		return data.Get(self)
	elseif data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH then
		return data.Get(self:GetMasterDoor())
	end
end

if SERVER then
	function Door.TryUse(door, ply)
		local accessType = Door.GetAccessType(door)

		if accessType.Callback(door, ply) then
			local override = accessType.OnSuccess(door, ply)

			if not override then
				ply:Use(door)
			end
		else
			accessType.OnDenied(door, ply)
		end
	end

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

	function entity:SetDoorValue(key, value)
		local data = Door.Vars[key]

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

	hook.Add("PlayerUse", "Plugin.Door", function(ply, ent)
		if ent:IsDoor() and not ent:IsPropDoor() then
			return false
		end
	end)

	hook.Add("KeyPress", "Plugin.Door", function(ply, key)
		if key != IN_USE then
			return
		end

		local ent = hook.Run("FindUseEntity", ply)

		if not IsValid(ent) or not ent:IsDoor() or ent:IsPropDoor() or not ent:GetDoorValue("Usable") then
			return
		end

		Door.TryUse(ent, ply)
	end)
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
