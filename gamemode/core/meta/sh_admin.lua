local meta = FindMetaTable("Player")


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
