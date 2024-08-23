function Combine.AddDoorTypes()
	Door.AddAccessType("Combine", {
		Color = Color(33, 106, 196),
		Callback = function(self, ply)
			return ply:GetCombineFlagged()
		end,
		OnDenied = function(self, ply)
			if self:GetNWFloat("NextDoorSound", 0) > CurTime() then
				return
			end

			self:EmitSound("buttons/combine_button_locked.wav")
			self:SetNWFloat("NextDoorSound", CurTime() + 1)
		end
	})
end

hook.Add("LoadPluginContent", "Plugin.Combine", function()
	CombineFlag.AddFolder("content/combineflags")

	Chat.AddFolder("plugins/combine/chatcommands")
	Command.AddFolder("plugins/combine/commands")
	Hud.AddFolder("plugins/combine/hudelements")

	Combine.AddDoorTypes()
end)
