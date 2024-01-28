-- Armor
local entMeta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")

plyMeta.Armor = nil
plyMeta.SetArmor = nil

function entMeta:Armor()
	return self:GetNetVar("Armor", 0)
end

if SERVER then
	function entMeta:SetArmor(val)
		self:SetNetVar("Armor", val)
	end

	function plyMeta:UpdateArmor()
		local armor = 0

		for _, v in pairs(self:GetEquipment()) do
			if v:IsBasedOn("base_clothing") then
				armor = math.max(armor, v:GetArmor())
			end
		end

		self:SetArmor(armor > 0 and armor or nil)
	end
end

-- Damage scaling
function GM:ScalePlayerDamage(ply, hitgroup, dmg)
	local scale = Config.Get("DamageScale")[hitgroup]

	if scale then
		dmg:ScaleDamage(scale)
	end
end

if SERVER then
	function GM:EntityTakeDamage(ent, dmg)
		local armor = ent:Armor()

		if armor > 0 and dmg:IsDamageType(DMG_GENERIC + DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_CLUB) then
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
end
