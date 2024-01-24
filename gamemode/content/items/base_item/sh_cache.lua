function ITEM:GetCache(key)
	return self.Cache[key]
end

function ITEM:WriteCache(key, val)
	self.Cache[key] = val

	return val
end

function ITEM:InvalidateCache(key)
	if key then
		self.Cache[key] = nil
	else
		table.Empty(self.Cache)
	end
end
