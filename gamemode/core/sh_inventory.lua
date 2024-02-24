module("Inventory", package.seeall)

local meta = FindMetaTable("Entity")

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

	hook.Add("PlayerDisconnected", "Inventory", function(ply)
		Inventory.Remove(ply:GetNetVar("InventoryID"))
	end)
end

function meta:GetInventory()
	return Get(self:GetNetVar("InventoryID"))
end

function meta:GetItems(class, allowChildren)
	return self:GetInventory():GetItems(class, allowChildren)
end

function meta:GetFirstItem(class, allowChildren)
	return self:GetInventory():GetFirstItem(class, allowChildren)
end

function meta:GetItemAmount(class)
	return self:GetInventory():GetAmount(class)
end

function meta:HasItem(class, amount)
	return self:GetInventory():HasItem(class, amount)
end

function meta:InventoryWeight()
	return self:GetInventory():GetWeight()
end

function meta:InventoryMaxWeight()
	local weight = self:GetCharacterFlagAttribute("MaxWeight")

	return weight
end

if SERVER then
	function meta:SetInventory(inventory)
		self:SetNetVar("InventoryID", inventory.ID)
	end
end
