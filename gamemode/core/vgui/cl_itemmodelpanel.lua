local PANEL = {}

AccessorFunc(PANEL, "m_bFirstPerson", "FirstPerson")
AccessorFunc(PANEL, "OrbitDistance", "OrbitDistance")

function PANEL:Init()
	self.mx = 0
	self.my = 0

	self.aLookAngle = angle_zero

	self:SetOrbitDistance(100)
end

function PANEL:OnMousePressed(mousecode)
	self:SetCursor("none")
	self:MouseCapture(true)

	self.Capturing = true
	self.MouseKey = mousecode

	self:SetFirstPerson(true)
	self:CaptureMouse()
end

function PANEL:LayoutEntity(ent)
	local mins, maxs = self.Entity:GetModelBounds()

	self.OrbitPoint = (mins + maxs) / 2
	self.vCamPos = self.OrbitPoint - self.aLookAngle:Forward() * self.OrbitDistance
end

function PANEL:Think()
	if not self.Capturing then
		return
	end

	if self.m_bFirstPerson then
		return self:FirstPersonControls()
	end
end

function PANEL:CaptureMouse()
	local x, y = input.GetCursorPos()

	local dx = x - self.mx
	local dy = y - self.my

	local centerx, centery = self:LocalToScreen(self:GetWide() * 0.5, self:GetTall() * 0.5)

	input.SetCursorPos(centerx, centery)

	self.mx = centerx
	self.my = centery

	return dx, dy
end

function PANEL:FirstPersonControls()
	local x, y = self:CaptureMouse()

	self.aLookAngle = self.aLookAngle + Angle(y * 0.5, x * -0.5, 0)

	return
end

function PANEL:OnMouseWheeled(dlta)
	local scale = self:GetFOV() / 180

	self.fFOV = math.Clamp(self.fFOV + dlta * -10.0 * scale, 0.001, 179)
end

function PANEL:OnMouseReleased(mousecode)
	self:SetCursor("arrow")
	self:MouseCapture(false)

	self.Capturing = false
end

local developer = GetConVar("developer")

function PANEL:PreDrawModel(ent)
	cam.IgnoreZ(true)
end

function PANEL:Paint(w, h)
	if developer:GetBool() then
		local ang = Angle(self.aLookAngle)

		ang:Normalize()

		local _, y = draw.SimpleText(ang, "BudgetLabel", 2)
		draw.SimpleText(self.fFOV, "BudgetLabel", 2, y)
	end

	surface.SetDrawColor(0, 0, 0, 70)
	surface.DrawRect(0, 0, w, h)

	DModelPanel.Paint(self, w, h)

	surface.SetDrawColor(self:GetSkin().Colors.Border)
	surface.DrawLine(0, h - 1, w, h - 1)
end

function PANEL:PostDrawModel(ent)
	cam.IgnoreZ(false)
end

derma.DefineControl("RPItemModelPanel", "Model display for item panels", PANEL, "DModelPanel")
