ITEM_NONE = 0
ITEM_WORLD = 1
ITEM_PLAYER = 2
ITEM_CONTAINER = 3
ITEM_ITEM = 4

Item = Item or {}
Item.List = Item.List or {}
Item.All = Item.All or setmetatable({}, {__mode = "v"})

function Item.Inherit(tab, base)
	if not base then
		return tab
	end

	for k, v in pairs(base) do
		if tab[k] == nil then
			tab[k] = v
		elseif k != "BaseClass" and istable(tab[k]) and istable(v) then
			Item.Inherit(tab[k], v)
		end
	end

	tab["BaseClass"] = base

	return tab
end

function Item.IsBasedOn(name, base)
	if name == base then
		return true
	end

	local item = Item.List[name]

	if not item or not item.Base then
		return false
	end

	if item.Base == base then
		return true
	end

	return Item.IsBasedOn(item.Base, base)
end

function Item.Add(name, data)
	name = name:lower()

	if name != "base_item" then
		data.Base = data.Base or "base_item"
	end

	if data.Model and not util.HasPhysicsObject(data.Model) then
		Msg("ERROR: Trying to add item " .. name .. " with invalid model " .. data.Model .. "!\n")

		return
	end

	data.ClassName = name
	data.Internal = tobool(data.Internal)

	Item.List[name] = data
end

function Item.AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.ITEM = {}

	IncludeFile(path)
	Item.Add(name, ITEM)

	_G.ITEM = nil
end

function Item.AddFolder(basePath)
	local recursive

	recursive = function(path)
		local abort = file.Exists(path .. "/shared.lua", "LUA")

		if abort then
			Item.AddFile(path .. "/shared.lua", path:GetFileFromFilename())

			return
		end

		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			Item.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/" .. basePath)

	for name in pairs(Item.List) do
		baseclass.Set(name, Item.GetTable(name))
	end

	for _, item in pairs(Item.All) do
		table.Merge(item, Item.GetTable(item.ClassName))
	end
end

function Item.GetTable(name)
	local item = Item.List[name]

	if not item then
		return
	end

	local tab = {}

	for k, v in pairs(item) do
		if istable(v) then
			tab[k] = table.Copy(v)
		else
			tab[k] = v
		end
	end

	if item.Base then
		tab = Item.Inherit(tab, Item.GetTable(item.Base))
	end

	return tab
end

function Item.Get(id)
	return Item.All[id]
end

function Item.Instance(name, id, data)
	local item = Item.GetTable(name)

	item.ID = id
	item.CustomData = data or {}
	item.Cache = {}

	Item.All[id] = item

	return item
end

if CLIENT then
	function Item.GetOrInstance(name, id, data)
		local item = Item.Get(id)

		if item then
			item.CustomData = data
			-- Refresh
		else
			item = Item.Instance(name, id, data)
		end

		return item
	end

	Netstream.Hook("ItemAdd", function(payload)
		Item.GetOrInstance(payload.Name, payload.ID, payload.Data):SetInventory(Inventory.Get(payload.Inventory))
	end)

	Netstream.Hook("ItemRemove", function(id)
		local item = Item.Get(id)

		if item then
			item:SetInventory(nil)
		end
	end)

	Netstream.Hook("ItemData", function(payload)
		local item = Item.Get(payload.ID)

		if item then
			item:SetProperty(payload.Key, payload.Value)
		end
	end)
end

if SERVER then
	Item.TempID = Item.TempID or -1

	Item.Create = coroutine.Bind(function(name, data)
		local query = MySQL:Insert("rp_items")
			query:Insert("class", name)
			query:Insert("custom_data", Pack.Encode(data))
		local _, id = query:Execute()

		return Item.Instance(name, id, data)
	end)

	function Item.CreateTemp(name, data)
		local item = Item.Instance(name, Item.TempID, data)

		Item.TempID = Item.TempID - 1

		return item
	end

	Item.LoadWorldItems = coroutine.Bind(function()
		local query = MySQL:Select("rp_items")
			query:Select("id")
			query:Select("class")
			query:Select("custom_data")
			query:Select("world_position")
			query:WhereEqual("store_type", ITEM_WORLD)
			query:WhereEqual("world_map", game.GetMap())
		local data = query:Execute()

		for _, v in pairs(data) do
			if not Item.List[v.class] then
				continue
			end

			local item = Item.Instance(v.class, v.id, Pack.Decode(v.custom_data))
			local worldPos = Pack.Decode(v.world_pos)

			local ent = item:SetWorldPos(worldPos.Pos, worldPos.Ang, true)

			if ent and worldPos.Frozen then
				ent:GetPhysicsObject():EnableMotion(false)
			end
		end
	end)

	Item.PlayerCreate = coroutine.Bind(function(ply, name)
		local item = Item.Create(name, {})

		item:SetWorldPos(hook.Run("GetItemDropLocation", ply))
	end)
end

hook.Add("OnReloaded", "Item", function()
	for _, item in pairs(Item.All) do
		item:InvalidateCache()
	end
end)

if SERVER then
	hook.Add("PostInitDatabase", "Item", function()
		Item.LoadWorldItems()
	end)
end

function GM:GetItemDropLocation(ply)
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 50,
		filter = ply,
		collisiongroup = COLLISION_GROUP_WEAPON
	})

	local ang = ply:GetAngles()

	ang.p = 0

	return tr.HitPos + tr.HitNormal * 10, ang
end

function GM:ItemEquipped(ply, item, loaded)
	item:OnEquip(loaded)
	item:FireEvent("EquipmentChanged")
end

function GM:ItemUnequipped(ply, item)
	item:OnUnequip()
	item:FireEvent("EquipmentChanged")
end
