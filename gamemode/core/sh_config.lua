module("Config", package.seeall)

function Get(key)
	return GM and GM.Config[key] or GAMEMODE.Config[key]
end
