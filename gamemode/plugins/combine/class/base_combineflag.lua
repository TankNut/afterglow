FLAG.Name = "Unnamed Combine Flag"
FLAG.Team = Combine.DefaultTeam

-- Everything else is empty because combine flags use the same fields as character flags, any fields here would overwrite

function FLAG:GetAttribute(ply, name)
	local func = self["Get" .. name]

	return func and func(self, ply) or self[name]
end
