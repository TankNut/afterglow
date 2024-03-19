CHARACTER_NONE = 0

Character = Character or {}
Character.Vars = Character.Vars or {}

local meta = FindMetaTable("Player")

PlayerVar.Add("CharID", {
	Default = CHARACTER_NONE,
	Callback = function(ply, old, new)
		if CLIENT and ply == LocalPlayer() and new != CHARACTER_NONE then
			Interface.CloseGroup("F2")
		end
	end
})

PlayerVar.Add("CharacterList", {
	Private = true,
	Default = {},
	Callback = function(ply, old, new)
		if CLIENT and (not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1])) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end
})

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

do -- Character Creation Rules
	function Character.GetRules()
		local rules = hook.Run("GetBaseCharacterRules")

		hook.Run("ModifyCharacterRules", rules)

		return rules
	end

	function GM:GetCharacterNameRules()
		return {
			Validate.Required(),
			Validate.String(),
			Validate.Min(Config.Get("MinNameLength")),
			Validate.Max(Config.Get("MaxNameLength")),
			Validate.AllowedCharacters(Config.Get("NameCharacters"))
		}
	end

	function GM:GetCharacterDescriptionRules()
		return {
			Validate.Required(),
			Validate.String(),
			Validate.Min(Config.Get("MinDescriptionLength")),
			Validate.Max(Config.Get("MaxDescriptionLength")),
			Validate.AllowedCharacters(Config.Get("DescriptionCharacters"))
		}
	end

	function GM:GetBaseCharacterRules()
		return {
			Name = hook.Run("GetCharacterNameRules"),
			Description = hook.Run("GetCharacterDescriptionRules"),
			Model = {
				Validate.Required(),
				Validate.String(),
				Validate.InList(Config.Get("CharacterModels"))
			},
			Skin = {
				Validate.Required(),
				Validate.Number(),
				Validate.Min(0),
				Validate.Callback(function(val)
					return val < util.GetModelSkins(Validate.Cache().Model), "Skin index out of bounds"
				end)
			}
		}
	end

	function GM:ModifyCharacterRules(rules)
	end

end

function Character.VarToField(var)
	var = Character.Vars[var]

	if var then
		return var.Field
	end
end

if SERVER then
	Character.TempID = Character.TempID or -1

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

	Netstream.Hook("DeleteCharacter", function(ply, id)
		if not ply:GetCharacterList()[id] then
			return
		end

		Character.Delete(id)
		ply:LoadCharacterList()
	end)

	function GM:PreCreateCharacter(ply, fields)
	end

	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end

	function GM:UnloadCharacter(ply, id, loadingNew)
	end
end
