module("CharacterFlag", package.seeall)

local meta = FindMetaTable("Player")

List = List or {}

function Add(name, data)
	if name != "default" then
		setmetatable(data, {__index = List.default})
	else
		Default = data
	end

	data.ID = name

	List[name] = data
end

function AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.FLAG = {}

	IncludeFile(path)
	Add(name, FLAG)

	_G.FLAG = nil
end

function AddFolder(basePath)
	basePath = engine.ActiveGamemode() .. "/gamemode/" .. basePath

	AddFile(basePath .. "/default.lua")

	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v == "default.lua" or v:GetExtensionFromFilename() != "lua" then
				continue
			end

			AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function Get(name)
	return List[name]
end

function GetOrDefault(name)
	return List[name] or List.default
end

function meta:GetCharacterFlagTable()
	return GetOrDefault(self:GetCharacterFlag())
end

function meta:GetCharacterFlagAttribute(name)
	local flag = self:GetCharacterFlagTable()

	return flag:GetAttribute(self, name)
end
