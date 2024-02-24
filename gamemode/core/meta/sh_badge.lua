local meta = FindMetaTable("Player")


function meta:GetBadges()
	local custom = self:GetCustomBadges()
	local badges = {}

	for _, badge in pairs(List) do
		if (badge.Automated and badge.Callback(self)) or custom[badge.ID] then
			table.insert(badges, badge)
		end
	end

	return badges
end


function meta:HasBadge(id)
	local badge = Get(id)

	if badge.Automated then
		return tobool(badge.Callback(self))
	else
		return tobool(self:GetBadges()[id])
	end
end


if SERVER then
	function meta:GiveBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetCustomBadges()

		badges[id] = true

		self:SetCustomBadges(badges)
	end


	function meta:TakeBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetCustomBadges()

		badges[id] = nil

		if table.IsEmpty(badges) then
			self:SetCustomBadges(nil)
		else
			self:SetCustomBadges(badges)
		end
	end
end
