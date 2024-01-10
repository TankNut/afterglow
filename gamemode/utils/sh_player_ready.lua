function GM:OnPlayerReady(ply)
end

if CLIENT then
	hook.Add("InitPostEntity", "player_ready", function()
		hook.Remove("InitPostEntity", "player_ready")
		hook.Run("OnPlayerReady")
	end)
else
	net.Ready = net.Ready or {}

	gameevent.Listen("OnRequestFullUpdate")

	hook.Add("OnRequestFullUpdate", "player_ready", function(data)
		local ply = Player(data.userid)

		if net.Ready[ply] then
			return
		end

		net.Ready[ply] = true

		hook.Run("OnPlayerReady", ply)
	end)
end
