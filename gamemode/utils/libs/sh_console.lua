module("console", package.seeall)

Commands = Commands or {}
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
		Commands[v] = command
	end

	return command
end

function Rebuild()
	for command, commandObject in pairs(Commands) do
		concommand.Add(command, function(ply, _, _, args)
			Parse(ply, command, args)
		end, AutoComplete, table.concat(commandObject:AutoComplete(), " | "))
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

function Parse(ply, name, args)
	local command = Commands[name]

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

	if IsValid(ply) then
		if command.NoPlayer then
			Feedback(ply, "This command can only be run from the server console.")

			return
		end

		local ok, msg = command.CanAccess(ply)

		if not ok then
			Feedback(ply, msg or "You do not have access to do this.")

			return
		end

		command:Invoke(ply, args)
	else
		if command.NoConsole then
			Feedback(ply, "This command can only be run from an in-game client.")

			return
		end
	end
end

function AutoComplete(name, args)
	local command = Commands[name]

	return table.Add({name .. args}, command:AutoComplete())
end

function Feedback(ply, ...)
	if IsValid(ply) then
		ply:SendChat("ERROR", string.format(...))
	else
		MsgC(Color(200, 0, 0), "Error: ", string.format(...), "\n")
	end
end

function Command:Invoke(ply, args)
	local processedArgs = {}

	for k, arg in pairs(self.Arguments) do
		if #args < 1 then
			if arg.Optional then
				processedArgs[k] = arg.Fallback

				continue
			else
				Feedback(ply, "Missing argument #%s", k)

				return
			end
		end

		local ok, processed = arg.Callback(ply, args, k == #self.Arguments, arg.Options)

		if not ok then
			Feedback(ply, "Failed to parse argument #%s: %s", k, processed or "Unknown error")

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

if SERVER then
	netstream.Hook("Console", function(ply, payload)
		Parse(ply, payload.Name, payload.Args)
	end)
end

hook.Add("InitPostEntity", "Console", Rebuild)
hook.Add("OnReloaded", "Console", Rebuild)
