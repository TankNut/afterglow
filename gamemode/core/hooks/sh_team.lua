function GM:CreateTeams()
	for k, v in pairs(Team.List) do
		team.SetUp(k, v.Name, v.Color, false)
	end
end
