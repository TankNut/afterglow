CHARACTER_NONE = 0

Character = Character or {}

local meta = FindMetaTable("Player")

function Character.Find(id)
	for _, v in player.Iterator() do
		if v:GetCharID() == id then
			return v
		end
	end
end

function Character.VarToField(var)
	var = Character.Vars[var]

	if var then
		return var.Field
	end
end

function Character.GetRules()
	local rules = hook.Run("GetBaseCharacterRules")

	hook.Run("ModifyCharacterRules", rules)

	return rules
end

function meta:HasCharacter()
	return self:GetCharID() != CHARACTER_NONE
end

function meta:IsTemplateCharacter()
	return self:GetCharID() < CHARACTER_NONE
end
