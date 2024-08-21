CombineFlag = CombineFlag or {}

local meta = FindMetaTable("Player")

CombineFlag.List = List or {}
CombineFlag.Default = Default or {}

_G.FLAG = CombineFlag.Default
IncludeFile("class/base_combineflag.lua")
_G.FLAG = nil

function CombineFlag.Add(name, data)
	CombineFlag.List[name] = setmetatable(data, {__index = CombineFlag.Default})
end

function CombineFlag.AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.FLAG = {}

	IncludeFile(path)
	CombineFlag.Add(name, FLAG)

	_G.FLAG = nil
end

function CombineFlag.AddFolder(basePath)
	basePath = engine.ActiveGamemode() .. "/gamemode/" .. basePath

	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			CombineFlag.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function CombineFlag.Get(name)
	return CombineFlag.List[name]
end

function CombineFlag.GetOrDefault(name)
	return CombineFlag.List[name] or Default
end

hook.Add("GetCharacterFlagAttribute", "Plugin.Combine.CombineFlag", function(flag, ply, name)
	if not ply:GetCombineFlagged() then
		return
	end

	return ply:GetCombineFlagAttribute(name)
end)

if SERVER then
	hook.Add("PostLoadCharacter", "Plugin.Combine.CombineFlag", function(ply, id)
		if ply:GetCombineFlagged() then
			hook.Run("OnCombineFlag", ply, true)
		end
	end)

	hook.Add("UnloadCharacter", "Plugin.Combine.CombineFlag", function(ply, id)
		if ply:GetCombineFlagged() then
			hook.Run("OnCombineUnflag", ply, true)
		end
	end)
end

function meta:HasCombineFlag()
	return self:GetCombineFlag() != ""
end

function meta:GetCombineFlagTable()
	return CombineFlag.GetOrDefault(self:GetCombineFlag())
end

function meta:GetCombineFlagAttribute(name)
	return self:GetCombineFlagTable():GetAttribute(self, name)
end
