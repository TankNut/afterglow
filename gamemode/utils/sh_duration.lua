module("duration", package.seeall)

Formats = Formats or {}


function AddFormat(ratio, ...)
	for _, format in pairs({...}) do
		Formats[format:lower()] = ratio
	end
end


AddFormat(1 / 1000, "ms", "miliseconds")
AddFormat(1, "", "s", "secs", "seconds")
AddFormat(60, "m", "mins", "minutes")
AddFormat(Formats.m * 60, "h", "hrs", "hours")
AddFormat(Formats.h * 24, "d", "days")
AddFormat(Formats.d * 7, "w", "wks", "weeks")
AddFormat(Formats.d * (365 / 12), "mons", "months")
AddFormat(Formats.d * 365, "y", "yrs", "years")


function Parse(str, outputFormat)
	outputFormat = outputFormat and outputFormat:lower() or "s"
	str = tostring(str)

	local outputRatio = Formats[outputFormat]

	if not outputRatio then
		outputRatio = Formats[outputFormat:gsub("s$", "")]
	end

	if not outputRatio then
		return
	end

	local result

	for num, unit in str:gmatch("(%-?%d*%.?%d*)(%a*)") do
		num = tonumber(num)
		unit = unit:lower()

		if num == nil then
			continue
		end

		local ratio = Formats[unit]

		if not ratio then
			ratio = Formats[unit:gsub("s$", "")]
		end

		if not ratio then
			continue
		end

		if not result then
			result = 0
		end

		result = result + num * ratio
	end

	if result != nil then
		return result / outputRatio
	end
end
