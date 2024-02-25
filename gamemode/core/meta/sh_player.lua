local entity = FindMetaTable("Entity")
local meta = FindMetaTable("Player")

meta.Armor = nil
meta.SetArmor = nil

function entity:Armor()
	return self:GetNetVar("Armor", 0)
end

function meta:GetPlayerColor()
	return hook.Run("GetPlayerColor", self)
end

if SERVER then
	function entity:SetArmor(val)
		self:SetNetVar("Armor", val)
	end
end
