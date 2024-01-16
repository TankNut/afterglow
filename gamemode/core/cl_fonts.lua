GM.MainFont = "Tahoma"

function surface.FontExists(font)
	local ok = pcall(surface.SetFont, font)

	return ok
end

surface.CreateFont("DefaultBold", {
	font = "Tahoma",
	size = 13,
	weight = 1000
})

surface.CreateFont("afterglow.labelworld", {
	font = GM.MainFont,
	size = 2048,
	weight = 21
})

surface.CreateFont("afterglow.labelmassive", {
	font = GM.MainFont,
	size = 30,
	weight = 500
})

surface.CreateFont("afterglow.labelgiant", {
	font = GM.MainFont,
	size = 22,
	weight = 500
})

surface.CreateFont("afterglow.labelbig", {
	font = GM.MainFont,
	size = 18,
	weight = 500
})

surface.CreateFont("afterglow.labelmedium", {
	font = GM.MainFont,
	size = 16,
	weight = 500
})

surface.CreateFont("afterglow.labelmediumbold", {
	font = GM.MainFont,
	size = 16,
	weight = 1600
})

surface.CreateFont("afterglow.labelsmall", {
	font = GM.MainFont,
	size = 14,
	Weight = 500
})

surface.CreateFont("afterglow.labelsmallbold", {
	font = GM.MainFont,
	size = 14,
	weight = 1600
})

surface.CreateFont("afterglow.labelsmallitalic", {
	font = GM.MainFont,
	size = 14,
	Weight = 500,
	italic = true
})

surface.CreateFont("afterglow.labeltiny", {
	font = GM.MainFont,
	size = 12,
	Weight = 500
})
