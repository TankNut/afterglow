ITEM.__Item = true

ITEM.Name = "NULL Item"
ITEM.Description = "God help you if you ever see this"

ITEM.ItemColor = color_white

ITEM.Category = "Misc"
ITEM.Tags = {}

ITEM.Model = Model("models/props_junk/PopCan01a.mdl")
ITEM.Skin = 0

ITEM.Bodygroups = {}

ITEM.Equipment = {}

ITEM.InspectAngle = Angle(11, 175)
ITEM.InspectFOV = 14

ITEM.Weight = 0

ITEM.Internal = true

-- Used for item displays
ITEM.Amount = 1
ITEM.Equipped = false

IncludeFile("sh_actions.lua")
IncludeFile("sh_cache.lua")
IncludeFile("sh_equipment.lua")
IncludeFile("sh_event.lua")
IncludeFile("sh_getters.lua")
IncludeFile("sh_inventory.lua")
IncludeFile("sv_db.lua")

function ITEM:IsTempItem()
	return self.ID < 0
end

function ITEM:IsBasedOn(name)
	return Item.IsBasedOn(self.ClassName, name)
end

function ITEM:GetParent()
	return self:GetInventory()
end

function ITEM:GetProperty(key)
	local val = self.CustomData[key]

	return val != nil and val or self[key]
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
	if key == "Equipped" then
		self:FireEvent("EquipmentChanged", self)

		if val then
			hook.Run("ItemEquipped", self.Player, self)
		else
			hook.Run("ItemUnequipped", self.Player, self)
		end
	elseif key == "Weight" then
		self:FireEvent("WeightChanged", self)
	elseif key == "Category" or key == "Tags" then
		self:InvalidateCache("Tags")
	end
end

if SERVER then
	function ITEM:GetReceivers()
		local inventory = self:GetInventory()

		if inventory then
			return inventory:GetReceivers()
		end
	end

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
