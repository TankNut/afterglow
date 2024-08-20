TAB_LOOC	= 2^1
TAB_OOC		= 2^2
TAB_IC		= 2^3
TAB_ADMIN	= 2^4
TAB_PM		= 2^5
TAB_RADIO	= 2^6

Chat = Chat or {
	Class = {},
	List = {},
	ConsoleCommands = {},
	Commands = {},
	Aliases = {}
}

local entity = FindMetaTable("Entity")
local meta = FindMetaTable("Player")

_G.CLASS = Chat.Class
IncludeFile("class/base_chatcommand.lua")
_G.CLASS = nil

function Chat.Add(data)
	Chat.List[data.Name] = setmetatable(data, {
		__index = Chat.Class
	})

	for _, v in pairs(data.Commands) do
		Chat.Commands[v] = data
	end

	for _, v in pairs(data.Aliases) do
		Chat.Aliases[v] = data.Commands[1]
	end
end

function Chat.AddFile(path)
	_G.CLASS = {}

	IncludeFile(path)
	Chat.Add(CLASS)

	_G.CLASS = nil
end

function Chat.AddFolder(basePath)
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			Chat.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/" .. basePath)
end

function Chat.AddConsoleCommand(names, command)
	if not istable(names) then
		names = {names}
	end

	for _, name in pairs(names) do
		Chat.ConsoleCommands[name] = command
	end
end

function Chat.Process(ply, str)
	for k, v in pairs(Chat.Aliases) do
		if string.find(str, k, 1, true) == 1 then
			str = string.format("/%s %s", v, string.sub(str, #k + 1))

			break
		end
	end

	local lang, command, args = str:match("^[/!](%w+)%.(%w+)%s*(.-)%s*$")

	if not Language.Lookup[lang] then
		lang = ply:GetActiveLanguage()
		command, args = str:match("^[/!](%w+)%s*(.-)%s*$")

		if not command then
			command, args = "say", str:Trim()
		end
	end

	if lang then
		lang = lang:lower()
	end

	return lang, command:lower(), args
end

function Chat.GetTargets(pos, range, muffledRange, withEntities)
	local maxRange = math.max(range, muffledRange)
	local targets = {}

	for _, ent in pairs(ents.FindInSphere(pos, maxRange)) do
		if not ent:IsPlayer() and (not withEntities or not ent.OnHear) then
			continue
		end

		local dist = ent:GetPos():DistToSqr(pos)

		if ent:CanHear(pos) then
			if dist < maxRange * maxRange then
				table.insert(targets, ent)
			end
		elseif dist <= muffledRange then
			table.insert(targets, ent)
		end
	end
end

function Chat.Parse(ply, str)
	local lang, cmd, args = Chat.Process(ply, str)

	if CLIENT then
		if Chat.ConsoleCommands[cmd] then
			Console.Parse(LocalPlayer(), Chat.ConsoleCommands[cmd], args)
		else
			Netstream.Send("ParseChat", str)
		end
	else
		local command = Chat.Commands[cmd]

		if not command then
			ply:SendChat("ERROR", string.format("Unknown command: '%s'", cmd))

			return ""
		end

		command:Handle(ply, lang, cmd, args)
	end

	return ""
end

if CLIENT then
	function Chat.Show()
		Interface.GetGroup("Chat"):Show()
	end

	function Chat.Hide()
		Interface.GetGroup("Chat"):Hide()
	end

	function Chat.Receive(name, data)
		local command = Chat.List[name]
		local message, consoleMessage = command:OnReceive(data)

		if isstring(message) then
			Interface.GetGroup("Chat"):AddMessage(message, consoleMessage, command.Tabs)
		end
	end
end

if SERVER then
	function Chat.Send(name, data, targets)
		if isstring(data) then
			data = {Text = data}
		end

		data.__Type = name

		Netstream.Send("SendChat", targets, data)
	end
end

if CLIENT then
	Netstream.Hook("SendChat", function(payload)
		Chat.Receive(payload.__Type, payload)
	end)

	hook.Add("InitPostEntity", "Chat", function()
		Interface.OpenGroup("Chat", "Chat")
	end)

	hook.Add("OnReloaded", "Chat", function()
		local buffer = Interface.GetGroup("Chat"):ExportBuffer()

		Interface.OpenGroup("Chat", "Chat"):ImportBuffer(buffer)
	end)

	hook.Add("PlayerBindPress", "Chat", function(ply, bind, down)
		if down and string.find(bind, "messagemode") then
			Chat.Show()

			return true
		end
	end)
end

if SERVER then
	Netstream.Hook("ParseChat", Chat.Parse)
	hook.Add("PlayerSay", "Chat", Chat.Parse)
end

function entity:CanHear(pos)
	return util.TraceLine({
		start = self:IsPlayer() and self:EyePos() or self:WorldSpaceCenter(),
		endpos = pos,
		filter = self,
		mask = MASK_OPAQUE
	}).Fraction == 1
end

function meta:SendChat(name, data)
	if CLIENT then
		if self != LocalPlayer() then
			error("Attempt to SendChat to a non-local player")
		end

		Chat.Receive(name, data)
	else
		Chat.Send(name, data, self)
	end
end
