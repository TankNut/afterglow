local meta = FindMetaTable("Player")

function meta:GetPlayerColor()
	return hook.Run("GetPlayerColor", self)
end

if SERVER then
	function meta:UpdateSpeed()
		self:SetSlowWalkSpeed(hook.Run("GetSlowWalkSpeed", self))
		self:SetWalkSpeed(hook.Run("GetWalkSpeed", self))
		self:SetRunSpeed(hook.Run("GetRunSpeed", self))
		self:SetJumpPower(hook.Run("GetJumpPower", self))
		self:SetCrouchedWalkSpeed(hook.Run("GetCrouchedWalkSpeed", self))
	end
end
