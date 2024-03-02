console.Parser("CombineFlag", function(ply, args, last, options)
	local flag = table.remove(args, 1):lower()

	if not Combine.Flag.Get(flag) then
		return false, "Invalid flag."
	end

	return true, flag
end)
