function GM:PostSetAppearance(ent)
end

if CLIENT then
	function GM:CreateClientsideRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end
else
	function GM:CreateEntityRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end

	function GM:GetCharacterAppearance(ply, data)
		ply:GetCharacterFlagTable():GetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end
