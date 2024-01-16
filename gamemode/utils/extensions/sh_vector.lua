local meta = FindMetaTable("Vector")

function meta:Approach(dest, speed)
	self.x = math.ApproachSpeed(self.x, dest.x, speed)
	self.y = math.ApproachSpeed(self.y, dest.y, speed)
	self.z = math.ApproachSpeed(self.z, dest.z, speed)

	return self
end
