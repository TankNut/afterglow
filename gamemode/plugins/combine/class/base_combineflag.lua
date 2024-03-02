-- NOTE: ANY fields defined in combine flags will overwrite the corresponding character flag field when the character is flagged up
FLAG.Name = "Unnamed Combine Flag"
FLAG.Team = Combine.DefaultTeam

FLAG.CombineRank = "???"

function FLAG:GetCharacterName(ply)
	return string.format("CCA.C45-%s.%s.%s", ply:GetCombineSquad(), self:GetAttribute(ply, "CombineRank"), ply:GetCID())
end

function FLAG:GetAttribute(ply, name)
	local func = self["Get" .. name]

	return func and func(self, ply) or self[name]
end
