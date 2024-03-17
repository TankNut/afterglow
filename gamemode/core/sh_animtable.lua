Animtable = Animtable or {}

Animtable.Tables = Animtable.Tables or {}
Animtable.Models = Animtable.Models or {}
Animtable.Offsets = Animtable.Offsets or {}

function Animtable.Define(name, normal, combat)
	local tab = Animtable.Tables[name]

	if not tab then
		tab = {}
		Animtable.Tables[name] = tab
	end

	table.Merge(tab, normal)

	if combat then
		local sub = tab["__COMBAT"] or {}

		if not sub then
			sub = {}
			tab["__COMBAT"] = sub
		end

		table.Merge(sub, combat)
	end
end

function Animtable.Add(name, models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animtable.Models[model:lower()] = Animtable.Tables[name]
	end

	if offset then
		Animtable.AddOffset(models, offset)
	end
end

function Animtable.AddOffset(models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animtable.Offsets[model:lower()] = offset
	end
end

function Animtable.Get(model)
	return Animtable.Models[model:lower()]
end

function Animtable.GetOffset(model)
	return Animtable.Offsets[model:lower()] or Vector()
end

function GM:CalcMainActivity(ply, vel)
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding(ply, vel, ply.m_bWasOnGround)

	local bool = self:HandlePlayerNoClipping(ply, vel) or self:HandlePlayerDriving(ply) or self:HandlePlayerVaulting(ply, vel) or self:HandlePlayerJumping(ply, vel) or self:HandlePlayerDucking(ply, vel) or self:HandlePlayerSwimming(ply, vel)

	if not bool then
		local len2d = vel:Length2D()

		if len2d > Lerp(0.5, ply:GetWalkSpeed(), ply:GetRunSpeed()) then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_WALK
		end
	end

	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:InVehicle()

	self:HandleNonPlayerModel(ply, vel)

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.CalcMainActivity then
		wep:CalcMainActivity(ply, vel)
	end

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:HandleNonPlayerModel(ply, vel)
	local animtable = Animtable.Get(ply:GetModel())

	if not animtable then
		return
	end

	local len2d = vel:Length2D()

	if len2d <= 25 then
		ply.CalcIdeal = ACT_MP_STAND_IDLE
	end

	-- if self:UseUnholsteredAnims(tab, ply:GetActiveWeapon()) then
	-- 	tab = tab["__COMBAT"]
	-- end

	if animtable[ply.CalcIdeal] then
		if type(animtable[ply.CalcIdeal]) == "number" then
			ply.CalcIdeal = animtable[ply.CalcIdeal]
		else
			ply.CalcSeqOverride = ply:LookupSequence(animtable[ply.CalcIdeal])
		end
	end
end

function GM:UpdateAnimation(ply, vel, max)
	if CLIENT then
		max = max * ply:GetPlayerScale()
	end

	self.BaseClass:UpdateAnimation(ply, vel, max)

	if CLIENT then
		if Animtable.Get(ply:GetModel():lower()) then
			ply:SetIK(false)
		else
			ply:SetIK(true)
		end
	end

	local moveang = Vector(vel.x, vel.y, 0):Angle()
	local eyeang = Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):Angle()

	local diff = moveang.y - eyeang.y

	if diff > 180 then diff = diff - 360 end
	if diff < -180 then diff = diff + 360 end

	ply:SetPoseParameter("move_yaw", diff)

	self:RadioAnimation(ply)
end

function GM:RadioAnimation(ply)
	ply.RadioWeight = ply.RadioWeight or 0

	-- if ply:Typing() == CHATINDICATOR_RADIOING then
	-- 	ply.RadioWeight = math.Approach(ply.RadioWeight, 1, FrameTime() * 5.0)
	-- else
	-- 	ply.RadioWeight = math.Approach(ply.RadioWeight, 0, FrameTime() * 5.0)
	-- end

	if ply.RadioWeight > 0 then
		ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, ply.RadioWeight)
	end
end
