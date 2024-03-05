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
	Field = "character_templates",
	Default = {},
	Private = true
})
