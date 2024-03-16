Log = Log or {}

Log.Categories = Log.Categories or {}
Log.LogColor = Color(200, 200, 200)

function Log.Category(name)
	if Log.Categories[name] then
		return Log.Categories[name]
	end

	local convar = CreateConVar("rp_log_" .. name:lower(), "0", FCVAR_ARCHIVE, "", 0, 1)

	local func = function(text, ...)
		if not convar:GetBool() then
			return
		end

		Log.Write(name, text, ...)
	end

	Log.Categories[name] = func

	return func
end

function Log.Write(category, text, ...)
	MsgC(Log.LogColor, string.format("[%s] " .. text, category, ...), "\n")
end
