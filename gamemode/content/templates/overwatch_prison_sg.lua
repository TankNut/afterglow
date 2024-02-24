TEMPLATE.Name = "Nova Prospekt Shotgunner"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name"
}

TEMPLATE.Items = {
	"overwatch_prison_sg"
}

function TEMPLATE:GetName(ply)
	local id = ""

	for i = 1, 5 do
		id = id .. math.random(0, 9)
	end

	return "COTA.HELIX-OWC." .. id
end

function TEMPLATE:OnCreate(ply)
	ply:GetFirstItem("overwatch_prison_sg"):Equip("Uniform")
end
