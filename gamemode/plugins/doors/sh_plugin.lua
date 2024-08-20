-- This plugin uses NW and not Netvar because of PVS issues, don't try to change it
DOOR_SEPARATE = 0
DOOR_MASTER = 1
DOOR_BOTH = 2

Doors = Doors or {}
Doors.Types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

Doors.All = Doors.All or {}
Doors.Vars = Doors.Vars or {}

function Doors.Iterator()
	return pairs(Doors.All)
end

IncludeFile("sh_doors.lua")
IncludeFile("sh_meta.lua")
IncludeFile("sh_vars.lua")

IncludeFolder("plugins/doors/vgui")

hook.Add("LoadPluginContent", "Plugin.Doors", function()
	Hud.AddFolder("plugins/doors/hudelements")
end)
