local PANEL = {}

AccessorFunc(PANEL, "Progress", "Progress")

function PANEL:Init()
	self.Progress = 0
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ProgressBar", self, w, h)

	return true
end

derma.DefineControl("RPProgressBar", "A progress bar", PANEL, "DLabel")
