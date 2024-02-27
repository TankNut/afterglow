module("Combine", package.seeall)

IncludeFile("sh_vars.lua")

function GetCID(seed)
	if seed then
		math.randomseed(seed)
	end

	local str = ""

	for i = 1, 5 do
		str = str .. math.random(0, 9)
	end

	return str
end
