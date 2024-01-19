if CLIENT then
	netvar.AddEntityHook("CharacterList", "Character", function(ply)
		if not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1]) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end)

	netvar.AddEntityHook("CharID", "Character", function(ply, _, new)
		if ply == LocalPlayer() and new > -1 then
			Interface.CloseGroup("F2")
		end
	end)
else
	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end

	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	function GM:GetCharacterListName(id, fields)
	end
end

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

function GM:CanChangeCharacterName(ply)
	return true
end

function GM:CanChangeCharacterDescription(ply)
	return true
end
