Character.AddVar("Description", {
	Private = true,
	Default = ""
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

	Netstream.Hook("SetCharacterDescription", function(ply, new)
		if not ply:HasCharacter() or ply:GetCharacterDescription() == new then
			return
		end

		if not hook.Run("CanChangeCharacterDescription", ply) then
			return
		end

		local ok = Validate.Value(new, hook.Run("GetCharacterDescriptionRules"))

		if not ok then
			return
		end

		ply:SetCharacterDescription(new)
	end)
end

function GM:OnCharacterDescriptionChanged(ply, old, new)
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
