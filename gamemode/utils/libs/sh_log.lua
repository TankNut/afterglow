module("log", package.seeall)

Categories = Categories or {}
LogColor = LogColor or Color(200, 200, 200)

function Category(name)
	if Categories[name] then
		return Categories[name]
	end

	local convar = CreateConVar("rp_log_" .. name:lower(), 0, FCVAR_ARCHIVE, "", 0, 1)
	local func = function(text, ...)
		if not convar:GetBool() then
			return
		end

		Write(name, text, ...)
	end

	Categories[name] = func

	return func
end

function Write(category, text, ...)
	MsgC(LogColor, string.format("[%s] " .. text, category, ...), "\n")
end
