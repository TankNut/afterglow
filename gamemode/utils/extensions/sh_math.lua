function math.ApproachSpeed(start, dest, speed)
	dist = math.max(math.abs(start - dest), 0.0001)

	return math.Approach(start, dest, dist / speed)
end
