AddCSLuaFile()

IncludeFile("sh_config.lua")

IncludeFile("sv_database.lua")
IncludeFile("sh_playervars.lua")
IncludeFile("sh_character.lua")
IncludeFile("sh_admin.lua")
IncludeFile("sh_appearance.lua")
IncludeFile("sh_item.lua")
IncludeFile("sh_inventory.lua")

IncludeFile("sh_interface.lua")
IncludeFile("cl_skin.lua")
IncludeFolder("core/vgui")
IncludeFolder("core/gui")

IncludeFolder("core/hooks")
IncludeFolder("core/net")

function GM:Initialize()
	if SERVER then
		Database.Initialize()
	end
end
