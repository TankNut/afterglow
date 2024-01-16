PlayerVars.Register("UserGroup", {
	Field = "usergroup",
	Default = "user",
	ServerOnly = true,
	Callback = function(ply, _, new)
		ply:SetUserGroup(new)
	end
})

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end
