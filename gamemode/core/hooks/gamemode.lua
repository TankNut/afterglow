function GM:CreateTeams()
	for k, v in pairs(Team.List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end

local femaleModels = table.Lookup({
	"models/player/alyx.mdl",
	"models/player/mossman.mdl",
	"models/player/mossman_arctic.mdl",
	"models/player/p2_chell.mdl",
	"models/player/police_fem.mdl"
})

function GM:IsFemaleModel(mdl)
	if femaleModels[mdl] then
		return true
	end

	if string.find(mdl, "female") then return true end

	return false
end
