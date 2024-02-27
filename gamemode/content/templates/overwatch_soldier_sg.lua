TEMPLATE.Name = "Combine Shotgunner"
TEMPLATE.Base = "overwatch_soldier"

TEMPLATE.Items = {
	"overwatch_soldier_sg"
}

function TEMPLATE:GetName(ply, data)
	return "COTA.ECHO-OWC." .. data.CID
end

function TEMPLATE:OnLoad(ply, data)
	ply:GetFirstItem("overwatch_soldier_sg"):Equip("Uniform")
end
