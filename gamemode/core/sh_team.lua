module("Team", package.seeall)

List = {}


function Add(name, color, hidden)
	return table.insert(List, {
		Name = name,
		Color = color,
		Hidden = tobool(hidden)
	})
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


if SERVER then
	function GM:PlayerGetTeam(ply)
		return ply:GetCharacterFlagAttribute("Team")
	end
end


function GM:CreateTeams()
	for k, v in pairs(List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end
