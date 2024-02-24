module("Character", package.seeall)

local meta = FindMetaTable("Player")

Vars = Vars or {}

function AddVar(key, data)
	Vars[key] = data

	data.Key = "Character" .. (data.Key or key:FirstToUpper())
	data.Accessor = data.Accessor or "Character" .. key:FirstToUpper()
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

			if data.Callback then
				data.Callback(ply, old, callValue)
			end

			if not noSave then
				-- Write nil here to keep the database clean
				SaveVar(ply:GetCharID(), data.Field, value)
			end
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

				if data.Callback then
					data.Callback(ply, old, callValue)
				end

				if not noSave then
					-- Write nil here to keep the database clean
					SaveVar(ply:GetCharID(), data.Field, value)
				end
			end
		end

		if CLIENT and data.Callback then
			netvar.AddEntityHook(data.Key, "CharacterVar", function(ply, old, value)
				local callValue = value != nil and value or data.Default

				data.Callback(ply, old, callValue)
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

function GetRules()
	local rules = hook.Run("GetBaseCharacterRules")

	hook.Run("ModifyCharacterRules", rules)

	return rules
end

if SERVER then
	Load = coroutine.Bind(function(ply, id, fields)
		if ply:HasCharacter() then
			OnUnload(ply)
		end

		_G.CHARACTER_LOADING = true

		ply:SetCharID(id)

		for k, v in pairs(Vars) do
			local val = fields[v.Field] or nil

			ply["Set" .. v.Accessor](ply, val, true)
		end

		local inventory = Inventory.New(ITEM_PLAYER, id)

		ply:SetInventory(inventory)

		if not ply:IsTemplateCharacter() then
			inventory:LoadItems()
		end

		_G.CHARACTER_LOADING = nil

		hook.Run("PostLoadCharacter", ply, id)
	end)

	function Delete(id)
		mysql:Begin()

		local query = mysql:Delete("rp_characters")
			query:WhereEqual("id", id)
		query:Execute()

		query = mysql:Delete("rp_character_data")
		query:WhereEqual("id", id)
		query:Execute()

		mysql:Commit()
	end

	function Unload(ply)
		if ply:HasCharacter() then
			OnUnload(ply)
		end

		_G.CHARACTER_LOADING = true

		ply:SetCharID(nil)

		for k, v in pairs(Vars) do
			ply["Set" .. v.Accessor](ply, nil, true)
		end

		_G.CHARACTER_LOADING = nil

		hook.Run("PostLoadCharacter", ply, -1)
	end

	LoadExternal = coroutine.Bind(function(ply, id)
		local query = mysql:Select("rp_character_data")
			query:Select("key")
			query:Select("value")
			query:WhereEqual("id", id)
		local fields = table.DBKeyValues(query:Execute())

		Load(ply, id, fields)
	end)

	LoadList = coroutine.Bind(function(ply)
		local characters = {}

		local query = mysql:Select("rp_characters")
			query:Select("id")
			query:WhereEqual("steamid", ply:SteamID())
		local ids = query:Execute()

		local fields = {}

		hook.Run("GetCharacterListFields", fields)

		for _, v in pairs(ids) do
			query = mysql:Select("rp_character_data")
				query:Select("key")
				query:Select("value")
				query:WhereEqual("id", v.id)
				query:WhereIn("key", fields)
			local data = table.DBKeyValues(query:Execute())

			data.name = hook.Run("GetCharacterListName", data) or data.name or "*UNNAMED CHARACTER*"

			characters[v.id] = data
		end

		ply:SetCharacterList(characters)
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

	function OnUnload(ply)
		Inventory.Remove(ply:GetNetVar("InventoryID"))
	end
end

if SERVER then
	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end

	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	function GM:GetCharacterListName(id, fields)
	end

	function GM:PreCreateCharacter(ply, fields)
	end
end

function GM:GetCharacterNameRules()
	return {
		validate.Required(),
		validate.String(),
		validate.Min(Config.Get("MinNameLength")),
		validate.Max(Config.Get("MaxNameLength")),
		validate.AllowedCharacters(Config.Get("NameCharacters"))
	}
end

function GM:GetCharacterDescriptionRules()
	return {
		validate.Required(),
		validate.String(),
		validate.Min(Config.Get("MinDescriptionLength")),
		validate.Max(Config.Get("MaxDescriptionLength")),
		validate.AllowedCharacters(Config.Get("DescriptionCharacters"))
	}
end

function GM:GetBaseCharacterRules()
	return {
		Name = hook.Run("GetCharacterNameRules"),
		Description = hook.Run("GetCharacterDescriptionRules"),
		Model = {
			validate.Required(),
			validate.String(),
			validate.InList(Config.Get("CharacterModels"))
		},
		Skin = {
			validate.Required(),
			validate.Number(),
			validate.Min(0),
			validate.Callback(function(val)
				return val < util.GetModelSkins(validate.Cache().Model), "Skin index out of bounds"
			end)
		}
	}
end

function GM:ModifyCharacterRules(rules)
end

function GM:CanChangeCharacterName(ply)
	return true
end

function GM:CanChangeCharacterDescription(ply)
	return true
end
