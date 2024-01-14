if CLIENT then
	netvar.AddEntityHook("CharacterList", "Character", function(ply)
		if not ply:HasCharacter() then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end)
else
	function GM:PostLoadCharacter(ply, old, id)
		ply:Spawn()
	end

	function GM:GetCharListFields(fields)
		table.insert(fields, "name")
	end

	function GM:GetCharListName(id, fields)
	end
end
