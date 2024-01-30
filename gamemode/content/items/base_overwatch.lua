ITEM.Base = "base_clothing"

ITEM.Tags = {
	"Combine",
	"Overwatch"
}

ITEM.Flags = table.Lookup({
	"combine_soldier"
})

function ITEM:CanEquip()
	return self.Flags[self.Player:GetCharacterFlag()]
end
