AddCSLuaFile()

-- Include code, put it as close as possible to init so we can start using it right away
local realms = {
	cl = "client",
	sv = "server"
}

function string.GetRealmFromFilename(path)
	return realms[path:GetFileFromFilename():match("^(%a-)_")] or "shared"
end

local includes = {
	client = {true, CLIENT},
	server = {false, SERVER},
	shared = {true, true}
}

function IncludeFile(path, realm)
	local addCS, doInclude = unpack(includes[realm or path:GetRealmFromFilename()])

	if addCS then
		AddCSLuaFile(path)
	end

	if doInclude then
		return include(path)
	end
end

function IncludeFolder(dir, baseDir)
	baseDir = baseDir or engine.ActiveGamemode() .. "/gamemode/"

	for _, v in pairs(file.Find(baseDir .. dir .. "/*.lua", "LUA")) do
		IncludeFile(baseDir .. dir .. "/" .. v)
	end
end

-- Extensions
IncludeFolder("utils/extensions")

-- Everything else
IncludeFile("libs/sh_log.lua")
IncludeFile("libs/sv_mysql.lua")

IncludeFile("libs/sh_pack.lua")
IncludeFile("libs/sh_queue.lua")
IncludeFile("libs/sh_netstream.lua")
IncludeFile("libs/sh_netvar.lua")

IncludeFile("sh_player_ready.lua")
IncludeFile("sh_ref.lua")
