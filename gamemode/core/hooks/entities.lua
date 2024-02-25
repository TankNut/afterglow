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
