function GM:GetPlayerColor(ply) return ply:GetCharacterFlagAttribute("PlayerColor") end

if SERVER then
	function GM:GetBaseArmor(ply) return ply:GetCharacterFlagAttribute("Armor") end
	function GM:GetPlayerTeam(ply) return ply:GetCharacterFlagAttribute("Team") end

	function GM:GetSlowWalkSpeed(ply) return ply:GetCharacterFlagAttribute("SlowWalkSpeed") end
	function GM:GetWalkSpeed(ply) return ply:GetCharacterFlagAttribute("WalkSpeed") end
	function GM:GetRunSpeed(ply) return ply:GetCharacterFlagAttribute("RunSpeed") end
	function GM:GetJumpPower(ply) return ply:GetCharacterFlagAttribute("JumpPower") end
	function GM:GetCrouchedWalkSpeed(ply) return ply:GetCharacterFlagAttribute("CrouchSpeed") end
end