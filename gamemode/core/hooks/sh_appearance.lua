if SERVER then
	function GM:GetAppearance(ply, data)
		ply:GetCharacterFlagTable():GetAppearance(ply, data)
	end

	function GM:PostSetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end

netvar.AddEntityHook("Appearance", "Appearance", function(ent, _, appearance)
	Appearance.Apply(ent, appearance)
end)
