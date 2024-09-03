local create = Console.AddCommand("rpa_item_create", coroutine.Bind(function(ply, class, args)
	local item = Item.Create(class)

	item:SetWorldPos(hook.Run("GetItemDropLocation", ply))

	if #args > 0 then
		item:ParseArguments(args)
	end
end))

create:SetDescription("Create an item in front of you.")
create:AddParameter(Console.Item({
	List = true, -- Display item list
	Silent = true, -- Don't output parser errors
	Force = true -- Force parser to run on nil values
}), nil, "")
create:AddOptional(Console.String(), "Arguments", "")
create:SetAccess(Command.IsAdmin)
