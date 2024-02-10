local PANEL = {}
DEFINE_BASECLASS("afterglow_modelpanel")

AccessorFunc(PANEL, "_CamPosTarget", "CamPosTarget")
AccessorFunc(PANEL, "_LookAtTarget", "LookAtTarget")

function PANEL:Init()
	self:SetCamPosTarget(Vector(60, -20, 64))
	self:SetLookAtTarget(Vector(0, 0, 54))
end

function PANEL:SetPlayer(ply)
	self:SetModel(ply:GetModel())

	Appearance.Copy(ply, self.Entity)

	self.Entity.GetPlayerColor = function()
		return ply:GetPlayerColor()
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
	local pos = Vector(self._CamPosTarget)
	local look = Vector(self._LookAtTarget)

	local ang = Angle(0, self.Entity:EyeAngles().y, 0)

	pos:Rotate(ang)
	look:Rotate(ang)

	pos = pos + self.Offset
	look = look + self.Offset

	return self.Entity:GetPos() + pos, self.Entity:GetPos() + look
end

function PANEL:PreDrawModel()
	local ent = self.Entity

	ent:DrawModel()

	return false
end

derma.DefineControl("RPPlayerView", "Deprecated?", PANEL, "RPModelPanel")
