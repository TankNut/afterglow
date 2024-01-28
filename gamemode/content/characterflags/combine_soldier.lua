FLAG.Name = "Combine Soldier"

FLAG.Model = Model("models/player/soldier_stripped.mdl")

function FLAG:GetBaseAppearance(ply, data)
	data.Model = self.Model
end
