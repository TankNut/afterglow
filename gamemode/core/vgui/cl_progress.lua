local PANEL = {}

AccessorFunc(PANEL, "fProgress", "Progress")

function PANEL:Init()
	self:SetProgress(0)
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ProgressBar", self, w, h)

	return true
end

vgui.Register("afterglow_progress", PANEL, "DLabel")
