AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.AutomaticFrameAdvance = true

-- Why tf are there two of these?
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end

		self.StoredPos = self:GetPos()
	end

	function ENT:Think()
		if self:GetPos() != self.StoredPos then
			self.Item:SaveLocation()
		end

		self:NextThink(CurTime() + 30)

		return true
	end

	function ENT:OnRemove()
		if self.Item then
			self.Item.Entity = nil
			self.Item:Destroy()
		end
	end

	function ENT:Use(ply)
		self.Item:OnWorldUse(ply, self)
	end
end
