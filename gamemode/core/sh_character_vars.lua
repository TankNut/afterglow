local meta = FindMetaTable("Player")

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
