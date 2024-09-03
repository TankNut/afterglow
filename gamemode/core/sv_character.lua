Character.TempID = Character.TempID or -1

local meta = FindMetaTable("Player")

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

	self:UpdateEquipmentCache()

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

Netstream.Hook("SelectCharacter", function(ply, id)
	if ply:GetCharacterList()[id] then
		ply:LoadCharacter(id, Character.Fetch(id))
	end
end)

Netstream.Hook("CreateCharacter", function(ply, payload)
	local ok, data = Validate.Multi(payload, Character.GetRules())

	if not ok then
		return
	end

	local fields = {}

	for k, v in pairs(data) do
		local var = Character.Vars[k]

		if var.Field then
			fields[var.Field] = v
		end
	end

	hook.Run("PreCreateCharacter", ply, fields)

	coroutine.wrap(function()
		ply:LoadCharacter(Character.Create(ply:SteamID(), fields), fields)
	end)()

	ply:LoadCharacterList()
end)

Netstream.Hook("DeleteCharacter", function(ply, id)
	if not ply:GetCharacterList()[id] then
		return
	end

	Character.Delete(id)
	ply:LoadCharacterList()
end)
