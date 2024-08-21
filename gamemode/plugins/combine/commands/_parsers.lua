Console.Parser("CombineFlag", function(ply, args, last, options)
	local flag = table.remove(args, 1):lower()

	if not CombineFlag.Get(flag) then
		return false, "Invalid flag."
	end

	return true, flag
end)
