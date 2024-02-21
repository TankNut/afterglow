module("request", package.seeall)

Requests = Requests or {}

if CLIENT then
	function Hook(name, callback)
		netstream.Hook(name, function(payload)
			netstream.Send("Request", {
				Index = payload.Index,
				Payload = callback(payload.Data)
			})
		end)
	end

	function Send(name, data)
		local cr = coroutine.running()

		if not cr then
			error("Cannot request.Send outside of a coroutine environment")
		end

		local index = table.insert(Requests, cr)

		netstream.Send(name, {
			Index = index,
			Data = data
		})

		return coroutine.yield()
	end

	netstream.Hook("Request", function(payload)
		local cr = Requests[payload.Index]

		Requests[payload.Index] = nil

		if cr then
			coroutine.Resume(cr, payload.Data)
		end
	end)
else
	function Hook(name, callback)
		netstream.Hook(name, function(ply, payload)
			netstream.Send("Request", ply, {
				Index = payload.Index,
				Data = callback(ply, payload.Data)
			})
		end)
	end

	function Send(name, ply, data)
		local cr = coroutine.running()

		if not cr then
			error("Cannot request.Send outside of a coroutine environment")
		end

		if not Requests[ply] then
			Requests[ply] = {}
		end

		local index = table.insert(Requests[ply], cr)

		netstream.Send(name, ply, {
			Index = index,
			Data = data
		})

		return coroutine.yield()
	end

	netstream.Hook("Request", function(ply, payload)
		if not Requests[ply] then
			return
		end

		local cr = Requests[ply][payload.Index]

		Requests[ply][payload.Index] = nil

		if cr then
			coroutine.Resume(cr, payload.Data)
		end
	end)
end
