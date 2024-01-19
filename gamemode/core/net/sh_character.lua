if SERVER then
	netstream.Hook("SelectCharacter", function(ply, id)
		if ply:GetCharacterList()[id] then
			Character.LoadExternal(ply, id)
		end
	end)

	netstream.Hook("CreateCharacter", function(ply, payload)
		local ok, data = validate.Multi(payload, Character.GetRules())

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

		coroutine.wrap(function()
			Character.LoadExternal(ply, Character.Create(ply:SteamID(), fields))
		end)()

		Character.LoadList(ply)
	end)

	netstream.Hook("DeleteCharacter", function(ply, id)
		if not ply:GetCharacterList()[id] then
			return
		end

		if ply:GetCharID() == id then
			Character.Unload(ply)
		end

		Character.Delete(id)
		Character.LoadList(ply)
	end)

	local function addCharacterHook(name, callback)
		netstream.Hook(name, function(ply, ...)
			if not ply:HasCharacter() then
				return
			end

			callback(ply, ...)
		end)
	end

	addCharacterHook("SetCharacterDescription", function(ply, new)
		if ply:GetCharacterDescription() == new then
			return
		end

		local ok = validate.Value(new, hook.Run("GetCharacterDescriptionRules"))

		if not ok then
			return
		end

		ply:SetCharacterDescription(new)
	end)

	addCharacterHook("SetCharacterName", function(ply, new)
		if ply:GetCharacterName() == new then
			return
		end

		local ok = validate.Value(new, hook.Run("GetCharacterNameRules"))

		if not ok then
			return
		end

		ply:SetCharacterName(new)
	end)
end
