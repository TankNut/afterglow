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
