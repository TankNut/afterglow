if CLIENT then
	function GM:GetHudElements(ply)
		for id, element in pairs(Hud.List) do
			if element:ShouldAddElement(ply) then
				Hud.Add(id)
			end
		end
	end

	local classes = table.Lookup({
		"weapon_physgun",
		"gmod_tool"
	})

	function GM:ShouldOpenContextMenu(ply)
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) and classes[weapon:GetClass()] then
			return false
		end

		return true
	end
end
