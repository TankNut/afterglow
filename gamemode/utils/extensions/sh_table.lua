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

function table.Filter(tab, func)
	local res = {}

	if table.IsSequential(tab) then
		for k, v in ipairs(tab) do
			if func(k, v) then
				table.insert(res, v)
			end
		end
	else
		for k, v in pairs(tab) do
			if func(k, v) then
				res[k] = v
			end
		end
	end

	return res
end
