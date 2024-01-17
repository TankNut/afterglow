if SERVER then
	function GM:ShowTeam(ply)
		ply:OpenGroupedInterface("CharacterSelect", "F2")
	end

	function GM:ShowSpare1(ply)
		ply:OpenGroupedInterface("PlayerMenu", "F3")
	end
end
