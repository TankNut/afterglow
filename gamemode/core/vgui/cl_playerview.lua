local PANEL = {}

AccessorFunc(PANEL, "CamPosTarget", "CamPosTarget")
AccessorFunc(PANEL, "LookAtTarget", "LookAtTarget")

function PANEL:Init()
	self:SetCamPosTarget(Vector(60, -20, 64))
	self:SetLookAtTarget(Vector(0, 0, 64))
end

function PANEL:SetPlayer(ply)
	self:SetModel(ply:GetModel())

	Appearance.Copy(ply, self.Entity)

	self.Entity.GetPlayerColor = function()
		return ply:GetPlayerColor()
	end

	local animtable = Animations.Get(ply:GetModel())

	if animtable then
		local sequence = animtable[ACT_MP_STAND_IDLE]

		if isstring(sequence) then
			sequence = self.Entity:LookupSequence(animtable[ACT_MP_STAND_IDLE])
		end

		self.Entity:SetSequence(self.Entity:SelectWeightedSequence(sequence))
	end
end

function PANEL:LayoutEntity(ent)
	self:RunAnimation()

	local pos, look = self:GetTargets()

	if not ent.PanelLayoutDone then
		ent.PanelLayoutDone = true
	end

	self:SetCamPos(pos)
	self:SetLookAt(look)
	self:SetFOV(20)

	local height = 64
	local dir = ent:GetForward()

	local att = ent:GetAttachment(ent:LookupAttachment("eyes"))

	if att then
		height = att.Pos.z
		dir = att.Ang:Forward()
	end

	ent:SetEyeTarget(Vector(0, 0, height) + dir * 50)
end

function PANEL:GetTargets()
	local pos = Vector(self.CamPosTarget)
	local look = Vector(self.LookAtTarget)

	local ang = Angle(0, self.Entity:EyeAngles().y, 0)

	pos:Rotate(ang)
	look:Rotate(ang)

	local offset = Animations.GetOffset(self:GetModel())

	pos = pos + offset
	look = look + offset

	return self.Entity:GetPos() + pos, self.Entity:GetPos() + look
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
		render.SuppressEngineLighting(true)
		render.ResetModelLighting(0.3, 0.3, 0.3)

		render.SetModelLighting(BOX_FRONT, 1, 1, 1)
		render.SetModelLighting(BOX_TOP, 1, 1, 1)

		render.SetColorModulation(1, 1, 1)

		render.ClearDepth()

		self.Entity:DrawModel()

		render.SuppressEngineLighting(false)
	cam.End3D()

	self.LastPaint = RealTime()
end

derma.DefineControl("RPPlayerView", "Panel for viewing a non-live version of a player", PANEL, "RPModelPanel")
