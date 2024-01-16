PlayerVars.Register("RPUserGroup", {
	Default = "user",
	Field = "usergroup",
	ServerOnly = true,
	Hook = "PlayerUserGroupChanged"
})

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end
