if SERVER then
	function GM:GetAppearance(ply, data)
		data.Model = ply:GetCharacterModel()
		data.Skin = ply:GetCharacterSkin()

		-- Todo: Some kind of sorting?
		for _, item in pairs(ply:GetEquipment()) do
			item:GetModelData(ply, data)
		end
	end

	function GM:PostSetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end

netvar.AddEntityHook("Appearance", "Appearance", function(ent, _, appearance)
	Appearance.Apply(ent, appearance)
end)
