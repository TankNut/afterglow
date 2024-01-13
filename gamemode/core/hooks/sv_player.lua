function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_UNASSIGNED)
	ply:SetUserGroup("user")

	player.LoadVars(ply)
end

function GM:PlayerSpawn(ply)
	ply:Freeze(not ply:HasCharacter())
	ply:UpdateAppearance()

	if not ply:HasCharacter() then
		-- Should only happen during initial spawn
		ply:KillSilent()

		return
	end

	hook.Run("PlayerLoadout", ply)
end

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:RemoveAllAmmo()

	if not ply:HasCharacter() then
		return
	end

	ply:GiveAmmo(256, "Pistol", true)
	ply:GiveAmmo(256, "SMG1", true)
	ply:GiveAmmo(5, "grenade", true)
	ply:GiveAmmo(64, "Buckshot", true)
	ply:GiveAmmo(32, "357", true)
	ply:GiveAmmo(32, "XBowBolt", true)
	ply:GiveAmmo(6, "AR2AltFire", true)
	ply:GiveAmmo(100, "AR2", true)

	ply:Give("weapon_crowbar")
	ply:Give("weapon_pistol")
	ply:Give("weapon_smg1")
	ply:Give("weapon_frag")
	ply:Give("weapon_physcannon")
	ply:Give("weapon_crossbow")
	ply:Give("weapon_shotgun")
	ply:Give("weapon_357")
	ply:Give("weapon_rpg")
	ply:Give("weapon_ar2")

	ply:Give("gmod_tool")
	ply:Give("gmod_camera")
	ply:Give("weapon_physgun")

	ply:SwitchToDefaultWeapon()
end
