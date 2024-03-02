FLAG.Name = "Ground Unit"

function FLAG:GetCharacterName(ply)
	return string.format("CCA.C45-%s.%s.%s", ply:GetCombineSquad(), ply:GetCombineSquadID(), ply:GetCID())
end
