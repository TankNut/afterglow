local meta = FindMetaTable("Player")

Character.AddVar("Name", {
	Private = true,
	Default = "*INVALID*"
})

PlayerVar.Add("VisibleName", {
	Default = ""
})

function meta:HasForcedCharacterName()
	return tobool(hook.Run("GetCharacterName", self))
end

if SERVER then
	function meta:UpdateName()
		self:SetVisibleName(hook.Run("GetCharacterName", self) or self:GetCharacterName())
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

		ply:SetCharacterName(ply, new)
	end)
end

function GM:GetCharacterName(ply) return ply:GetCharacterFlagAttribute("CharacterName") end

function GM:OnCharacterNameChanged(ply, old, new)
	if SERVER and not CHARACTER_LOADING then
		ply:UpdateName()
		ply:LoadCharacterList()
	end
end

function GM:CanChangeCharacterName(ply) return not ply:HasForcedCharacterName() end
