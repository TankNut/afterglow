local create = Console.AddCommand("rpa_item_create", coroutine.Bind(function(ply, class)
	local item = Item.Create(class)

	item:SetWorldPos(hook.Run("GetItemDropLocation", ply))
end))

create:SetDescription("Create an item in front of you.")
create:AddParameter(Console.Item({
	List = true, -- Display item list
	Silent = true, -- Don't output parser errors
	Force = true -- Force parser to run on nil values
}), nil, "")
create:SetAccess(Command.IsAdmin)
