Combine = Combine or {}

Combine.DefaultTeam = TEAM_COMBINE

IncludeFile("sh_combineflag.lua")
IncludeFile("sh_vars.lua")
IncludeFile("sh_hooks.lua")

function Combine.GetCID(seed)
	if seed then
		math.randomseed(seed)
	end

	local str = ""

	for i = 1, 5 do
		str = str .. math.random(0, 9)
	end

	return str
end

hook.Add("LoadPluginContent", "Plugin.Combine", function()
	Combine.Flag.AddFolder("content/combineflags")

	Chat.AddFolder("plugins/combine/chatcommands")
	Command.AddFolder("plugins/combine/commands")
	Hud.AddFolder("plugins/combine/hudelements")
end)

if SERVER then
	hook.Add("PreCreateCharacter", "Plugin.Combine", function(ply, fields)
		fields.cid = Combine.GetCID()
	end)
end
