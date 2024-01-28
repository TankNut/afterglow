FLAG.Name = "Antlion Soldier"

FLAG.Model = Model("models/antlion.mdl")

function FLAG:GetAppearance(ply, data)
	data.Model = self.Model
	data.Skin = math.random(0, 3)
end
