function GM:GetHudElements(ply)
	for id, element in pairs(Hud.List) do
		if element:IsDefaultElement(ply) then
			Hud.Add(id)
		end
	end
end
