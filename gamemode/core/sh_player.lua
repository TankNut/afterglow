function GM:SetupMove(ply, mv, cmd)
	if cmd:GetForwardMove() <= 0 then
		mv:SetMaxClientSpeed(Lerp(0.6, ply:GetWalkSpeed(), ply:GetRunSpeed()))
	end
end
