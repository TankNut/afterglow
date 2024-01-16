if CLIENT then
	netvar.AddEntityHook("CharacterList", "Character", function(ply)
		if not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1]) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end)
else
	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end

	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	function GM:GetChararacterListName(id, fields)
	end
end

function GM:GetBaseCharacterRules()
	return {
		RPName = {
			validate.Required(),
			validate.String(),
			validate.Min(3),
			validate.Max(30),
			validate.AllowedCharacters("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ.-0123456789'")
		},
		Description = {
			validate.String(),
			validate.Max(2048),
			validate.AllowedCharacters("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ.-0123456789'")
		},
		CharacterModel = {
			validate.Required(),
			validate.String(),
			validate.InList(Config.Get("CharacterModels"))
		},
		CharacterSkin = {
			validate.Required(),
			validate.Number(),
			validate.Min(0),
			validate.Callback(function(val)
				return val < util.GetModelSkins(validate.Cache().CharacterModel), "Skin index out of bounds"
			end)
		}
	}
end

function GM:ModifyCharacterRules(rules)
end
