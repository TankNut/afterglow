ITEM.Name = "Combine Overwatch Uniform"
ITEM.Description = "God help you if you ever see this"

ITEM.Category = "Clothing"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Equipment = {"Uniform"}

ITEM.InspectAngle = Angle(20, -130)
ITEM.InspectFOV = 55

function ITEM:GetModelData(ply, data)
	data.Model = Model("models/player/combine_soldier.mdl")
	data.Materials = {
		"models/combine_soldier/combinesoldiersheet"
	}
end
