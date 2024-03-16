CHARACTER_NONE = 0

Character = Character or {}
Character.Vars = Character.Vars or {}

local meta = FindMetaTable("Player")

function Character.AddVar(key, data)
	Character.Vars[key] = data

	data.Key = "C_" .. key:FirstToUpper()
	data.Accessor = data.Accessor or ("Character" .. key:FirstToUpper())
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
				Character.SaveVar(ply:GetCharID(), data.Field, value)
			end
		end
	else
		meta["Get" .. data.Accessor] = function(ply)
			local val = ply:GetNetvar(data.Key, data.Default)

			return data.Get and data.Get(ply, val) or val
		end

		if SERVER then
			local func = data.Private and "SetPrivateNetvar" or "SetNetvar"

			meta["Set" .. data.Accessor] = function(ply, value, noSave)
				local old = ply:GetNetvar(data.Key, data.Default)

				-- Since defaults are pre-defined, we can replace nil with it
				local callValue = value != nil and value or data.Default

				ply[func](ply, data.Key, value)

				if data.Callback then
					data.Callback(ply, old, callValue)
				end

				if not noSave then
					-- Write nil here to keep the database clean
					Character.SaveVar(ply:GetCharID(), data.Field, value)
				end
			end
		end

		if CLIENT and data.Callback then
			Netvar.AddEntityHook(data.Key, "CharacterVar", function(ply, old, value)
				local callValue = value != nil and value or data.Default

				data.Callback(ply, old, callValue)
			end)
		end
	end
end

function Character.Find(id)
	for _, v in player.Iterator() do
		if v:GetCharID() == id then
			return v
		end
	end
end

function Character.GetRules()
	local rules = hook.Run("GetBaseCharacterRules")

	hook.Run("ModifyCharacterRules", rules)

	return rules
end

if SERVER then
	Character.TempID = Character.TempID or -1

	function Character.Delete(id)
		assert(id > CHARACTER_NONE, "Attempt to delete invalid CharID")

		local ply = Character.Find(id)

		if IsValid(ply) then
			ply:UnloadCharacter()
		end

		MySQL:Begin()

		local query = MySQL:Delete("rp_characters")
			query:WhereEqual("id", id)
		query:Execute()

		query = MySQL:Delete("rp_character_data")
		query:WhereEqual("id", id)
		query:Execute()

		MySQL:Commit()
	end

	Character.Fetch = coroutine.Bind(function(id)
		local query = MySQL:Select("rp_character_data")
			query:Select("key")
			query:Select("value")
			query:WhereEqual("id", id)

		return table.DBKeyValues(query:Execute())
	end)

	Character.Create = coroutine.Bind(function(steamid, fields)
		local query = MySQL:Insert("rp_characters")
			query:Insert("steamid", steamid)
		local _, id = query:Execute()

		MySQL:Begin()

		for k, v in pairs(fields) do
			query = MySQL:Insert("rp_character_data")
				query:Insert("id", id)
				query:Insert("key", k)
				query:Insert("value", Pack.Encode(v))
			query:Execute()
		end

		MySQL:Commit()

		return id
	end)

	function Character.SaveVar(id, field, value)
		if id <= CHARACTER_NONE then
			return
		end

		if value == nil then
			local query = MySQL:Delete("rp_character_data")
				query:WhereEqual("id", id)
				query:WhereEqual("key", field)
			query:Execute(true)
		else
			local query = MySQL:Upsert("rp_character_data")
				query:Insert("id", id)
				query:Insert("key", field)
				query:Insert("value", Pack.Encode(value))
			query:Execute(true)
		end
	end
end

function meta:HasCharacter()
	return self:GetCharID() != CHARACTER_NONE
end

function meta:IsTemplateCharacter()
	return self:GetCharID() < CHARACTER_NONE
end

function meta:HasForcedCharacterName()
	return tobool(hook.Run("GetCharacterName", self))
end

if SERVER then
	-- Using bind here because of inventory:LoadItems()
	meta.LoadCharacter = coroutine.Bind(function(self, id, fields)
		if self:HasCharacter() then
			hook.Run("UnloadCharacter", self, self:GetCharID(), true)
		end

		_G.CHARACTER_LOADING = true

		self:SetCharID(id)

		for k, v in pairs(Character.Vars) do
			local val = fields[v.Field] or nil

			self["Set" .. v.Accessor](self, val, true)
		end

		local inventory = Inventory.New(ITEM_PLAYER, id)

		self:SetInventory(inventory)

		if not self:IsTemplateCharacter() then
			inventory:LoadItems()
		end

		_G.CHARACTER_LOADING = nil

		hook.Run("PostLoadCharacter", self, id)
	end)

	function meta:UnloadCharacter()
		if self:HasCharacter() then
			hook.Run("UnloadCharacter", self, self:GetCharID(), false)
		end

		_G.CHARACTER_LOADING = true

		self:SetCharID(nil)

		for k, v in pairs(Character.Vars) do
			self["Set" .. v.Accessor](self, nil, true)
		end

		_G.CHARACTER_LOADING = nil

		hook.Run("PostLoadCharacter", self, CHARACTER_NONE)
	end

	meta.LoadCharacterList = coroutine.Bind(function(self)
		local characters = {}

		local query = MySQL:Select("rp_characters")
			query:Select("id")
			query:WhereEqual("steamid", self:SteamID())
		local ids = query:Execute()

		local fields = {}

		hook.Run("GetCharacterListFields", fields)

		for _, v in pairs(ids) do
			query = MySQL:Select("rp_character_data")
				query:Select("key")
				query:Select("value")
				query:WhereEqual("id", v.id)
				query:WhereIn("key", fields)

			local data = table.DBKeyValues(query:Execute())

			characters[v.id] = hook.Run("GetCharacterListName", data)
		end

		self:SetCharacterList(characters)
	end)

	-- Move this somewhere else?
	function meta:UpdateName()
		self:SetVisibleName(hook.Run("GetCharacterName", self) or self:GetCharacterName())
	end
end
