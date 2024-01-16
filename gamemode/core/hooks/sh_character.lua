if CLIENT then
	netvar.AddEntityHook("CharacterList", "Character", function(ply)
		if not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1]) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end)
else
	function GM:PostLoadCharacter(ply, old, id)
		ply:Spawn()
	end

	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	function GM:GetChararacterListName(id, fields)
	end
end
