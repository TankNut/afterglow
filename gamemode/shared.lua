-- 09/01/2024

DeriveGamemode("sandbox")

GM.Name = "Afterglow"
GM.Author = "TankNut"

-- underscored files are for file inclusion/base level stuff
-- _utils.lua includes our IncludeFile global, so we only have to include() manually here and in (cl_)init.lua
include("utils/_utils.lua")

GM.Config = GM.Config or {}

IncludeFolder("config")

IncludeFile("core/_core.lua")
IncludeFile("content/sh_teams.lua")

Item.LoadItems()
CharacterFlags.LoadFlags()
Command.Load()
Chat.LoadCommands()
