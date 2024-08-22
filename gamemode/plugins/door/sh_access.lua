Door.AccessTypes = Door.AccessTypes or {}

function Door.AddAccessType(name, data)
	Door.AccessTypes[name] = {
		Title = data.Title or name,
		Callback = data.Callback or function(self, ply) return true end,
		Color = data.Color or color_white,
		OnSuccess = data.OnSuccess or function(self, ply) end,
		OnDenied = data.OnDenied or function(self, ply) end
	}
end

Door.AddAccessType("Default", {
	Color = Color(0, 255, 0)
})

function Door.GetAccessType(door)
	return Door.AccessTypes[door:GetDoorValue("Access")] or Door.AccessTypes.Default
end

function Door.CheckAccess(door, ply)
	return Door.GetAccessType(door).Callback(door, ply)
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

		if not ent:IsDoor() or ent:IsPropDoor() or not ent:GetDoorValue("Usable") then
			return
		end

		Door.TryUse(ent, ply)
	end)
end
