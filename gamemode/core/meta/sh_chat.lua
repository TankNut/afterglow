local entity = FindMetaTable("Entity")
local meta = FindMetaTable("Player")


function entity:CanHear(pos)
	return util.TraceLine({
		start = self:IsPlayer() and self:EyePos() or self:WorldSpaceCenter(),
		endpos = pos,
		filter = self,
		mask = MASK_OPAQUE
	}).Fraction == 1
end


function meta:SendChat(name, data)
	if CLIENT then
		if self != LocalPlayer() then
			error("Attempt to SendChat to a non-local player")
		end

		Chat.Receive(name, data)
	else
		Chat.Send(name, data, self)
	end
end
