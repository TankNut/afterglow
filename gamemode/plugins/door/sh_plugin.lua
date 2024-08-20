-- This plugin uses NW and not Netvar because of PVS issues, don't try to change it
DOOR_SEPARATE = 0
DOOR_MASTER = 1
DOOR_BOTH = 2

Door = Door or {}
Door.Types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

Door.All = Door.All or {}
Door.Vars = Door.Vars or {}

function Door.Iterator()
	return pairs(Door.All)
end

IncludeFile("sh_door.lua")
IncludeFile("sh_meta.lua")
IncludeFile("sh_vars.lua")

IncludeFolder("plugins/door/vgui")

hook.Add("LoadPluginContent", "Plugin.Doors", function()
	Hud.AddFolder("plugins/door/hudelements")
end)
