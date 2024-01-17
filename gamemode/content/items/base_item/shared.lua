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

function ITEM:GetProperty(key, default)
	local val = self.CustomData[key]

	return val != nil and val or default
end

function ITEM:SetProperty(key, val)
	local old = self.CustomData[key]

	self.CustomData[key] = val
	self:PropertyUpdated(key, old, val)

	if SERVER then
		netstream.Send(self:GetReceivers(), "ItemData", {ID = self.ID, Key = key, Value = val})
		self:SaveData()
	end
end

function ITEM:PropertyUpdated(key, old, val)
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
		if ply:IsTemporaryCharacter() and not self:IsTempItem() then
			return false
		end

		return true
	end
end
