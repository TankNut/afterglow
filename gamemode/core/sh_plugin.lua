module("Plugin", package.seeall)

local pluginFiles = {
	"cl_plugin.lua",
	"sh_plugin.lua",
	"sv_plugin.lua"
}

function Load()
	local base = engine.ActiveGamemode() .. "/gamemode/plugins/"
	local files, folders = file.Find(base .. "*", "LUA")

	for _, path in pairs(files) do
		if path:GetExtensionFromFilename() != "lua" then
			continue
		end

		IncludeFile(base .. path)
	end

	for _, folder in pairs(folders) do
		for _, path in pairs(pluginFiles) do
			local finalPath = string.format("%s%s/%s", base, folder, path)

			if not file.Exists(finalPath, "LUA") then
				continue
			end

			IncludeFile(finalPath)
		end
	end

	hook.Run("LoadPluginContent")
end
