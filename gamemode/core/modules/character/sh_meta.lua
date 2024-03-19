local meta = FindMetaTable("Player")

function meta:HasCharacter()
	return self:GetCharID() != CHARACTER_NONE
end

function meta:IsTemplateCharacter()
	return self:GetCharID() < CHARACTER_NONE
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
end
