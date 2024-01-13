AddCSLuaFile()

IncludeFolder("core/hooks")

IncludeFile("sv_database.lua")
IncludeFile("sh_player.lua")
IncludeFile("sh_character.lua")
IncludeFile("sh_admin.lua")
IncludeFile("sh_appearance.lua")
IncludeFile("sh_items.lua")
IncludeFile("sh_inventories.lua")

function GM:Initialize()
	if SERVER then
		database.Initialize()
	end
end
