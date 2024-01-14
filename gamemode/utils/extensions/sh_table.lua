function table.Map(tab, func)
	local res = {}

	for k, v in pairs(tab) do
		res[k] = func(v, k)
	end

	return res
end

function table.Lookup(tab)
	local res = {}

	for _, v in pairs(tab) do
		res[v] = true
	end

	return res
end
