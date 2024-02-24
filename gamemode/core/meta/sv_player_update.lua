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


function meta:UpdateAppearance()
	Appearance.QueueUpdate(self)
end
