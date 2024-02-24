function meta:HasCharacter() return self:GetCharID() != -1 end
function meta:IsTemplateCharacter() return self:GetCharID() == 0 end


function meta:GetCharacterFlagTable()
	return GetOrDefault(self:GetCharacterFlag())
end


function meta:GetCharacterFlagAttribute(name)
	local flag = self:GetCharacterFlagTable()

	return flag:GetAttribute(name, self)
end
