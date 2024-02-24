function GM:OnPlayerReady(ply)
end


if CLIENT then
	hook.Add("InitPostEntity", "PlayerReady", function()
		hook.Remove("InitPostEntity", "player_ready")
		hook.Run("OnPlayerReady")
	end)
end


if SERVER then
	net.Ready = net.Ready or {}

	gameevent.Listen("OnRequestFullUpdate")


	hook.Add("OnRequestFullUpdate", "PlayerReady", function(data)
		local ply = Player(data.userid)

		if net.Ready[ply] then
			return
		end

		net.Ready[ply] = true

		hook.Run("OnPlayerReady", ply)
	end)
end
