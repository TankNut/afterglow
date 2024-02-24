PlayerVar.Add("CharacterList", {
	Private = true,
	Default = {},
	Callback = function(ply, old, new)
		if CLIENT and (not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1])) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end
})


PlayerVar.Add("Scale", {
	Accessor = "PlayerScale",
	Default = 1,
	Callback = function(ply, old, new)
		ply:RefreshHull()
	end
})
