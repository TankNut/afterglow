TEMPLATE.Name = "Combine Soldier"

TEMPLATE.Vars = {
	Name = "COTA.ECHO-OWS.0000",
	Flag = "combine_soldier"
}

TEMPLATE.Items = {
	"overwatch_soldier"
}

function TEMPLATE:OnCreate(ply)
	local inventory = ply:GetInventory()

	for _, item in pairs(inventory.Items) do
		item:Equip("Uniform")
	end
end
