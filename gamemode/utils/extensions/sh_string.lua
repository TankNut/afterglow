function string.FirstToUpper(str)
	return str:sub(1, 1):upper() .. str:sub(2)
end

function string.LastSpace(str)
	for i = #str, 1, -1 do
		if str[i] == " " then
			return i
		end
	end
end

local escapeEntities = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;"
}

local unescapeEntities = {
	["&amp;"] = "&",
	["&lt;"] = "<",
	["&gt;"] = ">"
}

function string.Escape(str)
	return tostring(str):gsub("[&<>]", escapeEntities)
end

function string.Unescape(str)
	return tostring(str):gsub("(&.-;)", unescapeEntities)
end
