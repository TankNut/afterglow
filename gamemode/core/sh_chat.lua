TAB_LOOC	= 2^1
TAB_OOC		= 2^2
TAB_IC		= 2^3
TAB_ADMIN	= 2^4
TAB_PM		= 2^5
TAB_RADIO	= 2^6

module("Chat", package.seeall)

Class = Class or {}

List = List or {}

ConsoleCommands = ConsoleCommands or {}
Commands = Commands or {}
Aliases = Aliases or {}

_G.CLASS = Class

IncludeFile("class/sh_chatcommand.lua")

_G.CLASS = nil

function Register(data)
	setmetatable(data, {
		__index = Class
	})

	List[data.Name] = data

	for _, v in pairs(data.Commands) do
		Commands[v] = data
	end

	for _, v in pairs(data.Aliases) do
		Aliases[v] = data.Commands[1]
	end
end

function AddConsoleCommand(names, command)
	if not istable(names) then
		names = {names}
	end

	for _, name in pairs(names) do
		ConsoleCommands[name] = command
	end
end

function LoadFromFile(path)
	_G.CLASS = {}

	IncludeFile(path)

	Register(CLASS)

	_G.CLASS = nil
end

function LoadCommands()
	local basePath = engine.ActiveGamemode() .. "/gamemode/content/chatcommands"
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			LoadFromFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function Process(str)
	for k, v in pairs(Aliases) do
		if string.find(str, k, 1, true) == 1 then
			str = string.format("/%s %s", v, string.sub(str, #k + 1))

			break
		end
	end

	local lang, command, args = str:match("^[/!](%w+)%.(%w+)%s*(.-)%s*$")

	if not lang then
		lang = "eng"
		command, args = str:match("^[/!](%w+)%s*(.-)%s*$")

		if not command then
			command, args = "say", str:Trim()
		end
	end

	return lang:lower(), command:lower(), args
end

function GetTargets(pos, range, muffledRange, withEntities)
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

function Parse(ply, str)
	local lang, cmd, args = Process(str)

	if CLIENT then
		if ConsoleCommands[cmd] then
			console.Parse(LocalPlayer(), ConsoleCommands[cmd], args)
		else
			netstream.Send("ParseChat", str)
		end
	else
		local command = Commands[cmd]

		if not command then
			ply:SendChat("ERROR", string.format("Unknown command: '%s'", cmd))

			return ""
		end

		command:Handle(ply, lang, cmd, args)
	end

	return ""
end

if CLIENT then
	function Show()
		Interface.GetGroup("Chat"):Show()
	end

	function Hide()
		Interface.GetGroup("Chat"):Hide()
	end

	function Add(name, data)
		local command = List[name]
		local message, consoleMessage = command:OnReceive(data)

		if isstring(message) then
			Interface.GetGroup("Chat"):AddMessage(message, consoleMessage, command.Tabs)
		end
	end
else
	function Send(name, data, targets)
		if isstring(data) then
			data = {Text = data}
		end

		data.__Type = name

		netstream.Send("SendChat", targets, data)
	end
end

local meta = FindMetaTable("Entity")

function meta:CanHear(pos)
	return util.TraceLine({
		start = self:IsPlayer() and self:EyePos() or self:WorldSpaceCenter(),
		endpos = pos,
		filter = self,
		mask = MASK_OPAQUE
	}).Fraction == 1
end

local plyMeta = FindMetaTable("Player")

if CLIENT then
	netstream.Hook("SendChat", function(payload)
		Add(payload.__Type, payload)
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
			Show()

			return true
		end
	end)

	function plyMeta:SendChat(name, data)
		if self != LocalPlayer() then
			error("Attempt to SendChat to another player")
		end

		Add(name, data)
	end
else
	function plyMeta:SendChat(name, data)
		Send(name, data, self)
	end

	netstream.Hook("ParseChat", Parse)

	hook.Add("PlayerSay", "Chat", Parse)
end
