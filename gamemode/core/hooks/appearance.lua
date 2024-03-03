function GM:PostSetAppearance(ent)
end

if SERVER then
	function GM:GetCharacterAppearance(ply, data)
		ply:GetCharacterFlagTable():GetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end
