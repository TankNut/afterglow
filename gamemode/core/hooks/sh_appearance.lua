if SERVER then
	function GM:GetAppearance(ply, data)
	end

	function GM:PostSetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		appearance.Apply(ent, ply.HandsAppearance or {
			Model = Model("models/weapons/c_arms_hev.mdl")
		})
	end
end

netvar.AddEntityHook("Appearance", "Appearance", function(ply, _, _, data)
	if not ply:IsPlayer() then
		return
	end

	appearance.Apply(ply, data)
end)
