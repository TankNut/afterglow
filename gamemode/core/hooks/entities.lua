function GM:EntityIsDoor(ent)
	return tobool(Door.Types[ent:GetClass()])
end

if CLIENT then
	function GM:CreateClientsideRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end
end

if SERVER then
	function GM:CreateEntityRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end
end
