module("PlayerVars", package.seeall)

local meta = FindMetaTable("Player")

Vars = Vars or {}
Fields = Fields or {}

function Register(key, data)
	Vars[key] = data

	data.Key = "Ply" .. (data.Key or key:FirstToUpper())
	data.Accessor = data.Accessor or key:FirstToUpper()

	if data.Field then
		Fields[data.Field] = data.Accessor
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

			if data.Hook then
				hook.Run(data.Hook, ply, data.Key, old, callValue)
			end

			if data.PostSet then
				data.PostSet(ply, data.Key, old, callValue)
			end

			if data.Field and not noSave then
				-- Write nil here to keep the database clean
				SaveVar(ply, data.Field, value)
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

				if data.Hook then
					hook.Run(data.Hook, ply, data.Key, old, callValue)
				end

				if data.PostSet then
					data.PostSet(ply, data.Key, old, callValue)
				end

				if data.Field and not noSave then
					-- Write nil here to keep the database clean
					SaveVar(ply, data.Field, value)
				end
			end
		end

		if CLIENT and data.Hook then
			netvar.AddEntityHook(data.Key, "PlayerVars", function(ply, _, old, value)
				local callValue = value != nil and value or data.Default

				hook.Run(data.Hook, ply, data.Key, old, callValue)
			end)
		end
	end
end

if SERVER then
	Load = coroutine.Bind(function(ply)
		local query = mysql:Select("rp_player_data")
			query:Select("key")
			query:Select("value")
			query:WhereEqual("steamid", ply:SteamID())
		local data = query:Execute()

		for _, v in pairs(data) do
			local accessor = Fields[v.key]

			if accessor then
				ply["Set" .. accessor](ply, pack.Decode(v.value), true)
			end
		end
	end)

	function Save(ply, field, value)
		if value == nil then
			local query = mysql:Delete("rp_player_data")
				query:WhereEqual("steamid", ply:SteamID())
				query:WhereEqual("key", field)
			query:Execute(true)
		else
			local query = mysql:Upsert("rp_player_data")
				query:Insert("steamid", ply:SteamID())
				query:Insert("key", field)
				query:Insert("value", pack.Encode(value))
			query:Execute(true)
		end
	end
end
