team.GetVecColor = Memoize(function(index)
	return team.GetColor(index):ToVector()
end)
