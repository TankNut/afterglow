FLAG.Name = "Squad Leader"

function FLAG:GetCharacterName(ply)
	return string.format("CCA.C45-%s.SqL.%s", ply:GetCombineSquad(), ply:GetCID())
end
