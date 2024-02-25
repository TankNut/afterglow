function GM:CharacterNameChanged(ply)
	if SERVER then
		ply:UpdateName()
	end
end


if SERVER then
	function GM:PreCreateCharacter(ply, fields)
	end

	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end
end
