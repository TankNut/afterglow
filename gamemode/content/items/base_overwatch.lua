DEFINE_BASECLASS("base_clothing")

ITEM.Base = "base_clothing"

ITEM.Internal = true

ITEM.Tags = {
	"Combine",
	"Overwatch"
}

ITEM.HudElements = {
	"overlay_combine"
}

ITEM.Flags = table.Lookup({
	"combine_soldier"
})

function ITEM:CanEquip()
	return self.Flags[self.Player:GetCharacterFlag()]
end
