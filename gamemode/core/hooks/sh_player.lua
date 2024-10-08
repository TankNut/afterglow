function GM:SetupMove(ply, mv, cmd)
	if cmd:GetForwardMove() <= 0 then
		mv:SetMaxClientSpeed(math.min(Lerp(0.6, ply:GetWalkSpeed(), ply:GetRunSpeed()), mv:GetMaxClientSpeed()))
	end
end

function GM:GetPlayerColor(ply) return
	ply:GetAppearance().PlayerColor or team.GetVecColor(ply:Team())
end

function GM:CanInteract(ply, ent)
	return ply:HasCharacter() and ply:Alive() and IsValid(ent) and ent:WithinRange(ply, Config.Get("InteractRange"))
end

function GM:PostPlayerSpawn(ply)
	if SERVER then
		Netstream.Send("PostPlayerSpawn", ply)
	end
end

if CLIENT then
	function GM:SelectDefaultWeapon(ply)
		return ply:GetCharacterFlagAttribute("Weapons")[1] or "weapon_physgun"
	end
else
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

		if ply:IsBot() then
			timer.Simple(0, function()
				ply:LoadTemplate(Template.Get(Config.Get("BotTemplate")))
			end)
		else
			coroutine.wrap(function()
				PlayerVar.Load(ply)
				ply:LoadCharacterList()
			end)()
		end
	end

	function GM:PlayerSpawn(ply)
		ply:Freeze(not ply:HasCharacter())

		if not ply:HasCharacter() then
			ply:KillSilent()

			return
		end

		hook.Run("PlayerSetup", ply)
		hook.Run("PostPlayerSpawn", ply)
	end

	function GM:PlayerSetup(ply)
		local flag = ply:GetCharacterFlagTable()

		local healthFraction = ply:Health() / ply:GetMaxHealth()
		local health = flag:GetAttribute(ply, "Health")

		ply:UpdateTeam()
		ply:UpdateName()
		ply:UpdateDescription()

		ply:SetMaxHealth(health)
		ply:SetHealth(math.ceil(healthFraction * health))

		ply:UpdateAppearance()
		ply:UpdateArmor()
		ply:UpdateSpeed()

		ply:SetBloodColor(flag:GetAttribute(ply, "BloodColor"))

		ply:StripWeapons()
		ply:RemoveAllAmmo()

		ply:Give("gmod_tool")
		ply:Give("gmod_camera")
		ply:Give("weapon_physgun")

		local weaponList = flag:GetAttribute(ply, "Weapons")

		for _, class in pairs(weaponList) do
			ply:Give(class)
		end

		for _, item in pairs(ply:GetEquipment()) do
			item:OnSpawn()
		end

		ply:SetActiveWeapon(NULL)

		Netstream.Send("SelectDefaultWeapon", ply)

		flag:OnSpawn(ply)
	end
end
