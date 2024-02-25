function GM:GetCharacterNameRules()
	return {
		validate.Required(),
		validate.String(),
		validate.Min(Config.Get("MinNameLength")),
		validate.Max(Config.Get("MaxNameLength")),
		validate.AllowedCharacters(Config.Get("NameCharacters"))
	}
end

function GM:GetCharacterDescriptionRules()
	return {
		validate.Required(),
		validate.String(),
		validate.Min(Config.Get("MinDescriptionLength")),
		validate.Max(Config.Get("MaxDescriptionLength")),
		validate.AllowedCharacters(Config.Get("DescriptionCharacters"))
	}
end

function GM:GetBaseCharacterRules()
	return {
		Name = hook.Run("GetCharacterNameRules"),
		Description = hook.Run("GetCharacterDescriptionRules"),
		Model = {
			validate.Required(),
			validate.String(),
			validate.InList(Config.Get("CharacterModels"))
		},
		Skin = {
			validate.Required(),
			validate.Number(),
			validate.Min(0),
			validate.Callback(function(val)
				return val < util.GetModelSkins(validate.Cache().Model), "Skin index out of bounds"
			end)
		}
	}
end

function GM:ModifyCharacterRules(rules)
end
