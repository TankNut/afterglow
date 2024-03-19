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

function IncludeFolder(dir, baseDir, realm)
	baseDir = baseDir or engine.ActiveGamemode() .. "/gamemode/"

	for _, v in pairs(file.Find(baseDir .. dir .. "/*.lua", "LUA")) do
		IncludeFile(baseDir .. dir .. "/" .. v, realm)
	end
end

local moduleFiles = {
	"cl_module.lua",
	"sh_module.lua",
	"sv_module.lua"
}

function IncludeModule(folder)
	local baseDir = engine.ActiveGamemode() .. "/gamemode/core/modules/" .. folder .. "/"

	for _, path in pairs(moduleFiles) do
		if file.Exists(baseDir .. path, "LUA") then
			IncludeFile(baseDir .. path)
		end
	end
end

IncludeFile("sh_memoize.lua")

-- Extensions
IncludeFolder("utils/extensions")

-- Everything else
IncludeFile("libs/sh_log.lua")
IncludeFile("libs/sv_mysql.lua")

IncludeFile("libs/sh_validate.lua")
IncludeFile("libs/sh_pack.lua")
IncludeFile("libs/sh_queue.lua")
IncludeFile("libs/sh_netstream.lua")
IncludeFile("libs/sh_request.lua")
IncludeFile("libs/sh_netvar.lua")
IncludeFile("libs/cl_scribe.lua")
IncludeFile("libs/sh_console.lua")

IncludeFile("sh_player_ready.lua")
IncludeFile("sh_ref.lua")
IncludeFile("sh_duration.lua")
