Admin = Admin or {}
Admin.Ranks = Admin.Ranks or {}

local meta = FindMetaTable("Player")

function Admin.AddRank(name, inheritance)
	Admin.Ranks[name:lower()] = inheritance and inheritance:lower() or true
end

Admin.AddRank("user")
Admin.AddRank("admin", "user")
Admin.AddRank("superadmin", "admin")
Admin.AddRank("developer", "superadmin")

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
end

function meta:CheckUserGroup(group)
	local usergroup = self:GetUserGroup()

	if usergroup == group then
		return true
	end

	while usergroup do
		local parent = Admin.Ranks[usergroup]

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
