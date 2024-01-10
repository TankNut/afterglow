AddCSLuaFile()

IncludeFile("sv_database.lua")

function GM:Initialize()
	if SERVER then
		hook.Run("DatabaseInitialize")
	end
end
