module("netstream", package.seeall)

Hooks = Hooks or {}
Cache = Cache or {}

MessageLimit = 60000 -- 60 KB
TickLimit = 200000 -- 0.2 MB/s

local writeLog = log.Category("Netstream")


function Split(data)
	local encoded = Encode(data)
	local length = #encoded

	if length < MessageLimit then
		return {{Data = encoded, Length = length}}, length
	end

	local payload = {}
	local count = math.ceil(length / MessageLimit)

	for i = 1, count do
		local buffer = string.sub(encoded, MessageLimit * (i - 1) + 1, MessageLimit * i)

		payload[i] = {Data = buffer, Length = #buffer}
	end

	return payload, length
end


function Encode(data)
	return pack.Encode(data)
end


function Decode(data)
	return pack.Decode(data)
end


function Hook(name, cb)
	Hooks[name] = cb
	Cache[name] = {}
end


if CLIENT then
	function Send(name, data)
		if not data then
			writeLog("Outgoing: '%s' (NOTIFY) to SERVER", name)

			net.Start("NetstreamNotify")
				net.WriteString(name)
			net.SendToServer()

			return
		end

		local payload, size = Split(data)

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


	function Read(name)
		local final = net.ReadBool()
		local length = net.ReadUInt(15)
		local payload = net.ReadData(length)

		local cache = Cache[name]

		table.insert(cache, payload)

		if final then
			local raw = table.concat(cache)

			table.Empty(cache)

			return Decode(raw), #raw
		end
	end


	net.Receive("Netstream", function()
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			return
		end

		local data, len = Read(name)

		if data then
			writeLog("Incoming: '%s' (%s) from SERVER", name, string.NiceSize(len))

			callback(data)
		end
	end)


	net.Receive("NetstreamNotify", function()
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			return
		end

		writeLog("Incoming: '%s' (NOTIFY) from SERVER", name)

		callback()
	end)
end


if SERVER then
	util.AddNetworkString("Netstream")
	util.AddNetworkString("NetstreamNotify")

	Queue = Queue or {}
	Rate = Rate or {}
	Ready = Ready or {}


	function GetTargets(targets)
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


	function AddToQueue(name, final, payload, targets)
		local data = {
			Name = name,
			Final = final,
			Length = payload and payload.Length,
			Data = payload and payload.Data
		}

		for _, v in pairs(targets) do
			if not Queue[v] then
				Queue[v] = queue.New()
			end

			Queue[v]:Push(data)
		end
	end


	function Broadcast(name, data)
		Send(name, nil, data)
	end


	function Send(name, targets, data)
		targets = GetTargets(targets)

		if #targets < 1 then
			writeLog("Rejected: '%s' to NOBODY", name)

			return
		end

		if not data then
			writeLog("Outgoing: '%s' (NOTIFY) to %s", name, #targets > 1 and #targets .. " targets" or targets[1])

			AddToQueue(name, nil, nil, targets)

			return
		end

		local payload, size = Split(data)

		writeLog("Outgoing: '%s' (%s) to %s", name, string.NiceSize(size), #targets > 1 and #targets .. " targets" or targets[1])

		for k, v in pairs(payload) do
			AddToQueue(name, k == #payload, v, targets)
		end
	end


	function Read(name, ply)
		local final = net.ReadBool()
		local length = net.ReadUInt(15)
		local payload = net.ReadData(length)

		local cache = Cache[name]

		if not cache[ply] then
			cache[ply] = {}
		end

		table.insert(cache[ply], payload)

		if final then
			local raw = table.concat(cache[ply])

			table.Empty(cache[ply])

			return Decode(raw), #raw
		end
	end


	net.Receive("Netstream", function(_, ply)
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			writeLog("Rejected: '%s' from %s", name, ply)

			return
		end

		local data, len = Read(name, ply)

		if data then
			writeLog("Incoming: '%s' (%s) from %s", name, string.NiceSize(len), ply)

			callback(ply, data)
		end
	end)


	net.Receive("NetstreamNotify", function(_, ply)
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			writeLog("Rejected: '%s' from %s", name, ply)

			return
		end

		writeLog("Incoming: %s (NOTIFY) from %s", name, ply)

		callback(ply)
	end)


	hook.Add("OnPlayerReady", "Netstream", function(ply)
		Ready[ply] = true

		if Queue[ply] then
			local size = 0

			for _, v in pairs(Queue[ply].Items) do
				size = size + v.Length
			end

			writeLog("Ready: %s (%s queued)", ply, string.NiceSize(size))
		else
			writeLog("Ready: %s", ply)
		end
	end)


	hook.Add("Think", "Netstream", function()
		for k, v in pairs(Queue) do
			if not IsValid(k) then
				Queue[k] = nil
				Rate[k] = nil
				Ready[k] = nil

				continue
			end

			if not Ready[k] or Queue[k]:Count() < 1 then
				continue
			end

			Rate[k] = Rate[k] or TickLimit
			Rate[k] = math.Min(Rate[k] + (TickLimit * FrameTime()), TickLimit)

			while Rate[k] - MessageLimit > 0 do
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

						Rate[k] = Rate[k] - net.BytesWritten()
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
