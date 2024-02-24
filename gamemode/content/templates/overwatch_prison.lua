TEMPLATE.Name = "Nova Prospekt Guard"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name"
}

TEMPLATE.Items = {
	"overwatch_prison"
}

function TEMPLATE:GetName(ply)
	local id = ""

	for i = 1, 5 do
		id = id .. math.random(0, 9)
	end

	return "COTA.HELIX-OWS." .. id
end

function TEMPLATE:OnCreate(ply)
	ply:GetFirstItem("overwatch_prison"):Equip("Uniform")
end
