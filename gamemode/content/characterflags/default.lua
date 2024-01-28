FLAG.Name = "Citizen"

FLAG.Weapons = {}

-- Overwrite if you want to keep equipment logic
function FLAG:GetBaseAppearance(ply, data)
	data.Model = ply:GetCharacterModel()
	data.Skin = ply:GetCharacterSkin()
end

-- Overwrite if you want full control over player appearance
function FLAG:GetAppearance(ply, data)
	self:GetBaseAppearance(ply, data)

	-- Todo: Some kind of sorting?
	for _, item in pairs(ply:GetEquipment()) do
		item:GetModelData(ply, data)
	end
end
