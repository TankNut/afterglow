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

function meta:GetInventory()
	return Get(self:GetNetVar("InventoryID"))
end

function meta:GetItems()
	local inventory = self:GetInventory()

	return inventory and inventory.Items or {}
end

function meta:InventoryWeight()
	local inventory = self:GetInventory()

	return inventory and inventory:GetWeight() or 0
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

if SERVER and not Null then
	Null = New(ITEM_NULL, 0)
end
