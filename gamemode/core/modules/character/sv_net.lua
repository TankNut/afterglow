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
