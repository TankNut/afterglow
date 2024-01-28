FLAG.Name = "Citizen"

FLAG.Weapons = {}

function FLAG:GetAppearance(ply, data)
	data.Model = ply:GetCharacterModel()
	data.Skin = ply:GetCharacterSkin()

	-- Todo: Some kind of sorting?
	for _, item in pairs(ply:GetEquipment()) do
		item:GetModelData(ply, data)
	end
end
