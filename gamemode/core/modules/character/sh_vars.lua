local meta = FindMetaTable("Player")

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

local function addCharacterHook(name, callback)
	Netstream.Hook(name, function(ply, ...)
		if not ply:HasCharacter() then
			return
		end

		callback(ply, ...)
	end)
end

do -- Character Name
	Character.AddVar("Name", {
		Private = true,
		Default = "*INVALID*",
		Callback = function(ply, old, new)
			hook.Run("CharacterNameChanged", ply, old, new)
		end
	})

	PlayerVar.Add("VisibleName", {
		Default = ""
	})

	function meta:HasForcedCharacterName()
		return tobool(hook.Run("GetCharacterName", self))
	end

	function meta:UpdateName()
		self:SetVisibleName(hook.Run("GetCharacterName", self) or self:GetCharacterName())
	end

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

	function GM:GetCharacterName(ply) return ply:GetCharacterFlagAttribute("CharacterName") end

	function GM:CharacterNameChanged(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateName()
			ply:LoadCharacterList()
		end
	end

	function GM:CanChangeCharacterName(ply) return not ply:HasForcedCharacterName() end
end

do -- Character Description
	Character.AddVar("Description", {
		Private = true,
		Default = "",
		Callback = function(ply, old, new)
			hook.Run("CharacterDescriptionChanged", ply, old, new)
		end
	})

	PlayerVar.Add("ShortDescription", {
		Default = ""
	})

	if SERVER then
		Request.Hook("Examine", function(ply, target)
			target.ExamineCache = target.ExamineCache or {}

			if not target.ExamineCache[ply] then
				target.ExamineCache[ply] = true

				return target:GetCharacterDescription()
			end
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

	function GM:CharacterDescriptionChanged(ply, old, new)
		if SERVER then
			ply.ExamineCache = nil

			local short = string.match(new, "^[^\r\n]*")
			local config = Config.Get("ShortDescriptionLength")

			if #short > 0 and #short > config then
				short = string.sub(short, 1, config) .. "..."
			end

			ply:SetShortDescription(short)
		end
	end

	function GM:CanChangeCharacterDescription(ply) return true end
end

Character.AddVar("Model", {
	ServerOnly = true,
	Default = "models/player/skeleton.mdl",
	Callback = function(ply)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateAppearance()
		end
	end
})

Character.AddVar("Skin", {
	ServerOnly = true,
	Default = 0,
	Callback = function(ply)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateAppearance()
		end
	end
})
