function bit.Has(val, flag)
	return bit.band(val, flag) == flag
end

function bit.Add(val, flag)
	return bit.bor(val, flag)
end

function bit.Remove(val, flag)
	return bit.band(val, bit.bnot(flag))
end
