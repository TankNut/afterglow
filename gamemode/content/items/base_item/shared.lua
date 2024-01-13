ITEM.Name = "NULL Item"
ITEM.Description = "God help you if you ever see this"

ITEM.Model = Model("models/props_junk/PopCan01a.mdl")
ITEM.Skin = 0

ITEM.Bodygroups = {}

ITEM.Internal = true

IncludeFile("sh_inventory.lua")
IncludeFile("sv_db.lua")

function ITEM:IsTempItem()
	return self.ID < 0
end

if SERVER then
	function ITEM:OnWorldUse(ply, ent)
		if not ply:GetInventory() then
			return
		end

		if self:CanPickup(ply) then
			self:SetInventory(ply:GetInventory())
		end
	end

	function ITEM:CanPickup(ply)
		return true
	end
end
