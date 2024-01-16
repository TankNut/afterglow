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
end
