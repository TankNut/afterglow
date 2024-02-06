module("Command", package.seeall)

function Load()
	local basePath = engine.ActiveGamemode() .. "/gamemode/content/commands"
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			IncludeFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function IsAdmin(ply)
	return ply:IsAdmin()
end

function IsSuperAdmin(ply)
	return ply:IsSuperAdmin()
end

function IsDeveloper(ply)
	return ply:IsDeveloper()
end

function IsUserGroup(...)
	local usergroups = {...}

	return function(ply)
		for _, group in pairs(usergroups) do
			if ply:CheckUserGroup(group) then
				return true
			end
		end

		return false
	end
end
