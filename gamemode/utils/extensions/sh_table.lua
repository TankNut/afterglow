function table.Map(tbl, func)
	local res = {}

	for k, v in pairs(tbl) do
		res[k] = func(v, k)
	end

	return res
end

function table.Lookup(tbl)
	local res = {}

	for _, v in pairs(tbl) do
		res[v] = true
	end

	return res
end
