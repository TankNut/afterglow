local meta = FindMetaTable("Entity")

function meta:WithinRange(ent, range)
	local origin = ent:IsPlayer() and ent:EyePos() or ent:WorldSpaceCenter()
	local distance = self:NearestPoint(origin):DistToSqr(origin)

	return distance <= range * range
end
