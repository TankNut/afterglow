module("Admin", package.seeall)

local meta = FindMetaTable("Player")

Ranks = Ranks or {}

function AddRank(name, inheritance)
	Ranks[name:lower()] = inheritance and inheritance:lower() or true
end

AddRank("user")
AddRank("admin", "user")
AddRank("superadmin", "admin")
AddRank("developer", "superadmin")

PlayerVar.Register("UserGroup", {
	Accessor = "RPUserGroup",
	Field = "usergroup",
	Default = "user",
	ServerOnly = true,
	Callback = function(ply, _, new)
		ply:SetUserGroup(new)
	end
})

function meta:CheckUserGroup(group)
	local usergroup = self:GetUserGroup()

	if usergroup == group then
		return true
	end

	while usergroup do
		local parent = Ranks[usergroup]

		if parent == group then
			return true
		elseif parent == true then
			return false
		end

		usergroup = parent
	end

	return false
end

function meta:IsAdmin()
	return self:CheckUserGroup("admin")
end

function meta:IsSuperAdmin()
	return self:CheckUserGroup("superadmin")
end

function meta:IsDeveloper()
	return self:CheckUserGroup("developer")
end

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end
