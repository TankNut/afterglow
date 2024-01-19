surface.GetFontSize = Memoize(function(font, str)
	surface.SetFont(font)

	return surface.GetTextSize(str)
end)
