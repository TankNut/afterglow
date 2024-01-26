IncludeFile("sh_event.lua")
IncludeFile("sv_net.lua")

CLASS.__Inventory = true

function CLASS:Initialize(id, storeType, storeID)
	self.ID = id
	self.StoreType = storeType
	self.StoreID = storeID

	if storeType == ITEM_PLAYER then
		self.Player = Character.Find(storeID)
	elseif storeType == ITEM_ITEM then
		self.Item = Item.Get(storeID)
	end

	self.Items = {}

	if CLIENT then
		self.Panels = {}
	else
		self.Receivers = {}
		self:SendFullUpdate(self:GetReceivers())
	end
end

function CLASS:GetParent()
	if self.StoreType == ITEM_PLAYER then
		return self.Player
	elseif self.StoreType == ITEM_ITEM then
		return self.Item
	end
end

function CLASS:AddItem(item)
	self.Items[item.ID] = item

	item.InventoryID = self.ID
	item.StoreType = self.StoreType
	item.StoreID = self.StoreID

	if self.StoreType == ITEM_PLAYER then
		item.Player = self.Player
	end

	self:FireEvent("ItemAdded", item)
end

function CLASS:RemoveItem(item)
	self.Items[item.ID] = nil

	if self.StoreType == ITEM_PLAYER then
		item.Player = nil
	end

	item.InventoryID = nil
	item.StoreType = ITEM_NONE
	item.StoreID = 0

	self:FireEvent("ItemRemoved", item)
end

if CLIENT then
	function CLASS:AddPanel(pnl)
		table.insert(self.Panels, pnl)
	end

	function CLASS:RemovePanel(pnl)
		self.Panels = table.Filter(self.Panels, function(_, v)
			return IsValid(v) and v != pnl
		end)
	end
else
	CLASS.LoadItems = coroutine.Bind(function(self)
		local query = mysql:Select("rp_items")
			query:Select("id")
			query:Select("class")
			query:Select("customdata")
			query:WhereEqual("storetype", self.StoreType)
			query:WhereEqual("storeid", self.StoreID)
		local data = query:Execute()

		for _, v in pairs(data) do
			local item = Item.Instance(v.class, v.id, pack.Decode(v.customdata))

			item:SetInventory(self, true)
		end
	end)
end
