local PANEL = {}
DEFINE_BASECLASS("DModelPanel")

AccessorFunc(PANEL, "bAllowManipulation", "AllowManipulation")

AccessorFunc(PANEL, "vCamPosRange", "CamPosRange")
AccessorFunc(PANEL, "vLookAtRange", "LookAtRange")
AccessorFunc(PANEL, "fFOVRange", "FOVRange")

function PANEL:Init()
	self.Zoom = 0

	self:SetCamPosRange({Vector(100, 100, 50), Vector(50, 50, 64)})
	self:SetLookAtRange({Vector(0, 0, 36), Vector(0, 0, 64)})
	self:SetFOVRange({20, 11})

	self.Dragging = false
	self.DragStart = 0
end

function PANEL:SetEntity(ent)
	BaseClass.SetEntity(self, ent)

	ent.PanelLayoutDone = false
end

function PANEL:SetModel(mdl)
	local cycle = 0

	if IsValid(self.Entity) then
		cycle = self.Entity:GetCycle()
	end

	BaseClass.SetModel(self, mdl)

	self.Entity:SetCycle(cycle)
end

function PANEL:SetSkin(num)
	self.Entity:SetSkin(num)
end

function PANEL:LayoutEntity(ent)
	if self.bAnimated then
		self:RunAnimation()
	end

	local pos, look, fov = self:GetCameraTarget()

	if not ent.PanelLayoutDone then
		ent.PanelLayoutDone = true

		self:SetCamPos(pos)
		self:SetLookAt(look)
		self:SetFOV(fov)

		ent:SetAngles(Angle(0, 20, 0))
	end

	if not self.bAllowManipulation then
		return
	end

	self:SetCamPos(self:GetCamPos():Approach(pos, 10))
	self:SetLookAt(self:GetLookAt():Approach(look, 10))
	self:SetFOV(math.ApproachSpeed(self:GetFOV(), fov, 10))

	local ang = Angle(0, 20, 0)

	if self.Dragging then
		local diff = gui.MouseX() - self.DragStart

		if self.Mouse then
			ang = Angle(0, 20 + diff, 0)
		else
			ang = ent:GetAngles() + Angle(0, diff * 0.25, 0)
		end
	end

	local att = ent:GetAttachment(ent:LookupAttachment("eyes"))
	local height = att.Pos.z or 64
	local dir = att.Ang:Forward() or ent:GetForward()

	ent:SetAngles(ent:GetAngles():Approach(ang, 30))
	ent:SetEyeTarget(Vector(0, 0, height) + dir * 50)
end

function PANEL:GetCameraTarget()
	local pos = LerpVector(self.Zoom, unpack(self.vCamPosRange))
	local look = LerpVector(self.Zoom, unpack(self.vLookAtRange))
	local fov = Lerp(self.Zoom, unpack(self.fFOVRange))

	return self.Entity:GetPos() + pos, self.Entity:GetPos() + look, fov
end

function PANEL:OnMouseWheeled(delta)
	if delta > 0 then
		self.Zoom = math.Approach(self.Zoom, 1, 0.2)
	else
		self.Zoom = math.Approach(self.Zoom, 0, 0.2)
	end
end

function PANEL:OnMousePressed(mouse)
	if self.bAllowManipulation then
		self:MouseCapture(true)

		self.Dragging = true
		self.DragStart = gui.MouseX()
		self.Mouse = mouse == MOUSE_LEFT
	end
end

function PANEL:OnMouseReleased()
	self:MouseCapture(false)
	self.Dragging = false

	local ang = self.Entity:GetAngles()

	ang:Normalize()

	self.Entity:SetAngles(ang)
end

derma.DefineControl("RPModelPanel", "Custom model panel for displaying player models with custom manipulation controls", PANEL, "DModelPanel")
