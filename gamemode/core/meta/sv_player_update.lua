local meta = FindMetaTable("Player")


function meta:UpdateArmor()
	local armor = 0

	if self:HasCharacter() then
		armor = self:GetCharacterFlagAttribute("Armor")

		for _, v in pairs(self:GetEquipment()) do
			if v:IsBasedOn("base_clothing") then
				armor = math.max(armor, v:GetArmor())
			end
		end
	end

	if self:Armor() != armor then
		self:SetArmor(armor > 0 and armor or nil)
	end
end


function meta:UpdateTeam()
	self:SetTeam(hook.Run("PlayerGetTeam", self))
end


function meta:UpdateName()
	self:SetVisibleName(hook.Run("GetVisibleName", self))
end


function meta:UpdateAppearance()
	Appearance.QueueUpdate(self)
end


function meta:UpdateSpeed()
	self:SetSlowWalkSpeed(hook.Run("GetSlowWalkSpeed", self))
	self:SetWalkSpeed(hook.Run("GetWalkSpeed", self))
	self:SetRunSpeed(hook.Run("GetRunSpeed", self))
	self:SetJumpPower(hook.Run("GetJumpPower", self))
	self:SetCrouchedWalkSpeed(hook.Run("GetCrouchedWalkSpeed", self))
end
