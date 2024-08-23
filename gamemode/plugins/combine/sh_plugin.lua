Combine = Combine or {}

Combine.DefaultTeam = TEAM_COMBINE

IncludeFile("sh_character_vars.lua")
IncludeFile("sh_combineflag.lua")
IncludeFile("sh_content.lua")
IncludeFile("sh_hooks.lua")

function Combine.GetCID(seed)
	if seed then
		math.randomseed(seed)
	end

	local str = ""

	for i = 1, 4 do
		str = str .. math.random(0, 9)
	end

	return str
end

if SERVER then
	hook.Add("PreCreateCharacter", "Plugin.Combine", function(ply, fields)
		fields[Character.VarToField("CID")] = Combine.GetCID()
	end)
end
