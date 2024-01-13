module("inventories", package.seeall)

local meta = FindMetaTable("Entity")

Class = Class or {}
All = All or {}

if SERVER then
	Index = Index or 0
end

function Get(id)
	return All[id]
end

function Class:Initialize(id, storeType, storeID)
	self.ID = id
	self.StoreType = storeType
	self.StoreID = storeID

	self.Items = {}

	if SERVER then
		self.Receivers = {}
		self:SendFullUpdate(self:GetReceivers())
	end
end

function Class:AddItem(item)
	self.Items[item.ID] = item

	item.InventoryID = self.ID
	item.StoreType = self.StoreType
	item.StoreID = self.StoreID
end

function Class:RemoveItem(item)
	self.Items[item.ID] = nil

	item.InventoryID = nil
	item.StoreType = ITEM_NONE
	item.StoreID = 0
end

if SERVER then
	function Class:GetReceivers()
		local receivers = self.Receivers

		if self.StoreType == ITEM_PLAYER then
			receivers[character.Find(self.StoreID)] = true
		elseif self.StoreType == ITEM_ITEM then
			table.Merge(receivers, items.Get(self.StoreID):GetInventory():GetReceivers())
		end

		return table.GetKeys(receivers)
	end

	-- Get the receivers we don't have compared to other
	function Class:DiffReceivers(other)
		local receivers = table.Lookup(self:GetReceivers())
		local tab = {}

		for _, v in pairs(other:GetReceivers()) do
			if not receivers[v] then
				tab[v] = true
			end
		end

		return table.GetKeys(tab)
	end

	function Class:SendFullUpdate(targets)
		local payload = {}

		for _, v in pairs(self.Items) do
			table.insert(payload, {Name = v.ClassName, ID = v.ID, Data = v.CustomData})
		end

		netstream.Send(targets, "InventoryCreated", {ID = self.ID, StoreType = self.StoreType, StoreID = self.StoreID, Items = payload})
	end

	function Class:AddReceiver(ply)
		if table.HasValue(self:GetReceivers(), ply) then
			return
		end

		self.Receivers[ply] = true

		self:SendFullUpdate(ply)
	end

	function Class:RemoveReceiver(ply)
		if not self.Receivers[ply] then
			return
		end

		self.Receivers[ply] = nil

		netstream.Send(ply, "InventoryRemoved", self.ID)
	end

	function Class:LoadItems(callback)
		local query = mysql:Select("rp_items")
			query:Select("id")
			query:Select("class")
			query:Select("customdata")
			query:WhereEqual("storetype", self.StoreType)
			query:WhereEqual("storeid", self.StoreID)
		query:Execute(function(data)
			for _, v in pairs(data) do
				local item = items.Instance(v.class, v.id, pack.Decode(v.customdata))

				item:SetInventory(self, true)
			end

			if callback then
				callback()
			end
		end)
	end
end

function meta:GetInventory()
	return Get(self:GetNetVar("InventoryID"))
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
		netstream.Send(Get(id):GetReceivers(), "InventoryRemoved", id)
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
	Null = New(ITEM_NULL)
end
