function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_UNASSIGNED)
	ply:SetUserGroup("user")

	-- We don't use source armor
	ply:SetMaxArmor(0)

	coroutine.wrap(function()
		PlayerVars.Load(ply)
		Character.LoadList(ply)
	end)()
end

function GM:PlayerSpawn(ply)
	ply:Freeze(not ply:HasCharacter())

	local health = ply:GetCharacterFlagAttribute("Health")

	ply:SetMaxHealth(health)
	ply:SetHealth(health)

	ply:UpdateAppearance()
	ply:UpdateArmor()

	if not ply:HasCharacter() then
		ply:KillSilent()

		return
	end

	ply:StripWeapons()
	ply:RemoveAllAmmo()

	ply:Give("gmod_tool")
	ply:Give("gmod_camera")
	ply:Give("weapon_physgun")

	local flag = ply:GetCharacterFlagTable()
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

function GM:PlayerDisconnected(ply)
	Inventory.Remove(ply:GetNetVar("InventoryID"))
end
