FLAG.Name = "Combine Soldier"

FLAG.Model = Model("models/player/soldier_stripped.mdl")

FLAG.AllowClothing = false

if SERVER then
	function FLAG:GetBaseAppearance(ply, data)
		data.Model = self.Model
	end
end
