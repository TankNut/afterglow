function player.GetByUserGroup(usergroup)
	local tab = {}

	for _, ply in player.Iterator() do
		if ply:CheckUserGroup(usergroup) then
			table.insert(tab, ply)
		end
	end

	return tab
end

local meta = FindMetaTable("Player")

if SERVER then
	function meta:Use(ent)
		ent:Fire("Use", "!activator", 0, self)
	end
end
