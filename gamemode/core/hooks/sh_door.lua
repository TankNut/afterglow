function GM:EntityIsDoor(ent)
	return tobool(Door.Types[ent:GetClass()])
end

function GM:GetDoorPrice(door)
	return Config.Get("UseMoney") and Config.Get("DoorPrice") or 0
end
