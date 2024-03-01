module("Combine.Flag", package.seeall)

local meta = FindMetaTable("Player")

List = List or {}
Class = Class or {}

_G.FLAG = Class
IncludeFile("class/base_combineflag.lua")
_G.FLAG = nil

function Add(name, data)
	List[name] = setmetatable(data, {__index = Class})
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
	return List[name] or Class
end

Character.AddVar("CombineFlag", {
	Accessor = "CombineFlag",
	Default = "",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:GetCombineFlagged() then
			if new == "" then
				ply:SetCombineFlagged(false)
			else
				hook.Run("PlayerSetup", ply)
			end
		end
	end
})

Character.AddVar("CombineFlagged", {
	Accessor = "CombineFlagged",
	Default = false,
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
		end
	end
})

hook.Add("GetCharacterFlagAttribute", "Plugin.Combine", function(flag, ply, name)
	if not ply:GetCombineFlagged() then
		return
	end

	return ply:GetCombineFlagAttribute(name)
end)

function meta:GetCombineFlagTable()
	return GetOrDefault(self:GetCombineFlag())
end

function meta:GetCombineFlagAttribute(name)
	return self:GetCombineFlagTable():GetAttribute(self, name)
end
