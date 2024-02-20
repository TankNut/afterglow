Animtable.Define("antlion", {
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

Animtable.Add("antlion", {"models/antlion.mdl", "models/antlion_worker.mdl"})
Animtable.AddOffset({"models/antlion.mdl", "models/antlion_worker.mdl"}, Vector(50, -10, -40))