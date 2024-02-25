function ITEM:GetFormattedItemName()
	local color = self:GetProperty("ItemColor")

	if IsColor(color) then
		return string.format("<c=%s>%s", color, self:GetName())
	elseif isstring(color) then
		return color .. self:GetName()
	end

	return self:GetName()
end

function ITEM:GetName() return self:GetProperty("Name") end
function ITEM:GetDescription() return self:GetProperty("Description") end
function ITEM:GetCategory() return self:GetProperty("Category") end
function ITEM:GetWeight() return self:GetProperty("Weight") end

function ITEM:GetTags()
	local cache = self:GetCache("Tags")

	if cache then
		return cache
	end

	local tags = {self:GetProperty("Category")}

	for k, v in ipairs(self:GetProperty("Tags")) do
		table.insert(tags, v)
	end

	self:WriteCache("Tags", tags)

	return tags
end

function ITEM:GetAmount()
	return 1
end
