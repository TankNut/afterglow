module("Inventory", package.seeall)

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
