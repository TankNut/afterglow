FLAG.Name = "Antlion Soldier"
FLAG.Team = TEAM_XENIAN

FLAG.Model = Model("models/antlion.mdl")

FLAG.WalkSpeed = 195
FLAG.RunSpeed = 355
FLAG.JumpPower = 410

FLAG.NoFallDamage = true

FLAG.AllowClothing = false

if SERVER then
	function FLAG:GetAppearance(ply, data)
		data.Model = self.Model
		data.Skin = math.random(0, 3)
	end
end
