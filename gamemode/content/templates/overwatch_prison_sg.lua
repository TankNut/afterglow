TEMPLATE.Name = "Nova Prospekt Shotgunner"
TEMPLATE.Base = "overwatch_soldier"

TEMPLATE.Items = {
	"overwatch_prison_sg"
}

function TEMPLATE:GetName(ply, data)
	return "COTA.HELIX-OWC." .. data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_prison_sg"):Equip("Uniform")
end
