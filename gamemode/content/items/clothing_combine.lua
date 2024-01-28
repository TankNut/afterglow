ITEM.Base = "base_clothing"

ITEM.Name = "Combine Overwatch Uniform"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Equipment = {"Uniform"}

ITEM.InspectAngle = Angle(20, -130)
ITEM.InspectFOV = 55

ITEM.Armor = 15

function ITEM:GetModelData(ply, data)
	data.Model = Model("models/player/combine_soldier.mdl")
	data.Materials = {
		"models/combine_soldier/combinesoldiersheet"
	}
end
