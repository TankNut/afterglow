module("Character", package.seeall)

Vars = Vars or {}

local meta = FindMetaTable("Player")

function RegisterVar(key, data)
	Vars[key] = data

	data.Key = "Char" .. (data.Key or key:FirstToUpper())
	data.Accessor = data.Accessor or key:FirstToUpper()
	data.Field = data.Field or key:lower()

	if data.ServerOnly then
		if CLIENT then
			return
		end

		meta["Get" .. data.Accessor] = function(ply)
			if not ply.CharacterData then
				return data.Default
			end

			local val = ply.CharacterData[data.Key]

			if val == nil then
				val = data.Default
			end

			return data.Get and data.Get(ply, val) or val
		end

		meta["Set" .. data.Accessor] = function(ply, value, noSave)
			ply.CharacterData = ply.CharacterData or {}

			local old = ply.CharacterData[data.Key]
			-- Since defaults are pre-defined, we can replace nil with it
			local callValue = value != nil and value or data.Default

			ply.CharacterData[data.Key] = value

			if data.Hook then
				hook.Run(data.Hook, ply, data.Key, old, callValue)
			end

			if data.PostSet then
				data.PostSet(ply, data.Key, old, callValue)
			end

			-- Write nil here to keep the database clean
			SaveVar(ply:GetCharID(), data.Field, value)
		end
	else
		meta["Get" .. data.Accessor] = function(ply)
			local val = ply:GetNetVar(data.Key, data.Default)

			return data.Get and data.Get(ply, val) or val
		end

		if SERVER then
			local func = data.Private and "SetPrivateNetVar" or "SetNetVar"

			meta["Set" .. data.Accessor] = function(ply, value, noSave)
				local old = ply:GetNetVar(data.Key, data.Default)
				-- Since defaults are pre-defined, we can replace nil with it
				local callValue = value != nil and value or data.Default

				ply[func](ply, data.Key, value)

				if data.Hook then
					hook.Run(data.Hook, ply, data.Key, old, callValue)
				end

				if data.PostSet then
					data.PostSet(ply, data.Key, old, callValue)
				end

				-- Write nil here to keep the database clean
				SaveVar(ply:GetCharID(), data.Field, value)
			end
		end

		if CLIENT and data.Hook then
			netvar.AddEntityHook(data.Key, "CharacterVar", function(ply, _, old, value)
				local callValue = value != nil and value or data.Default

				hook.Run(data.Hook, ply, data.Key, old, callValue)
			end)
		end
	end
end

function Find(id)
	for _, v in ipairs(player.GetAll()) do
		if v:GetCharID() == id then
			return v
		end
	end
end

function meta:GetCharID()
	return self:GetNetVar("CharID", -1)
end

function meta:HasCharacter()
	return self:GetCharID() != -1
end

function meta:IsTemporaryCharacter()
	return self:GetCharID() == 0
end

if SERVER then
	function meta:SetCharID(id)
		self:SetNetVar("CharID", id)
	end

	Load = coroutine.Bind(function(ply, id, fields)
		local old = -1

		if ply:HasCharacter() then
			old = ply:GetCharID()
			Unload(ply)
		end

		LOADING_CHARACTER = true

		ply:SetNetVar("CharID", id)

		for k, v in pairs(Vars) do
			local val = fields[v.Field] or nil

			ply["Set" .. v.Accessor](ply, val, true)
		end

		LOADING_CHARACTER = nil

		local inventory = Inventory.New(ITEM_PLAYER, id)

		ply:SetInventory(inventory)

		if not ply:IsTemporaryCharacter() then
			inventory:LoadItems()
		end

		hook.Run("PostLoadCharacter", ply, old, id)
	end)

	function NoCharacter(ply)
		if ply:HasCharacter() then
			Unload(ply)
		end

		LOADING_CHARACTER = true

		ply:SetNetVar("CharID", -1)

		for k, v in pairs(Vars) do
			ply["Set" .. v.Accessor](ply, nil, true)
		end

		LOADING_CHARACTER = nil

		ply:KillSilent()
	end

	LoadExternal = coroutine.Bind(function(ply, id)
		-- Todo: Sanity check whether a character with that ID actually exists (somewhere else? character list?)
		local query = mysql:Select("rp_character_data")
			query:Select("key")
			query:Select("value")
			query:WhereEqual("id", id)
		local data = query:Execute()

		Load(ply, id, data)
	end)

	Create = coroutine.Bind(function(steamid, fields)
		local query = mysql:Insert("rp_characters")
			query:Insert("steamid", steamid)
		local _, id = query:Execute()

		mysql:Begin()

		for k, v in pairs(fields) do
			query = mysql:Insert("rp_character_data")
				query:Insert("id", id)
				query:Insert("key", k)
				query:Insert("value", pack.Encode(v))
			query:Execute()
		end

		mysql:Commit()

		return id
	end)

	function SaveVar(id, field, value)
		if id <= 0 then
			return
		end

		if value == nil then
			local query = mysql:Delete("rp_character_data")
				query:WhereEqual("id", id)
				query:WhereEqual("key", field)
			query:Execute(true)
		else
			local query = mysql:Upsert("rp_character_data")
				query:Insert("id", id)
				query:Insert("key", field)
				query:Insert("value", pack.Encode(value))
			query:Execute(true)
		end
	end

	function Unload(ply)
		Inventory.Remove(ply:GetNetVar("InventoryID"))
	end
end

RegisterVar("RPName", {
	Field = "name",
	Default = "*INVALID*"
})

RegisterVar("Description", {
	Default = ""
})
