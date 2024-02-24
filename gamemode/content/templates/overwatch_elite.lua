TEMPLATE.Name = "Combine Elite"

TEMPLATE.Vars = {
	Flag = "combine_soldier"
}

TEMPLATE.Callbacks = {
	"Name"
}

TEMPLATE.Items = {
	"overwatch_elite"
}

function TEMPLATE:GetName(ply)
	local id = ""

	for i = 1, 5 do
		id = id .. math.random(0, 9)
	end

	return "COTA.ECHO-EOW." .. id
end

function TEMPLATE:OnCreate(ply)
	ply:GetFirstItem("overwatch_elite"):Equip("Uniform")
end
