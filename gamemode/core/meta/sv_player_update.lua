local meta = FindMetaTable("Player")


function meta:UpdateArmor()
	local armor = hook.Run("GetBaseArmor", self)

	if self:HasCharacter() then
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
	self:SetTeam(hook.Run("GetPlayerTeam", self))
end


function meta:UpdateName()
	self:SetVisibleName(hook.Run("GetCharacterName", self) or self:GetCharacterName())
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
