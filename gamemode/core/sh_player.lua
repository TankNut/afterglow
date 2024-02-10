function GM:SetupMove(ply, mv, cmd)
	if cmd:GetForwardMove() <= 0 then
		mv:SetMaxClientSpeed(math.min(Lerp(0.6, ply:GetWalkSpeed(), ply:GetRunSpeed()), mv:GetMaxClientSpeed()))
	end
end

if CLIENT then
	function GM:CreateClientsideRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end
else
	function GM:CreateEntityRagdoll(ent, ragdoll)
		Appearance.Copy(ent, ragdoll)
	end
end
