local meta = FindMetaTable("Player")

Character.AddVar("Description", {
	Private = true,
	Default = "",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateDescription()
		end
	end
})

PlayerVar.Add("VisibleDescription", {
	Private = true,
	Default = ""
})

PlayerVar.Add("ShortDescription", {
	Default = ""
})

function GM:GetCharacterDescription(ply)
	return ply:GetCharacterDescription()
end

if SERVER then
	function meta:UpdateDescription()
		local description = hook.Run("GetCharacterDescription", self)

		self.ExamineCache = nil

		local short = string.match(description, "^[^\r\n]*")
		local config = Config.Get("ShortDescriptionLength")

		if #short > 0 and #short > config then
			short = string.sub(short, 1, config) .. "..."
		end

		self:SetVisibleDescription(description)
		self:SetShortDescription(short)
	end

	Request.Hook("Examine", function(ply, target)
		target.ExamineCache = target.ExamineCache or {}

		if not target.ExamineCache[ply] then
			target.ExamineCache[ply] = true

			return target:GetVisibleDescription()
		end
	end)

	Netstream.Hook("SetCharacterDescription", function(ply, new)
		if not ply:HasCharacter() or ply:GetVisibleDescription() == new then
			return
		end

		if not hook.Run("CanChangeCharacterDescription", ply) then
			return
		end

		local ok = Validate.Value(new, hook.Run("GetCharacterDescriptionRules"))

		if not ok then
			return
		end

		hook.Run("SetCharacterDescription", ply, new)
	end)

	function GM:SetCharacterDescription(ply, new)
		ply:SetCharacterDescription(new)
	end
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
