function GM:CharacterNameChanged(ply)
	if SERVER then
		ply:UpdateName()

		if not CHARACTER_LOADING then
			Character.LoadList(ply)
		end
	end
end

if SERVER then
	function GM:PreCreateCharacter(ply, fields)
	end

	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end
end
