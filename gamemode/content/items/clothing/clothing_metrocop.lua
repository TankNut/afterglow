ITEM.Base = "base_clothing"

ITEM.Name = "CCA Uniform"

ITEM.Model = Model("models/items/item_item_crate.mdl")

ITEM.Equipment = {"Uniform"}

ITEM.InspectAngle = Angle(20, -130)
ITEM.InspectFOV = 55

ITEM.Armor = 5

ITEM.MaleModel = Model("models/player/police.mdl")
ITEM.FemaleModel = Model("models/player/police_fem.mdl")

ITEM.PlayerColor = Color(143, 165, 181):ToVector()

function ITEM:GetModelData(ply, data)
	data.Model = util.IsFemaleModel(data.Model) and self.FemaleModel or self.MaleModel
	data.PlayerColor = self:GetProperty("PlayerColor")
end
