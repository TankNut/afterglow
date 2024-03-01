FLAG.Name = "Citizen"
FLAG.Team = TEAM_CITIZEN

FLAG.CharacterName = nil

FLAG.BaseLanguage = "eng"
FLAG.DefaultLanguages = {
	eng = true
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

FLAG.PlayerColor = Color(15, 71, 93):ToVector()

FLAG.AttributeBlacklist = table.Lookup({
	"Name", "ID", -- Internal values
	"Attribute", -- Infinite loop avoidance
})

function FLAG:GetAttribute(ply, name)
	return hook.Run("GetCharacterFlagAttribute", self, ply, name)
end

function FLAG:GetPlayerColor(ply)
	return ply:EquipmentHook("PlayerColor") or self.PlayerColor
end

if SERVER then
	-- Overwrite if you want to keep equipment logic
	function FLAG:GetBaseAppearance(ply, data)
		data.Model = ply:GetCharacterModel()
		data.Skin = ply:GetCharacterSkin()
		data.PlayerColor = self:GetAttribute(ply, "PlayerColor")
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
