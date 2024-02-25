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

PlayerVar.Add("Templates", {
	Accessor = "Templates",
	Field = "templates",
	Default = {},
	Private = true
})
