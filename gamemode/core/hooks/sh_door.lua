function GM:EntityIsDoor(ent)
	return tobool(Door.Types[ent:GetClass()])
end
