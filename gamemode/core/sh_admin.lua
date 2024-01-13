player.RegisterVar("RPUserGroup", {
	Default = "user",
	Field = "usergroup",
	ServerOnly = true,
	PostSet = function(ply, key, old, new)
		ply:SetUserGroup(new)
	end
})

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end
