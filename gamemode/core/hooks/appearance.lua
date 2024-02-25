function GM:PostSetAppearance(ent)
	if ent:IsPlayer() then
		ent:RefreshHull()
	end
end

if SERVER then
	function GM:GetAppearance(ply, data)
		ply:GetCharacterFlagTable():GetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end
