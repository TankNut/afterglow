ITEM.Base = "base_overwatch"

ITEM.Name = "Overwatch Elite Uniform"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Equipment = {"Uniform"}

ITEM.InspectAngle = Angle(20, -130)
ITEM.InspectFOV = 55

ITEM.Armor = 5


function ITEM:GetModelData(ply, data)
	data.Model = Model("models/player/combine_super_soldier.mdl")
	data.Materials = {
		"models/combine_soldier/combine_elite",
		"models/combine_soldier/combine_elite"
	}
end
