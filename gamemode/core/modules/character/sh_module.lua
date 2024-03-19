CHARACTER_NONE = 0

Character = Character or {}
Character.Vars = Character.Vars or {}

IncludeFile("sh_vars.lua")
IncludeFile("sh_hooks.lua")
IncludeFile("sh_meta.lua")
IncludeFile("sh_rules.lua")
IncludeFile("sh_flags.lua")
IncludeFile("sv_net.lua")

function Character.Find(id)
	for _, v in player.Iterator() do
		if v:GetCharID() == id then
			return v
		end
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
end
