FLAG.Name = "Citizen"

FLAG.BaseLanguage = "eng"
FLAG.DefaultLanguages = {
	{"eng", true}
}

FLAG.Weapons = {}

FLAG.Health = 100
FLAG.Armor = 0

FLAG.SlowWalkSpeed = 80
FLAG.WalkSpeed = 90
FLAG.RunSpeed = 220
FLAG.JumpPower = 210
FLAG.CrouchSpeed = 60

FLAG.MaxWeight = 20

FLAG.NoFallDamage = false

FLAG.BloodColor = BLOOD_COLOR_RED
FLAG.AllowClothing = true

function FLAG:GetAttribute(name, ply)
	local func = self["Get" .. name]

	return func and func(self, ply) or self[name]
end

if SERVER then
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

	function FLAG:OnSpawn(ply)
	end
end
