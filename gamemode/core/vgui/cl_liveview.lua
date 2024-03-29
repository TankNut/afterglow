local PANEL = {}

AccessorFunc(PANEL, "vTargetCamPos", "TargetCamPos")
AccessorFunc(PANEL, "vTargetLookAt", "TargetLookAt")

function PANEL:Init()
	self:SetTargetCamPos(Vector(100, 0, 45))
	self:SetTargetLookAt(Vector(0, 0, 35))
	self:SetFOV(22)

	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
end

function PANEL:GetTargets()
	local pos = Vector(self.vTargetCamPos)
	local look = Vector(self.vTargetLookAt)

	local ang = Angle(0, self.Entity:EyeAngles().y, 0)

	pos:Rotate(ang)
	look:Rotate(ang)

	return self.Entity:GetPos() + pos, self.Entity:GetPos() + look
end

function PANEL:LayoutEntity(ent)
	local pos, look = self:GetTargets()

	if not ent.PanelLayoutDone then
		ent.PanelLayoutDone = true
	end

	self:SetCamPos(pos)
	self:SetLookAt(look)
end

function PANEL:OnRemove()
end

function PANEL:ShouldDrawLocalPlayer(ply)
	if self.IsDrawing then
		return true
	end
end

function PANEL:Paint(w, h)
	if not IsValid(self.Entity) then
		return
	end

	local x, y = self:LocalToScreen(0, 0)

	self:LayoutEntity(self.Entity)

	local ang = self.aLookAngle

	if not ang then
		ang = (self.vLookatPos - self.vCamPos):Angle()
	end

	cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
		self.IsDrawing = true

		render.SuppressEngineLighting(true)
		render.ResetModelLighting(0.7, 0.7, 0.7)

		render.SetModelLighting(BOX_FRONT, 1, 1, 1)
		render.SetModelLighting(BOX_BOTTOM, 0.3, 0.3, 0.3)

		render.SetColorModulation(1, 1, 1)

		self.Entity:DrawModel()

		local weapon = self.Entity:GetActiveWeapon()

		if IsValid(weapon) then
			weapon:DrawModel()
		end

		render.SuppressEngineLighting(false)

		self.IsDrawing = nil
	cam.End3D()

	self.LastPaint = RealTime()
end

RPLiveView = derma.DefineControl("RPLiveView", "Panel for drawing players themselves into a DModelPanel", PANEL, "DModelPanel")
