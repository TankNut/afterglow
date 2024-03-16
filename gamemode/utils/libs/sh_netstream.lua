Netstream = Netstream or {}

Netstream.Hooks = Netstream.Hooks or {}
Netstream.Cache = Netstream.Cache or {}

Netstream.MessageLimit = 60000 -- 60 KB
Netstream.TickLimit = 200000 -- 0.2 MB/s

local writeLog = Log.Category("Netstream")

function Netstream.Split(data)
	local encoded = Netstream.Encode(data)
	local length = #encoded

	if length < Netstream.MessageLimit then
		return {{Data = encoded, Length = length}}, length
	end

	local payload = {}
	local count = math.ceil(length / Netstream.MessageLimit)

	for i = 1, count do
		local buffer = string.sub(encoded, Netstream.MessageLimit * (i - 1) + 1, Netstream.MessageLimit * i)

		payload[i] = {Data = buffer, Length = #buffer}
	end

	return payload, length
end

function Netstream.Encode(data)
	return Pack.Encode(data)
end

function Netstream.Decode(data)
	return Pack.Decode(data)
end

function Netstream.Hook(name, cb)
	Netstream.Hooks[name] = cb
	Netstream.Cache[name] = {}
end

if CLIENT then
	function Netstream.Send(name, data)
		if not data then
			writeLog("Outgoing: '%s' (NOTIFY) to SERVER", name)

			net.Start("Netstream_Notify")
				net.WriteString(name)
			net.SendToServer()

			return
		end

		local payload, size = Netstream.Split(data)

		writeLog("Outgoing: '%s' (%s) to SERVER", name, string.NiceSize(size))

		for k, v in pairs(payload) do
			net.Start("Netstream")
				net.WriteString(name)
				net.WriteBool(k == #payload)
				net.WriteUInt(v.Length, 15)
				net.WriteData(v.Data, v.Length)
			net.SendToServer()
		end
	end

	function Netstream.Read(name)
		local final = net.ReadBool()
		local length = net.ReadUInt(15)
		local payload = net.ReadData(length)

		local cache = Netstream.Cache[name]

		table.insert(cache, payload)

		if final then
			local raw = table.concat(cache)

			table.Empty(cache)

			return Netstream.Decode(raw), #raw
		end
	end

	net.Receive("Netstream", function()
		local name = net.ReadString()
		local callback = Netstream.Hooks[name]

		if not callback then
			return
		end

		local data, len = Netstream.Read(name)

		if data then
			writeLog("Incoming: '%s' (%s) from SERVER", name, string.NiceSize(len))

			coroutine.wrap(callback)(data)
		end
	end)

	net.Receive("Netstream_Notify", function()
		local name = net.ReadString()
		local callback = Netstream.Hooks[name]

		if not callback then
			return
		end

		writeLog("Incoming: '%s' (NOTIFY) from SERVER", name)

		coroutine.wrap(callback)()
	end)
end

if SERVER then
	util.AddNetworkString("Netstream")
	util.AddNetworkString("Netstream_Notify")

	Netstream.Queue = Netstream.Queue or {}
	Netstream.Rate = Netstream.Rate or {}
	Netstream.Ready = Netstream.Ready or {}

	function Netstream.GetTargets(targets)
		local result

		if not targets then
			result = player.GetAll()
		elseif TypeID(targets) == TYPE_RECIPIENTFILTER then
			result = targets:GetPlayers()
		elseif istable(targets) then
			result = table.Unique(targets)
		else
			result = {targets}
		end

		return result
	end

	function Netstream.AddToQueue(name, final, payload, targets)
		local data = {
			Name = name,
			Final = final,
			Length = payload and payload.Length,
			Data = payload and payload.Data
		}

		for _, v in pairs(targets) do
			if not Netstream.Queue[v] then
				Netstream.Queue[v] = Queue.New()
			end

			Netstream.Queue[v]:Push(data)
		end
	end

	function Netstream.Broadcast(name, data)
		Netstream.Send(name, nil, data)
	end

	function Netstream.Send(name, targets, data)
		targets = Netstream.GetTargets(targets)

		if #targets < 1 then
			writeLog("Rejected: '%s' to NOBODY", name)

			return
		end

		if not data then
			writeLog("Outgoing: '%s' (NOTIFY) to %s", name, #targets > 1 and #targets .. " targets" or targets[1])

			Netstream.AddToQueue(name, nil, nil, targets)

			return
		end

		local payload, size = Netstream.Split(data)

		writeLog("Outgoing: '%s' (%s) to %s", name, string.NiceSize(size), #targets > 1 and #targets .. " targets" or targets[1])

		for k, v in pairs(payload) do
			Netstream.AddToQueue(name, k == #payload, v, targets)
		end
	end

	function Netstream.Read(name, ply)
		local final = net.ReadBool()
		local length = net.ReadUInt(15)
		local payload = net.ReadData(length)

		local cache = Netstream.Cache[name]

		if not cache[ply] then
			cache[ply] = {}
		end

		table.insert(cache[ply], payload)

		if final then
			local raw = table.concat(cache[ply])

			table.Empty(cache[ply])

			return Netstream.Decode(raw), #raw
		end
	end

	net.Receive("Netstream", function(_, ply)
		local name = net.ReadString()
		local callback = Netstream.Hooks[name]

		if not callback then
			writeLog("Rejected: '%s' from %s", name, ply)

			return
		end

		local data, len = Netstream.Read(name, ply)

		if data then
			writeLog("Incoming: '%s' (%s) from %s", name, string.NiceSize(len), ply)

			coroutine.wrap(callback)(ply, data)
		end
	end)

	net.Receive("Netstream_Notify", function(_, ply)
		local name = net.ReadString()
		local callback = Netstream.Hooks[name]

		if not callback then
			writeLog("Rejected: '%s' from %s", name, ply)

			return
		end

		writeLog("Incoming: %s (NOTIFY) from %s", name, ply)

		coroutine.wrap(callback)(ply)
	end)

	hook.Add("OnPlayerReady", "Netstream", function(ply)
		Netstream.Ready[ply] = true

		if Netstream.Queue[ply] then
			local size = 0

			for _, v in pairs(Netstream.Queue[ply].Items) do
				size = size + v.Length
			end

			writeLog("Ready: %s (%s queued)", ply, string.NiceSize(size))
		else
			writeLog("Ready: %s", ply)
		end
	end)

	hook.Add("Think", "Netstream", function()
		for k, v in pairs(Netstream.Queue) do
			if not IsValid(k) then
				Netstream.Queue[k] = nil
				Netstream.Rate[k] = nil
				Netstream.Ready[k] = nil

				continue
			end

			if not Netstream.Ready[k] or Netstream.Queue[k]:Count() < 1 then
				continue
			end

			Netstream.Rate[k] = Netstream.Rate[k] or Netstream.TickLimit
			Netstream.Rate[k] = math.min(Netstream.Rate[k] + (Netstream.TickLimit * FrameTime()), Netstream.TickLimit)

			while Netstream.Rate[k] - Netstream.MessageLimit > 0 do
				local payload = v:Pop()

				if not payload then
					break
				end

				if payload.Data then
					net.Start("Netstream")
						net.WriteString(payload.Name)
						net.WriteBool(payload.Final)
						net.WriteUInt(payload.Length, 15)
						net.WriteData(payload.Data, payload.Length)

						Netstream.Rate[k] = Netstream.Rate[k] - net.BytesWritten()
					net.Send(k)
				else
					net.Start("Netstream_Notify")
						net.WriteString(payload.Name)
					net.Send(k)
				end
			end
		end
	end)
end
