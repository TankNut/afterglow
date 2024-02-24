PlayerVar.Add("CharacterList", {
	Private = true,
	Default = {},
	Callback = function(ply, old, new)
		if CLIENT and (not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1])) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end
})


PlayerVar.Add("UserGroup", {
	Accessor = "RPUserGroup",
	Field = "usergroup",
	Default = "user",
	ServerOnly = true,
	Callback = function(ply, _, new)
		ply:SetUserGroup(new)
	end
})


PlayerVar.Add("CustomBadges", {
	Field = "badges",
	Default = {}
})
