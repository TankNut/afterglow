TEMPLATE.Name = "Combine Soldier"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name", "CID"
}

TEMPLATE.Items = {
	"overwatch_soldier"
}

function TEMPLATE:OnCreate(ply, data)
	data.CID = Combine.GetCID()
end

function TEMPLATE:GetName(ply, data)
	return "COTA.ECHO-OWS." .. data.CID
end

function TEMPLATE:GetCID(ply, data)
	return data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_soldier"):Equip("Uniform")
end
