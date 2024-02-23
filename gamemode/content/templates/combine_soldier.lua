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

function TEMPLATE:GetName(ply)
	local id = ""

	for i = 1, 5 do
		id = id .. math.random(0, 9)
	end

	return "COTA.ECHO-OWS." .. id
end

function TEMPLATE:OnCreate(ply)
	local inventory = ply:GetInventory()

	for _, item in pairs(inventory.Items) do
		item:Equip("Uniform")
	end
end
