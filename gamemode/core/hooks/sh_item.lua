function GM:GetItemDropLocation(ply)
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 50,
		filter = ply,
		collisiongroup = COLLISION_GROUP_WEAPON
	})

	local ang = ply:GetAngles()

	ang.p = 0

	return tr.HitPos + tr.HitNormal * 10, ang
end

function GM:ItemEquipped(ply, item, loaded)
	item:FireEvent("EquipmentChanged")

	if SERVER and not loaded then
		ply:UpdateAttributes()
	end
end

function GM:ItemUnequipped(ply, item)
	item:FireEvent("EquipmentChanged")

	if SERVER then
		ply:UpdateAttributes()
	end
end
