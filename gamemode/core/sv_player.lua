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

	ply:SetSlowWalkSpeed(flag:GetAttribute("SlowWalkSpeed"))
	ply:SetWalkSpeed(flag:GetAttribute("WalkSpeed"))
	ply:SetRunSpeed(flag:GetAttribute("RunSpeed"))
	ply:SetJumpPower(flag:GetAttribute("JumpPower"))
	ply:SetCrouchedWalkSpeed(flag:GetAttribute("CrouchSpeed"))

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
