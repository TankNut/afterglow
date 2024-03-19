local entity = FindMetaTable("Entity")

function entity:WithinRange(ent, range)
	local origin = ent:IsPlayer() and ent:EyePos() or ent:WorldSpaceCenter()
	local distance = self:NearestPoint(origin):DistToSqr(origin)

	return distance <= range * range
end
