ITEM_NULL = 0
ITEM_WORLD = 1
ITEM_PLAYER = 2
ITEM_CONTAINER = 3
ITEM_ITEM = 4

module("Item", package.seeall)

List = List or {}
All = All or setmetatable({}, {__mode = "v"})

function Inherit(tab, base)
	if not base then
		return tab
	end

	for k, v in pairs(base) do
		if tab[k] == nil then
			tab[k] = v
		elseif k != "BaseClass" and istable(tab[k]) and istable(v) then
			Inherit(tab[k], v)
		end
	end

	tab["BaseClass"] = base

	return tab
end

function IsBasedOn(name, base)
	if name == base then
		return true
	end

	local item = List[name]

	if not item or not item.Base then
		return false
	end

	if item.Base == base then
		return true
	end

	return IsBasedOn(item.Base, base)
end

function Register(name, data)
	if name != "base_item" then
		data.Base = data.Base or "base_item"
	end

	if data.Model and not util.HasPhysicsObject(data.Model) then
		Msg("ERROR: Trying to register item " .. name .. " with invalid model " .. data.Model .. "!\n")

		return
	end

	data.ClassName = name
	data.Internal = tobool(data.Internal)

	List[name] = data
end

function GetTable(name)
	local item = List[name]

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
		tab = Inherit(tab, GetTable(item.Base))
	end

	return tab
end

function Get(id)
	return All[id]
end

function Instance(name, id, data)
	local item = GetTable(name)

	item.ID = id
	item.CustomData = data or {}
	item.Cache = {}

	All[id] = item

	return item
end

if CLIENT then
	function GetOrInstance(name, id, data)
		local item = Get(id)

		if item then
			item.CustomData = data
			-- Refresh
		else
			item = Instance(name, id, data)
		end

		return item
	end
end

function LoadFromFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.ITEM = {}

	IncludeFile(path)

	Register(name, ITEM)

	_G.ITEM = nil
end

function LoadItems()
	local recursive

	recursive = function(path)
		local abort = file.Exists(path .. "/shared.lua", "LUA")

		if abort then
			LoadFromFile(path .. "/shared.lua", path:GetFileFromFilename())

			return
		end

		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			LoadFromFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/content/items")

	for name in pairs(List) do
		baseclass.Set(name, GetTable(name))
	end

	for _, item in pairs(All) do
		table.Merge(item, GetTable(item.ClassName))
	end
end

if SERVER then
	Create = coroutine.Bind(function(name, data)
		local query = mysql:Insert("rp_items")
			query:Insert("class", name)
			query:Insert("customdata", pack.Encode(data))
		local _, id = query:Execute()

		return Instance(name, id, data)
	end)

	LoadWorldItems = coroutine.Bind(function()
		local query = mysql:Select("rp_items")
			query:Select("id")
			query:Select("class")
			query:Select("customdata")
			query:Select("worldpos")
			query:WhereEqual("storetype", ITEM_WORLD)
			query:WhereEqual("worldmap", game.GetMap())
		local data = query:Execute()

		for _, v in pairs(data) do
			local item = items.Instance(v.class, v.id, pack.Decode(v.customdata))
			local worldPos = pack.Decode(v.worldpos)

			local ent = item:SetWorldPos(worldPos.Pos, worldPos.Ang, true)

			if ent and worldPos.Frozen then
				ent:GetPhysicsObject():EnableMotion(false)
			end
		end
	end)

	PlayerCreate = coroutine.Bind(function(ply, name)
		local item = Create(name, {})

		item:SetWorldPos(hook.Run("GetItemDropLocation", ply))
	end)

	concommand.Add("rp_dev_createitem", function(ply, _, args)
		if not IsValid(ply) then
			return
		end

		PlayerCreate(ply, args[1])
	end)
end
