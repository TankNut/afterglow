if SERVER then
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

	local function addCharacterHook(name, callback)
		Netstream.Hook(name, function(ply, ...)
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

		local ok = Validate.Value(new, hook.Run("GetCharacterDescriptionRules"))

		if not ok then
			return
		end

		ply:SetCharacterDescription(new)
	end)

	addCharacterHook("SetCharacterName", function(ply, new)
		if ply:GetCharacterName() == new then
			return
		end

		local ok = Validate.Value(new, hook.Run("GetCharacterNameRules"))

		if not ok then
			return
		end

		ply:SetCharacterName(new)
	end)

	Request.Hook("Examine", function(ply, target)
		target.ExamineCache = target.ExamineCache or {}

		if not target.ExamineCache[ply] then
			target.ExamineCache[ply] = true

			return target:GetCharacterDescription()
		end
	end)
end
