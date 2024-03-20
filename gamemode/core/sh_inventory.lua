module("Inventory", package.seeall)
Inventory = Inventory or {}
Inventory.Class = Inventory.Class or {}
Inventory.All = Inventory.All or {}

if SERVER then
	Inventory.Index = Inventory.Index or 0
end

local entity = FindMetaTable("Entity")

_G.CLASS = Inventory.Class
IncludeFile("class/inventory/shared.lua")
_G.CLASS = nil

function Inventory.Get(id)
	return Inventory.All[id]
end

function Inventory.Remove(id)
	if not id or not Inventory.All[id] then
		return
	end

	if SERVER then
		Netstream.Send("InventoryRemoved", Inventory.Get(id):GetReceivers(), id)
	end

	Inventory.All[id] = nil
end

function Inventory.New(storeType, storeID, id)
	if SERVER then
		id = Inventory.Index
		Inventory.Index = Inventory.Index + 1
	end

	local instance = setmetatable({}, {__index = Inventory.Class})

	instance:Initialize(id, storeType, storeID)

	Inventory.All[id] = instance

	return instance
end

if CLIENT then
	Netstream.Hook("InventoryCreated", function(payload)
		local inventory = Inventory.New(payload.StoreType, payload.StoreID, payload.ID)

		for _, v in pairs(payload.Items) do
			inventory:AddItem(Item.GetOrInstance(v.Name, v.ID, v.Data), true)
		end
	end)

	Netstream.Hook("InventoryRemoved", Inventory.Remove)
else
	if not Inventory.Null then
		Inventory.Null = Inventory.New(ITEM_NONE, 0)
	end

	local function unload(ply)
		Inventory.Remove(ply:GetNetvar("InventoryID"))
	end

	hook.Add("PlayerDisconnected", "Inventory", unload)
	hook.Add("UnloadCharacter", "Inventory", unload)
end

function entity:GetInventory()
	return Inventory.Get(self:GetNetvar("InventoryID"))
end

function entity:GetItems(class, allowChildren)
	return self:GetInventory():GetItems(class, allowChildren)
end

function entity:GetFirstItem(class, allowChildren)
	return self:GetInventory():GetFirstItem(class, allowChildren)
end

function entity:GetItemAmount(class)
	return self:GetInventory():GetAmount(class)
end

function entity:HasItem(class, amount)
	return self:GetInventory():HasItem(class, amount)
end

function entity:InventoryWeight()
	return self:GetInventory():GetWeight()
end

function entity:InventoryMaxWeight()
	if self:IsPlayer() then
		return self:GetCharacterFlagAttribute("MaxWeight")
	end

	return 0
end

if SERVER then
	function entity:SetInventory(inventory)
		self:SetNetvar("InventoryID", inventory.ID)
	end
end
