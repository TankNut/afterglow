local meta = FindMetaTable("Player")

Character.AddVar("Name", {
	Private = true,
	Default = "*INVALID*",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateName()
			ply:LoadCharacterList()
		end
	end
})

PlayerVar.Add("VisibleName", {
	Default = ""
})

PlayerVar.Add("ForcedCharacterName", {
	Default = false
})

function meta:HasForcedCharacterName()
	return self:GetForcedCharacterName()
end

if SERVER then
	function meta:UpdateName()
		local forced = hook.Run("GetCharacterNameOverride", self)

		if forced then
			self:SetForcedCharacterName(true)
			self:SetVisibleName(forced)
		else
			self:SetForcedCharacterName(false)
			self:SetVisibleName(hook.Run("GetCharacterName", self))
		end
	end

	function GM:GetCharacterName(ply)
		return ply:GetCharacterName()
	end

	function GM:GetCharacterNameOverride(ply)
		return ply:GetCharacterFlagAttribute("CharacterName")
	end

	Netstream.Hook("SetCharacterName", function(ply, new)
		if not ply:HasCharacter() or ply:GetCharacterName() == new then
			return
		end

		if not hook.Run("CanChangeCharacterName", ply) then
			return
		end

		local ok = Validate.Value(new, hook.Run("GetCharacterNameRules"))

		if not ok then
			return
		end

		hook.Run("SetCharacterName", ply, new)
	end)

	function GM:SetCharacterName(ply, new)
		ply:SetCharacterName(new)
	end
end

function GM:CanChangeCharacterName(ply) return not ply:HasForcedCharacterName() end
