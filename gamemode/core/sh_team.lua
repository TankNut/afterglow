Team = Team or {}
Team.List = {}

local meta = FindMetaTable("Player")

function Team.Add(name, color, hidden)
	return table.insert(Team.List, {
		Name = name,
		Color = color,
		Hidden = tobool(hidden)
	})
end

function Team.Get(index)
	return Team.List[index]
end

function Team.Find(name)
	name = name:lower()

	for _, data in pairs(Team.List) do
		if string.find(data.Name:lower(), name) then
			return data
		end
	end
end

if SERVER then
	function meta:UpdateTeam()
		self:SetTeam(hook.Run("GetPlayerTeam", self))
	end
end

function GM:CreateTeams()
	for k, v in pairs(Team.List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end
