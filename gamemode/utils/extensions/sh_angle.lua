local meta = FindMetaTable("Angle")

function meta:Approach(dest, speed)
	self.p = math.ApproachSpeed(self.p, dest.p, speed)
	self.y = math.ApproachSpeed(self.y, dest.y, speed)
	self.r = math.ApproachSpeed(self.r, dest.r, speed)

	return self
end
