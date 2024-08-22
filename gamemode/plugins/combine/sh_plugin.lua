Combine = Combine or {}

Combine.DefaultTeam = TEAM_COMBINE

IncludeFile("sh_combineflag.lua")
IncludeFile("sh_vars.lua")
IncludeFile("sh_hooks.lua")

function Combine.GetCID(seed)
	if seed then
		math.randomseed(seed)
	end

	local str = ""

	for i = 1, 5 do
		str = str .. math.random(0, 9)
	end

	return str
end

function Combine.AddDoorTypes()
	if not Door then
		return
	end

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

if SERVER then
	hook.Add("PreCreateCharacter", "Plugin.Combine", function(ply, fields)
		fields[Character.VarToField("CID")] = Combine.GetCID()
	end)
end
