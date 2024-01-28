FLAG.Name = "Citizen"

FLAG.Weapons = {}

function FLAG:GetBaseModel(ply)
	return ply:GetCharacterModel(), ply:GetCharacterSkin()
end

function FLAG:GetAppearance(ply, data)
	data.Model, data.Skin = self:GetBaseModel(ply)

	-- Todo: Some kind of sorting?
	for _, item in pairs(ply:GetEquipment()) do
		item:GetModelData(ply, data)
	end
end
