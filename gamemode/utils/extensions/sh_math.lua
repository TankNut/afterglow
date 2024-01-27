function math.ApproachSpeed(start, dest, speed)
	dist = math.max(math.abs(start - dest), 0.0001)

	return math.Approach(start, dest, dist / speed)
end

function math.InRange(val, min, max)
	return val >= min and val <= max
end

function math.ClampedRemap(val, inMin, inMax, outMin, outMax)
	return math.Clamp(math.Remap(val, inMin, inMax, outMin, outMax), math.min(outMin, outMax), math.max(outMin, outMax))
end
