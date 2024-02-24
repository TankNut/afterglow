module("Admin", package.seeall)


Ranks = Ranks or {}


function AddRank(name, inheritance)
	Ranks[name:lower()] = inheritance and inheritance:lower() or true
end


AddRank("user")
AddRank("admin", "user")
AddRank("superadmin", "admin")
AddRank("developer", "superadmin")


if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end
