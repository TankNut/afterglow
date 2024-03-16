Request = Request or {}
Request.Active = Request.Active or {}

local writeLog = Log.Category("Request")

if CLIENT then
	function Request.Hook(name, callback)
		Netstream.Hook(name, function(payload)
			writeLog("Request: #%s (%s) from SERVER", payload.Index, name)

			Netstream.Send("Request", {
				Index = payload.Index,
				Payload = callback(payload.Data)
			})
		end)
	end

	function Request.Send(name, data)
		local cr = coroutine.running()

		if not cr then
			error("Cannot request.Send outside of a coroutine environment")
		end

		local index = table.insert(Request.Active, cr)

		writeLog("Query: #%s '%s' to SERVER", index, name)

		Netstream.Send(name, {
			Index = index,
			Data = data
		})

		return coroutine.yield()
	end

	Netstream.Hook("Request", function(payload)
		local cr = Request.Active[payload.Index]

		writeLog("Response: #%s from SERVER", payload.Index)

		Request.Active[payload.Index] = nil

		if cr then
			coroutine.Resume(cr, payload.Data)
		end
	end)
end

if SERVER then
	function Request.Hook(name, callback)
		Netstream.Hook(name, function(ply, payload)
			writeLog("Request: #%s (%s) from %s", payload.Index, name, ply)

			Netstream.Send("Request", ply, {
				Index = payload.Index,
				Data = callback(ply, payload.Data)
			})
		end)
	end

	function Request.Send(name, ply, data)
		local cr = coroutine.running()

		if not cr then
			error("Cannot request.Send outside of a coroutine environment")
		end

		if not Request.Active[ply] then
			Request.Active[ply] = {}
		end

		local index = table.insert(Request.Active[ply], cr)

		writeLog("Query: #%s (%s) to %s", index, name, ply)

		Netstream.Send(name, ply, {
			Index = index,
			Data = data
		})

		return coroutine.yield()
	end

	Netstream.Hook("Request", function(ply, payload)
		if not Request.Active[ply] then
			return
		end

		local cr = Request.Active[ply][payload.Index]

		writeLog("Response: #%s from %s", payload.Index, ply)

		Request.Active[ply][payload.Index] = nil

		if cr then
			coroutine.Resume(cr, payload.Data)
		end
	end)
end
