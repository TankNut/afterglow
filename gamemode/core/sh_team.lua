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

function Get(index)
	return List[index]
end

function Find(name)
	name = name:lower()

	for _, data in pairs(List) do
		if string.find(data.Name:lower(), name) then
			return data
		end
	end
end

function GM:CreateTeams()
	for k, v in pairs(List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end
