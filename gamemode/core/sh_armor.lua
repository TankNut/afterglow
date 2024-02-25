local entity = FindMetaTable("Entity")
local meta = FindMetaTable("Player")

meta.Armor = nil
meta.SetArmor = nil

function meta:GetPlayerColor()
	return hook.Run("GetPlayerColor", self)
end

function entity:Armor()
	return self:GetNetVar("Armor", 0)
end

if SERVER then
	function entity:SetArmor(val)
		self:SetNetVar("Armor", val)
	end

	function meta:UpdateArmor()
		local armor = hook.Run("GetBaseArmor", self)

		if self:HasCharacter() then
			for _, v in pairs(self:GetEquipment()) do
				if v:IsBasedOn("base_clothing") then
					armor = math.max(armor, v:GetArmor())
				end
			end
		end

		if self:Armor() != armor then
			self:SetArmor(armor > 0 and armor or nil)
		end
	end
end
