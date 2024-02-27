TEMPLATE.Name = "Combine Elite"
TEMPLATE.Base = "overwatch_soldier"

TEMPLATE.Items = {
	"overwatch_elite"
}

function TEMPLATE:GetName(ply, data)
	return "COTA.ECHO-EOW." .. data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_elite"):Equip("Uniform")
end
