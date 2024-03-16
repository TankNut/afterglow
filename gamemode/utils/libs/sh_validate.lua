Validate = Validate or {}
Validate.Rules = Validate.Rules or {}

function Validate.AddRule(name, callback, checkNil)
	Validate.Rules[name] = setmetatable({
		Callback = callback,
		CheckNil = checkNil
	}, {
		__call = function(_, ...)
			return {
				Name = name,
				Args = {...}
			}
		end
	})

	Validate[name] = Validate.Rules[name]
end

function Validate.Value(val, rules)
	if rules.Name then
		rules = {rules}
	end

	for k, v in pairs(rules) do
		local rule = Validate.Rules[v.Name]

		if val == nil and not rule.CheckNil then
			continue
		end

		local ok, err = rule.Callback(val, unpack(v.Args))

		if not ok then
			return false, err
		end
	end

	return true, val
end

function Validate.Multi(tab, rules)
	Cache = Weakref(tab)

	local ret = {}

	for k, v in pairs(tab) do
		local rule = rules[k] or rules["*"]

		if not rule then
			continue
		end

		local ok, err = Validate.Value(v, rule)

		if not ok then
			return false, k, err
		end

		ret[k] = v
	end

	-- Check for missing keys
	for k, v in pairs(rules) do
		if k != "*" and not ret[k] then
			local ok, err = Validate.Value(nil, v)

			if not ok then
				return false, k, err
			end
		end
	end

	return true, ret
end

Validate.AddRule("Required", function(val)
	return val != nil, "Cannot be nil"
end, true)

Validate.AddRule("Is", function(val, types)
	local id = TypeID(val)

	if istable(types) then
		for _, v in pairs(types) do
			if id == v then
				return true
			end
		end

		return false, "Type mismatch"
	else
		return id == types, "Type mismatch"
	end
end, true)

Validate.AddRule("Number", function(val) return isnumber(val), "Is not a number" end)
Validate.AddRule("String", function(val) return isstring(val), "Is not a string" end)
Validate.AddRule("Bool", function(val) return isbool(val), "Is not a boolean" end)

Validate.AddRule("Min", function(val, min)
	if isstring(val) then
		return #val >= min, string.format("Has to be at least %s characters long", min)
	else
		return val >= min, "Has to be at least " .. min
	end
end)

Validate.AddRule("Max", function(val, max)
	if isstring(val) then
		return #val <= max, string.format("Cannot be more than %s characters long", max)
	else
		return val <= max, "Cannot be more than " .. max
	end
end)

Validate.AddRule("AllowedCharacters", function(val, characters)
	local lookup = table.Lookup(string.Explode("", characters))
	local bad = {}

	for _, v in pairs(string.Explode("", val)) do
		if not lookup[v] then
			bad[v] = true
		end
	end

	if table.Count(bad) > 0 then
		local badCharacters = table.GetKeys(bad)

		table.sort(badCharacters)

		return false, "Cannot contain the following characters: " .. table.concat(badCharacters)
	end

	return true
end)

Validate.AddRule("Callback", function(val, callback)
	return callback(val)
end)

Validate.AddRule("InList", function(val, tab)
	return table.HasValue(tab, val)
end)

local function getProperty(val, index, ...)
	if index == nil then
		return val
	end

	if index == "#" then
		return #val
	end

	local property = val[index]

	if isfunction(property) then
		return property(val, ...)
	end

	return property
end

Validate.AddRule("True", function(val, property, ...) return tobool(getProperty(val, property, ...)) end)
Validate.AddRule("False", function(val, property, ...) return not tobool(getProperty(val, property, ...)) end)

Validate.AddRule("Equals", function(val, other, property, ...) return getProperty(val, property, ...) == other end)
Validate.AddRule("Differs", function(val, other, property, ...) return getProperty(val, property, ...) != other end)

Validate.AddRule("LessThan", function(val, other, property, ...) return getProperty(val, property, ...) < other end)
Validate.AddRule("LessThanEquals", function(val, other, property, ...) return getProperty(val, property, ...) <= other end)

Validate.AddRule("GreaterThan", function(val, other, property, ...) return getProperty(val, property, ...) > other end)
Validate.AddRule("GreaterThanEquals", function(val, other, property, ...) return getProperty(val, property, ...) >= other end)
