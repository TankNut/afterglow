FLAG.Name = "Recruit"

function FLAG:GetCharacterName(ply)
	return "CCA.C45-RcT." ..  ply:GetCID()
end
