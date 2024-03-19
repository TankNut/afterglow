TEMPLATE.Name = "Citizen"

TEMPLATE.Callbacks = {
	"Name", "Model"
}

function TEMPLATE:GetName(ply, data)
	return ply:Nick()
end

function TEMPLATE:GetModel(ply, data)
	return table.Random(Config.Get("CharacterModels"))
end
