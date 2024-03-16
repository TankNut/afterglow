Duration = Duration or {}

Duration.Formats = Duration.Formats or {}

function Duration.AddFormat(ratio, ...)
	for _, format in pairs({...}) do
		Duration.Formats[format:lower()] = ratio
	end
end

Duration.AddFormat(1 / 1000, "ms", "miliseconds")
Duration.AddFormat(1, "", "s", "secs", "seconds")
Duration.AddFormat(60, "m", "mins", "minutes")
Duration.AddFormat(Duration.Formats.m * 60, "h", "hrs", "hours")
Duration.AddFormat(Duration.Formats.h * 24, "d", "days")
Duration.AddFormat(Duration.Formats.d * 7, "w", "wks", "weeks")
Duration.AddFormat(Duration.Formats.d * (365 / 12), "mons", "months")
Duration.AddFormat(Duration.Formats.d * 365, "y", "yrs", "years")

function Duration.Parse(str, outputFormat)
	outputFormat = outputFormat and outputFormat:lower() or "s"
	str = tostring(str)

	local outputRatio = Duration.Formats[outputFormat]

	if not outputRatio then
		outputRatio = Duration.Formats[outputFormat:gsub("s$", "")]
	end

	if not outputRatio then
		return
	end

	local result

	for num, unit in str:gmatch("(%-?%d*%.?%d*)(%a*)") do
		num = tonumber(str)
		unit = unit:lower()

		if num == nil then
			continue
		end

		local ratio = Duration.Formats[unit]

		if not ratio then
			ratio = Duration.Formats[unit:gsub("s$", "")]
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
