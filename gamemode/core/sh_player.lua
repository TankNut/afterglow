local meta = FindMetaTable("Player")

function meta:GetPlayerColor()
	return hook.Run("GetPlayerColor", self)
end

if SERVER then
	function meta:UpdateSpeed()
		self:SetSlowWalkSpeed(hook.Run("GetSlowWalkSpeed", self))
		self:SetWalkSpeed(hook.Run("GetWalkSpeed", self))
		self:SetRunSpeed(hook.Run("GetRunSpeed", self))
		self:SetJumpPower(hook.Run("GetJumpPower", self))
		self:SetCrouchedWalkSpeed(hook.Run("GetCrouchedWalkSpeed", self))
	end
end

function meta:CanInteract(ent)
	return hook.Run("CanInteract", self, ent)
end

if CLIENT then
	function GM:SelectDefaultWeapon(ply)
		return ply:GetCharacterFlagAttribute("Weapons")[1] or "weapon_physgun"
	end

	Netstream.Hook("PostPlayerSpawn", function()
		hook.Run("PostPlayerSpawn", LocalPlayer())
	end)

	Netstream.Hook("SelectDefaultWeapon", function()
		local ply = LocalPlayer()
		local weapon = ply:GetWeapon(hook.Run("SelectDefaultWeapon", ply))

		if IsValid(weapon) then
			input.SelectWeapon(weapon)
		end
	end)
end
