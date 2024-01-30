AddCSLuaFile()

IncludeFile("sh_config.lua")

IncludeFile("sv_database.lua")
IncludeFile("sh_playervars.lua")
IncludeFile("sh_character.lua")
IncludeFile("sh_admin.lua")
IncludeFile("sh_appearance.lua")
IncludeFile("sh_item.lua")
IncludeFile("sh_inventory.lua")
IncludeFile("sh_equipment.lua")
IncludeFile("sh_interface.lua")
IncludeFile("sh_progress.lua")
IncludeFile("sh_characterflags.lua")

IncludeFile("cl_fonts.lua")
IncludeFile("cl_skin.lua")

IncludeFolder("core/vgui")
IncludeFolder("core/gui")
IncludeFolder("core/gui/playermenu")

IncludeFolder("core/hooks")
IncludeFolder("core/net")

function GM:Initialize()
	if SERVER then
		Database.Initialize()
	end
end

function GM:OnReloaded()
	if SERVER then
		for _, ply in pairs(player.GetAll()) do
			if ply:HasCharacter() then
				ply:UpdateAppearance()
				ply:UpdateArmor()
			end
		end
	end

	for _, item in pairs(Item.All) do
		item:InvalidateCache()
	end
end
