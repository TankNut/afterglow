Console = Console or {}
Console.Commands = {}

local writeLog = Log.Category("Console")

-- Not sure if this is the best spot for this
local printColor = Color(200, 200, 200)

function Console.Print(...)
	MsgC(printColor, ...)
end

function Console.PrintLine(...)
	Console.Print(...)
	Msg("\n")
end

function Console.AddCommand(commands, callback)
	local command = setmetatable({
		Callback = callback,
		Description = "No description specified",
		Arguments = {},
		Realm = SERVER
	}, {
		__index = Console.Command
	})

	commands = istable(commands) and commands or {commands}

	for _, v in pairs(commands) do
		Console.Commands[v] = command
	end

	return command
end

function Console.Rebuild()
	for command, commandObject in pairs(Console.Commands) do
		concommand.Add(command, function(ply, _, _, args)
			Console.Parse(ply, command, args)
		end, Console.AutoComplete, table.concat(commandObject:AutoComplete(), " | "))
	end
end

hook.Add("InitPostEntity", "Console", Console.Rebuild)
hook.Add("OnReloaded", "Console", Console.Rebuild)

function Console.Parser(name, callback)
	Console[name] = function(options, argName)
		return {
			Callback = callback,
			Name = argName and argName:lower(),
			Type = name:lower(),
			Options = options or {}
		}
	end
end

function Console.PlayerName(ply)
	return IsValid(ply) and ply:Nick() or "CONSOLE"
end

function Console.Feedback(ply, class, ...)
	local args = {...}

	for k, v in pairs(args) do
		if isentity(v) then
			args[k] = Console.PlayerName(v)
		end
	end

	if IsValid(ply) then
		ply:SendChat(class, string.format(unpack(args)))
	else
		local classTable = Chat.List[class]
		local color = classTable.ConsoleColor or classTable.Color
		local prefix = class == "ERROR" and "Error: " or ""

		MsgC(color, prefix, string.format(unpack(args)), "\n")
	end
end

function Console.Trim(str)
	return str:match("^()%s*$") and "" or str:match("^%s*(.*%S)")
end

function Console.Split(str)
	str = str:Trim()

	local args = {}
	local currentPos = 1
	local inQuote = false
	local len = #str

	while inQuote or currentPos <= len do
		local pos = str:find("\"", currentPos, true)
		local prefix = str:sub(currentPos, (pos or 0) - 1)

		if not inQuote then
			local trim = Console.Trim(prefix)

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

function Console.Parse(ply, name, str)
	local command = Console.Commands[name]

	if not command then
		return
	end

	if CLIENT and not command.Realm then
		Netstream.Send("Console", {
			Name = name,
			Args = str
		})

		return
	end

	local args = Console.Split(str)

	if IsValid(ply) then
		if command.NoPlayer then
			writeLog("Rejected: %s -> %s %s (NoPlayer)", ply, name, str)
			Console.Feedback(ply, "ERROR", "This command can only be run from the server console.")

			return
		end

		local ok, msg = command.CanAccess(ply)

		if not ok then
			msg = msg or "You do not have access to this command."

			writeLog("Rejected: %s -> %s %s (%s)", ply, name, str, msg)
			Console.Feedback(ply, "ERROR", msg)

			return
		end

		writeLog("Invoke: %s -> %s %s", ply, name, str)

		command:Invoke(ply, args)
	else
		if command.NoConsole then
			writeLog("Rejected: CONSOLE -> %s %s (NoConsole)", name, str)
			Console.Feedback(ply, "ERROR", "This command can only be run from an in-game client.")

			return
		end

		writeLog("Invoke: CONSOLE -> %s %s", name, str)

		command:Invoke(ply, args)
	end
end

if SERVER then
	Netstream.Hook("Console", function(ply, payload)
		Console.Parse(ply, payload.Name, payload.Args)
	end)
end

function Console.AutoComplete(name, args)
	local command = Console.Commands[name]

	return table.Add({name .. args}, command:AutoComplete())
end

local Command = {}

function Command:Invoke(ply, args)
	local processedArgs = {}

	for k, arg in pairs(self.Arguments) do
		if #args < 1 then
			if arg.Optional then
				processedArgs[k] = arg.Fallback

				continue
			else
				Console.Feedback(ply, "ERROR", "Missing argument #%s (%s)", k, arg.Name or arg.Type)

				return
			end
		end

		local ok, processed = arg.Callback(ply, args, k == #self.Arguments, arg.Options)

		if not ok then
			if not arg.Options.Silent then
				Console.Feedback(ply, "ERROR", "Failed to parse argument #%s (%s): %s", k, arg.Name or arg.Type, processed or "Unknown error")
			end

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

			if arg.Fallback or arg.FallbackText then
				fallback = " = " .. (arg.FallbackText or tostring(arg.Fallback))
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

Console.Command = Command
