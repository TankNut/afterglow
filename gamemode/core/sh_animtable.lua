module("Animtable", package.seeall)

Tables = Tables or {}
Models = Models or {}

function Define(name, normal, combat)
	local tab = Tables[name]

	if not tab then
		tab = {}
		Tables[name] = tab
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

function Add(name, models)
	if not istable(models) then
		models = {models}
	end

	for _, v in pairs(models) do
		Models[v:lower()] = Tables[name]
	end
end

Define("antlion", {
	[ACT_MP_STAND_IDLE] = ACT_IDLE,
	[ACT_MP_WALK] = ACT_WALK,
	[ACT_MP_RUN] = ACT_RUN,
	[ACT_MP_CROUCH_IDLE] = ACT_IDLE,
	[ACT_MP_CROUCHWALK] = ACT_WALK,
	[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_IDLE,
	[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_IDLE,
	[ACT_MP_RELOAD_STAND] = ACT_IDLE,
	[ACT_MP_RELOAD_CROUCH] = ACT_IDLE,
	[ACT_MP_JUMP] = ACT_JUMP,
	[ACT_MP_SWIM_IDLE] = ACT_IDLE,
	[ACT_MP_SWIM] = ACT_IDLE,
	[ACT_LAND] = ACT_IDLE
})

Add("antlion", {"models/antlion.mdl", "models/antlion_worker.mdl"})

function GM:CalcMainActivity(ply, vel)
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding(ply, vel, ply.m_bWasOnGround)

	if self:HandlePlayerNoClipping(ply, vel) or
		self:HandlePlayerDriving(ply) or
		self:HandlePlayerVaulting(ply, vel) or
		self:HandlePlayerJumping(ply, vel) or
		self:HandlePlayerDucking(ply, vel) or
		self:HandlePlayerSwimming(ply, vel) then
	else
		local len2d = vel:Length2D()

		if len2d > ply:GetRunSpeed() / math.sqrt(2) - 8 then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 25 then
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
	local tab = Models[string.lower(ply:GetModel())]

	if not tab then
		return
	end

	-- if self:UseUnholsteredAnims(tab, ply:GetActiveWeapon()) then
	-- 	tab = tab["__COMBAT"]
	-- end

	if tab[ply.CalcIdeal] then
		if type(tab[ply.CalcIdeal]) == "number" then
			ply.CalcIdeal = tab[ply.CalcIdeal]
		else
			ply.CalcSeqOverride = ply:LookupSequence(tab[ply.CalcIdeal])
		end
	end
end

function GM:UpdateAnimation(ply, vel, max)
	self.BaseClass:UpdateAnimation(ply, vel, max)

	if CLIENT then
		if Models[ply:GetModel():lower()] then
			ply:SetIK(false)
		else
			ply:SetIK(true)
		end

		local moveang = Vector(vel.x, vel.y, 0):Angle()
		local eyeang = Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):Angle()

		local diff = moveang.y - eyeang.y

		if diff > 180 then diff = diff - 360 end
		if diff < -180 then diff = diff + 360 end

		ply:SetPoseParameter("move_yaw", diff)

		self:RadioAnimation(ply)
	end
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
