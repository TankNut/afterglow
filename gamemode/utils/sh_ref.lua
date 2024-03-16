local meta = {__mode = "v", __call = function(self)
	return self[1]
end}

function Weakref(data)
	return setmetatable({data}, meta)
end
