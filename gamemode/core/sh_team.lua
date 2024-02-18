module("Team", package.seeall)

List = {}
Lookup = {}

function Add(name, color, hidden)
	local data = {
		Name = name,
		Color = color,
		Hidden = tobool(hidden)
	}

	local index = table.insert(List, data)

	data.Index = index
	Lookup[name:lower()] = data

	return index
end

function Get(name)
	return Lookup[name:lower()]
end

function GM:CreateTeams()
	for k, v in pairs(List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end
