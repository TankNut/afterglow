function player.GetByUserGroup(usergroup)
	local tab = {}

	for _, ply in player.Iterator() do
		if ply:CheckUserGroup(usergroup) then
			table.insert(tab, ply)
		end
	end

	return tab
end
