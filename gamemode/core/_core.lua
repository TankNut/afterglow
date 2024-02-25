AddCSLuaFile()

IncludeFile("sh_config.lua")

IncludeFile("sv_database.lua")

IncludeFile("sh_playervar.lua")
IncludeFile("sh_character.lua")
IncludeFile("sh_admin.lua")
IncludeFile("sh_appearance.lua")
IncludeFile("sh_item.lua")
IncludeFile("sh_inventory.lua")
IncludeFile("sh_interface.lua")
IncludeFile("sh_progress.lua")
IncludeFile("sh_characterflag.lua")
IncludeFile("sh_damage.lua")
IncludeFile("sv_player.lua")
IncludeFile("sh_animtable.lua")
IncludeFile("sh_hull.lua")
IncludeFile("sh_player.lua")
IncludeFile("sh_command.lua")
IncludeFile("sh_chat.lua")
IncludeFile("sh_language.lua")
IncludeFile("sh_team.lua")
IncludeFile("sh_badge.lua")
IncludeFile("sh_template.lua")
IncludeFile("sh_plugin.lua")

IncludeFile("cl_fonts.lua")
IncludeFile("cl_skin.lua")

IncludeFolder("core/hooks")
IncludeFolder("core/vars")
IncludeFolder("core/meta")

IncludeFolder("core/vgui")
IncludeFolder("core/gui")
IncludeFolder("core/gui/playermenu")

IncludeFolder("core/net")


if SERVER then
	for _, v in pairs(GM.Config.Content) do
		resource.AddWorkshop(v)
	end
end


function GM:Initialize()
	if SERVER then
		Database.Initialize()
	end
end


function GM:OnReloaded()
	if SERVER then
		for _, ply in player.Iterator() do
			if ply:HasCharacter() then
				ply:UpdateAppearance()
				ply:UpdateArmor()
				ply:UpdateName()
			end
		end
	end
end
