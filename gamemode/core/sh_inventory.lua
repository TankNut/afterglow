module("Inventory", package.seeall)

local entity = FindMetaTable("Entity")

Class = Class or {}
All = All or {}

if SERVER then
	Index = Index or 0
end

_G.CLASS = Class
IncludeFile("class/inventory/shared.lua")
_G.CLASS = nil

function Get(id)
	return All[id]
end

function Remove(id)
	if not id or not All[id] then
		return
	end

	if SERVER then
		netstream.Send("InventoryRemoved", Get(id):GetReceivers(), id)
	end

	All[id] = nil
end

function New(storeType, storeID, id)
	if SERVER then
		id = Index
		Index = Index + 1
	end

	local instance = setmetatable({}, {__index = Class})

	instance:Initialize(id, storeType, storeID)

	All[id] = instance

	return instance
end

if SERVER then
	if not Null then
		Null = New(ITEM_NULL, 0)
	end

	local function unload(ply)
		Remove(ply:GetNetVar("InventoryID"))
	end

	hook.Add("PlayerDisconnected", "Inventory", unload)
	hook.Add("UnloadCharacter", "Inventory", unload)
end

function entity:GetInventory()
	return Inventory.Get(self:GetNetVar("InventoryID"))
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
	local weight = self:GetCharacterFlagAttribute("MaxWeight")

	return weight
end

if SERVER then
	function entity:SetInventory(inventory)
		self:SetNetVar("InventoryID", inventory.ID)
	end
end
