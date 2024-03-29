module("Combine.Flag", package.seeall)

local meta = FindMetaTable("Player")

List = List or {}
Default = Default or {}

_G.FLAG = Default
IncludeFile("class/base_combineflag.lua")
_G.FLAG = nil

function Add(name, data)
	List[name] = setmetatable(data, {__index = Default})
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

	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
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
	return List[name] or Default
end

hook.Add("GetCharacterFlagAttribute", "Plugin.Combine", function(flag, ply, name)
	if not ply:GetCombineFlagged() then
		return
	end

	return ply:GetCombineFlagAttribute(name)
end)

if SERVER then
	hook.Add("PostLoadCharacter", "Plugin.Combine", function(ply, id)
		if ply:GetCombineFlagged() then
			hook.Run("OnCombineFlag", ply, true)
		end
	end)

	hook.Add("UnloadCharacter", "Plugin.Combine", function(ply, id)
		if ply:GetCombineFlagged() then
			hook.Run("OnCombineUnflag", ply, true)
		end
	end)
end

function meta:HasCombineFlag()
	return self:GetCombineFlag() != ""
end

function meta:GetCombineFlagTable()
	return GetOrDefault(self:GetCombineFlag())
end

function meta:GetCombineFlagAttribute(name)
	return self:GetCombineFlagTable():GetAttribute(self, name)
end
