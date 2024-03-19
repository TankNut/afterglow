TEMPLATE.Name = "Combine Soldier"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name"
}

TEMPLATE.Items = {
	"overwatch_soldier"
}

function TEMPLATE:OnCreate(ply, data, fields)
	data.CID = fields[Character.VarToField("CID")]
end

function TEMPLATE:GetName(ply, data)
	return "COTA.ECHO-OWS." .. data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_soldier"):Equip("Uniform")
end
