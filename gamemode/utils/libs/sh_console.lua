module("console", package.seeall)

List = List or {}

Command = Command or {}

function AddCommand(commands, callback)
	local command = setmetatable({
		Callback = callback,
		Description = "No description specified",
		Arguments = {},
		Realm = SERVER
	}, {
		__index = Command
	})

	if not istable(commands) then
		commands = {commands}
	end

	for _, v in pairs(commands) do
		List[v] = command
	end

	return command
end

function Rebuild()
	for command in pairs(List) do
		concommand.Add(command, function(ply, _, _, args)
			Invoke(ply, command, args)
		end, AutoComplete)
	end
end

function Parser(name, callback)
	console[name] = function(options, argName)
		return {
			Callback = callback,
			Name = argName and argName:lower(),
			Type = name:lower(),
			Options = options or {}
		}
	end
end

function Trim(str)
	return str:match("^()%s*$") and "" or str:match("^%s*(.*%S)")
end

function Split(str)
	str = str:Trim()

	local args = {}
	local currentPos = 1
	local inQuote = false
	local len = #str

	while inQuote or currentPos <= len do
		local pos = str:find("\"", currentPos, true)
		local prefix = str:sub(currentPos, (pos or 0) - 1)

		if not inQuote then
			local trim = Trim(prefix)

			if trim != "" then
				table.Add(args, string.Explode("%s+", trim, true))
			end
		else
			table.insert(args, prefix)
		end

		if pos != nil then
			currentPos = pos + 1
			inQuote = not inQuote
		else
			break
		end
	end

	return args
end

function Invoke(ply, name, args)
	local command = List[name]

	if not command then
		return
	end

	if CLIENT and not command.Realm then
		netstream.Send("Console", {
			Name = name,
			Args = args
		})

		return
	end

	if isstring(args) then
		args = Split(args)
	end

	if (not IsValid(ply) or command.CanAccess(ply)) and command.Realm then
		command:Invoke(ply, args)
	end
end

function AutoComplete(name, args)
	local command = List[name]

	return table.Add({name .. args}, command:AutoComplete())
end

function Command:Invoke(ply, args)
	if IsValid(ply) then
		if self.NoPlayer then
			print("Attempt to run function as player")

			return
		end
	else
		if self.NoConsole then
			print("Attempt to run function as console")

			return
		end
	end

	local processedArgs = {}

	for k, arg in pairs(self.Arguments) do
		if #args < 1 then
			if arg.Optional then
				processedArgs[k] = arg.Fallback

				continue
			else
				print("Error missing argument: ", k)

				return
			end
		end

		local ok, processed = arg.Callback(ply, args, k == #self.Arguments, arg.Options)

		if not ok then
			print(string.format("Error parsing argument #%s: %s", k, processed or "No error specified"))

			return
		end

		processedArgs[k] = processed
	end

	self.Callback(ply, unpack(processedArgs))
end

function Command:AutoComplete()
	return {"Description: " .. self.Description, self:GetUsage()}
end

function Command.CanAccess(ply)
	return true
end

function Command:GetUsage()
	if #self.Arguments == 0 then
		return
	end

	local args = {}

	for k, arg in pairs(self.Arguments) do
		local name = arg.Name and string.format("%s|%s", arg.Name, arg.Type) or arg.Type

		if arg.Optional then
			local fallback = ""

			if arg.Fallback then
				fallback = " = " .. (arg.FallbackText or arg.Fallback)
			end

			table.insert(args, string.format("[%s%s]", name, fallback))
		else
			table.insert(args, name)
		end
	end

	return "Usage: " .. table.concat(args, ", ")
end

function Command:AddParameter(arg)
	table.insert(self.Arguments, arg)
end

function Command:AddOptional(arg, fallback, fallbackText)
	arg.Optional = true
	arg.Fallback = fallback
	arg.FallbackText = fallbackText

	table.insert(self.Arguments, arg)
end

function Command:SetAccess(callback)
	self.CanAccess = callback
end

function Command:SetDescription(new)
	self.Description = new
end

function Command:SetRealm(realm)
	self.Realm = realm
end

function Command:SetConsoleOnly()
	self.NoPlayer = true
end

function Command:SetPlayerOnly()
	self.NoConsole = true
end

local boolValues = {
	f = false
}

Parser("Bool", function(ply, args, last, options)
	local val = table.remove(args, 1)
	local bool = boolValues[val]

	if bool == nil then
		bool = tobool(val)
	end

	return true, bool
end)

Parser("String", function(ply, args, last, options)
	return true, last and table.concat(args, " ") or table.remove(args, 1)
end)

Parser("Number", function(ply, args, last, options)
	local num = tonumber(table.remove(args, 1))

	if num == nil then
		return false, "Invalid number"
	end

	return true, num
end)

Parser("Time", function(ply, args, last, options)
	local duration = duration.Parse(table.remove(args, 1), options.Format)

	if duration == nil then
		return false, "Invalid duration"
	end

	return true, duration
end)

if SERVER then
	netstream.Hook("Console", function(ply, payload)
		Invoke(ply, payload.Name, payload.Args)
	end)
end

hook.Add("InitPostEntity", "Console", Rebuild)
hook.Add("OnReloaded", "Console", Rebuild)
