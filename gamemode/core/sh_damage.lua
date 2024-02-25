function GM:ScalePlayerDamage(ply, hitgroup, dmg)
	local scale = Config.Get("DamageScale")[hitgroup]

	if scale then
		dmg:ScaleDamage(scale)
	end
end

if SERVER then
	function GM:EntityTakeDamage(ent, dmg)
		local armor = ent:Armor()

		if armor > 0 and not dmg:IsDamageType(DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) then
			local damage = dmg:GetDamage()
			local cap = Config.Get("PenetrationCap")

			damage = math.floor(math.Clamp(damage - math.Remap(damage, armor, cap, armor, 0), 0, damage))

			if damage <= 0 then
				return true
			end

			dmg:SetDamage(damage)
		end
	end

	function GM:HandlePlayerArmorReduction(ply, dmg)
	end

	function GM:ScaleNPCDamage(npc, hitgroup, dmg)
		local scale = Config.Get("DamageScale")[hitgroup]

		if scale then
			dmg:ScaleDamage(scale)
		end
	end

	function GM:GetFallDamage(ply, speed)
		if ply:GetCharacterFlagAttribute("NoFallDamage") then
			return 0
		end

		return (speed - 526.5) * (100 / 396)
	end

	function GM:DoPlayerDeath(ply, attacker, dmg)
		local diff = 1 - math.abs(ply:GetPlayerScale())

		if diff < 0.15 then
			ply:CreateRagdoll()
		end
	end
end
