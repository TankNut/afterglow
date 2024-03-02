module("Combine", package.seeall)

DefaultTeam = TEAM_COMBINE

IncludeFile("sh_combineflag.lua")
IncludeFile("sh_vars.lua")

function GetCID(seed)
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
end)
