TEMPLATE.Name = "Nova Prospekt Guard"
TEMPLATE.Base = "overwatch_soldier"

TEMPLATE.Items = {
	"overwatch_prison"
}

function TEMPLATE:GetName(ply, data)
	return "COTA.HELIX-OWS." .. data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_prison"):Equip("Uniform")
end
