TEMPLATE.Name = "Combine Shotgunner"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name"
}

TEMPLATE.Items = {
	"overwatch_soldier_sg"
}

function TEMPLATE:GetName(ply)
	local id = ""

	for i = 1, 5 do
		id = id .. math.random(0, 9)
	end

	return "COTA.ECHO-OWC." .. id
end

function TEMPLATE:OnCreate(ply)
	ply:GetFirstItem("overwatch_soldier_sg"):Equip("Uniform")
end
