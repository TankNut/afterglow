module("CharacterFlags", package.seeall)

local meta = FindMetaTable("Player")

List = List or {}

Character.RegisterVar("Flag", {
	Default = "default",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
		end
	end
})

function Register(name, data)
	if name != "default" then
		setmetatable(data, {__index = List.default})
	else
		Default = data
	end

	List[name] = data
end

function Get(name)
	return List[name]
end

function GetOrDefault(name)
	return List[name] or List.default
end

function LoadFromFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.FLAG = {}

	IncludeFile(path)

	Register(name, FLAG)

	_G.FLAG = nil
end

function LoadFlags()
	local basePath = engine.ActiveGamemode() .. "/gamemode/content/characterflags"

	LoadFromFile(basePath .. "/default.lua")

	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v == "default.lua" or v:GetExtensionFromFilename() != "lua" then
				continue
			end

			LoadFromFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function meta:GetCharacterFlagTable()
	return GetOrDefault(self:GetCharacterFlag())
end

function meta:GetCharacterFlagAttribute(name)
	local flag = self:GetCharacterFlagTable()

	return flag:GetAttribute(name, self)
end
