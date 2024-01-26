if SERVER then
	function GM:GetAppearance(ply, data)
		data.Model = ply:GetCharacterModel()
		data.Skin = ply:GetCharacterSkin()

		-- Todo: Some kind of sorting?
		for _, item in pairs(ply:GetEquipment()) do
			item:GetModelData(ply, data)
		end

		if table.IsEmpty(data.Hands) then
			local name = player_manager.TranslateToPlayerModelName(data.Model)
			local hands = player_manager.TranslatePlayerHands(name)

			data.Hands.Model = hands.model
			data.Hands.Skin = hands.matchBodySkin and data.Skin or hands.skin
		end
	end

	function GM:PostSetAppearance(ply, data)
	end

	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance or {
			Model = Model("models/weapons/c_arms_hev.mdl")
		})
	end
end

netvar.AddEntityHook("Appearance", "Appearance", function(ent, _, appearance)
	Appearance.Apply(ent, appearance)
end)
