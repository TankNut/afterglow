function bit.Check(val, flag)
	return bit.band(val, flag) == flag
end

function bit.SetFlag(val, flag)
	return bit.bor(val, flag)
end

function bit.UnsetFlag(val, flag)
	return bit.band(val, bit.bnot(flag))
end
