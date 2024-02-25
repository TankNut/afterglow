function GM:SetupMove(ply, mv, cmd)
	if cmd:GetForwardMove() <= 0 then
		mv:SetMaxClientSpeed(math.min(Lerp(0.6, ply:GetWalkSpeed(), ply:GetRunSpeed()), mv:GetMaxClientSpeed()))
	end
end

function GM:GetPlayerColor(ply) return ply:GetCharacterFlagAttribute("PlayerColor") end

if SERVER then
	function GM:GetBaseArmor(ply) return ply:GetCharacterFlagAttribute("Armor") end
	function GM:GetPlayerTeam(ply) return ply:GetCharacterFlagAttribute("Team") end

	function GM:GetSlowWalkSpeed(ply) return ply:GetCharacterFlagAttribute("SlowWalkSpeed") end
	function GM:GetWalkSpeed(ply) return ply:GetCharacterFlagAttribute("WalkSpeed") end
	function GM:GetRunSpeed(ply) return ply:GetCharacterFlagAttribute("RunSpeed") end
	function GM:GetJumpPower(ply) return ply:GetCharacterFlagAttribute("JumpPower") end
	function GM:GetCrouchedWalkSpeed(ply) return ply:GetCharacterFlagAttribute("CrouchSpeed") end

	function GM:PlayerInitialSpawn(ply)
		ply:SetTeam(TEAM_UNASSIGNED)
		ply:SetUserGroup("user")

		-- We don't use source armor
		ply:SetMaxArmor(0)

		coroutine.wrap(function()
			PlayerVar.Load(ply)
			Character.LoadList(ply)
		end)()
	end

	function GM:PlayerSpawn(ply)
		ply:Freeze(not ply:HasCharacter())

		if not ply:HasCharacter() then
			ply:KillSilent()

			return
		end

		hook.Run("PlayerSetup", ply)
	end

	function GM:PlayerSetup(ply)
		local flag = ply:GetCharacterFlagTable()

		local healthFraction = ply:Health() / ply:GetMaxHealth()
		local health = flag:GetAttribute("Health")

		ply:UpdateTeam()
		ply:UpdateName()

		ply:SetMaxHealth(health)
		ply:SetHealth(math.ceil(healthFraction * health))

		ply:UpdateAppearance()
		ply:UpdateArmor()
		ply:UpdateSpeed()

		ply:SetBloodColor(flag:GetAttribute("BloodColor"))

		ply:StripWeapons()
		ply:RemoveAllAmmo()

		ply:Give("gmod_tool")
		ply:Give("gmod_camera")
		ply:Give("weapon_physgun")

		local weaponList = flag:GetAttribute("Weapons", ply)

		for _, class in pairs(weaponList) do
			ply:Give(class)
		end

		ply:SelectWeapon(weaponList[1] or "weapon_physgun")

		for _, item in pairs(ply:GetEquipment()) do
			item:OnSpawn()
		end

		flag:OnSpawn(ply)
	end
end
