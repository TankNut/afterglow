function Character.GetRules()
	local rules = hook.Run("GetBaseCharacterRules")

	hook.Run("ModifyCharacterRules", rules)

	return rules
end

function GM:GetCharacterNameRules()
	return {
		Validate.Required(),
		Validate.String(),
		Validate.Min(Config.Get("MinNameLength")),
		Validate.Max(Config.Get("MaxNameLength")),
		Validate.AllowedCharacters(Config.Get("NameCharacters"))
	}
end

function GM:GetCharacterDescriptionRules()
	return {
		Validate.Required(),
		Validate.String(),
		Validate.Min(Config.Get("MinDescriptionLength")),
		Validate.Max(Config.Get("MaxDescriptionLength")),
		Validate.AllowedCharacters(Config.Get("DescriptionCharacters"))
	}
end

function GM:GetBaseCharacterRules()
	return {
		Name = hook.Run("GetCharacterNameRules"),
		Description = hook.Run("GetCharacterDescriptionRules"),
		Model = {
			Validate.Required(),
			Validate.String(),
			Validate.InList(Config.Get("CharacterModels"))
		},
		Skin = {
			Validate.Required(),
			Validate.Number(),
			Validate.Min(0),
			Validate.Callback(function(val)
				return val < util.GetModelSkins(Validate.Cache().Model), "Skin index out of bounds"
			end)
		}
	}
end

function GM:ModifyCharacterRules(rules)
end
