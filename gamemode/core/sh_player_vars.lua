PlayerVar = PlayerVar or {}
PlayerVar.Vars = PlayerVar.Vars or {}
PlayerVar.Fields = PlayerVar.Fields or {}

local meta = FindMetaTable("Player")

function PlayerVar.Add(key, data)
	PlayerVar.Vars[key] = data

	data.Key = "P_" .. key:FirstToUpper()
	data.Accessor = data.Accessor or key:FirstToUpper()

	if data.Field then
		PlayerVar.Fields[data.Field] = data.Accessor
	end

	if data.ServerOnly then
		if CLIENT then
			return
		end

		meta["Get" .. data.Accessor] = function(ply)
			if not ply.PlayerData then
				return data.Default
			end

			local val = ply.PlayerData[data.Key]

			if val == nil then
				val = data.Default
			end

			return data.Get and data.Get(ply, val) or val
		end

		meta["Set" .. data.Accessor] = function(ply, value, noSave)
			ply.PlayerData = ply.PlayerData or {}

			local old = ply.PlayerData[data.Key]

			-- Since defaults are pre-defined, we can replace nil with it
			local callValue = value != nil and value or data.Default

			ply.PlayerData[data.Key] = value

			if data.Callback then
				data.Callback(ply, old, callValue)
			end

			if not noSave and data.Field then
				-- Write nil here to keep the database clean
				PlayerVar.Save(ply, data.Field, value)
			end

			hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
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

				if not noSave and data.Field then
					-- Write nil here to keep the database clean
					PlayerVar.Save(ply, data.Field, value)
				end

				hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
			end
		end

		if CLIENT then
			Netvar.AddEntityHook(data.Key, "PlayerVar", function(ply, old, value)
				local callValue = value != nil and value or data.Default

				if data.Callback then
					data.Callback(ply, old, callValue)
				end

				hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
			end)
		end
	end
end

if SERVER then
	PlayerVar.Load = coroutine.Bind(function(ply)
		local query = MySQL:Select("rp_player_data")
			query:Select("key")
			query:Select("value")
			query:WhereEqual("steamid", ply:SteamID())
		local data = query:Execute()

		for _, v in pairs(data) do
			local accessor = PlayerVar.Fields[v.key]

			if accessor then
				ply["Set" .. accessor](ply, Pack.Decode(v.value), true)
			end
		end
	end)

	function PlayerVar.Save(ply, field, value)
		if value == nil then
			local query = MySQL:Delete("rp_player_data")
				query:WhereEqual("steamid", ply:SteamID())
				query:WhereEqual("key", field)
			query:Execute(true)
		else
			local query = MySQL:Upsert("rp_player_data")
				query:Insert("steamid", ply:SteamID())
				query:Insert("key", field)
				query:Insert("value", Pack.Encode(value))
			query:Execute(true)
		end
	end
end
