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

-- Client doesn't get to compress because we don't trust people not to abuse it, if we're sending enough data that it's a problem then something's gone horribly wrong.
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

	net.Receive("Netstream", function()
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			return
		end

		local final = net.ReadBool()
		local length = net.ReadUInt(15)
		local payload = net.ReadData(length)

		local cache = Cache[name]

		table.insert(cache, payload)

		if final then
			local raw = table.concat(cache)

			writeLog("Incoming: '%s' (%s) from SERVER", name, string.NiceSize(#raw))

			table.Empty(cache)

			callback(Decode(raw))
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
else
	util.AddNetworkString("Netstream")
	util.AddNetworkString("NetstreamNotify")

	Queue = Queue or {}
	Rate = Rate or {}
	Ready = Ready or {}

	function GetTargets(targets)
		local result = targets

		if isstring(targets) then
			-- Way too common of a mistake, smh
			error("netstream.Send missing targets arg, found name instead?")
		end

		if not targets then
			result = player.GetAll()
		elseif TypeID(targets) == TYPE_RECIPIENTFILTER then
			result = targets:GetPlayers()
		elseif not istable(targets) then
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
		Send(nil, name, data)
	end

	function Send(targets, name, data)
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

	net.Receive("Netstream", function(_, ply)
		local name = net.ReadString()
		local callback = Hooks[name]

		if not callback then
			writeLog("Rejected: '%s' from %s", name, ply)

			return
		end

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

			writeLog("Incoming: '%s' (%s) from %s", name, string.NiceSize(#raw), ply)

			table.Empty(cache[ply])

			callback(ply, Decode(raw))
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
