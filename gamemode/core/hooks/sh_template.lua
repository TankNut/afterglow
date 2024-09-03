function GM:CanAccessTemplate(ply, id)
	return ply:IsSuperAdmin() or ply:GetTemplates()[id]
end
