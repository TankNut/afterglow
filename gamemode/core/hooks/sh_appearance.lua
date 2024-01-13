if SERVER then
	function GM:GetAppearance(ply, data)
	end

	function GM:PostSetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance or {
			Model = Model("models/weapons/c_arms_hev.mdl")
		})
	end
end

netvar.AddEntityHook("Appearance", "Appearance", function(ply, _, _, appearance)
	if not ply:IsPlayer() then
		return
	end

	Appearance.Apply(ply, appearance)
end)
