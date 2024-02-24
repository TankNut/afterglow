function coroutine.Bind(func)
	return function(...)
		if coroutine.running() then
			return func(...)
		else
			return coroutine.wrap(func)(...)
		end
	end
end


function coroutine.Resume(cr, ...)
	local yield = {coroutine.resume(cr, ...)}
	local ok = table.remove(yield, 1)

	if not ok then
		error(string.format("\n\n--- ERROR IN COROUTINE ---\n\n%s\n\n--- END OF COROUTINE ERROR ---\n", debug.traceback(cr, "[ERROR] " .. yield[1])))
	end

	return unpack(yield)
end
