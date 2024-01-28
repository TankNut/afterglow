FLAG.Name = "Combine Soldier"

FLAG.Model = Model("models/player/soldier_stripped.mdl")

function FLAG:GetBaseModel(ply)
	return self.Model
end
