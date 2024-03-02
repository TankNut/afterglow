FLAG.Name = "Recruit"

FLAG.CombineRank = "RcT"

function FLAG:GetCharacterName(ply)
	return string.format("CCA.C45-%s.%s", self:GetAttribute(ply, "CombineRank"), ply:GetCID())
end
