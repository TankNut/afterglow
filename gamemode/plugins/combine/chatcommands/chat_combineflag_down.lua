CLASS.Name = "Flag down"
CLASS.Description = "Sets you as off-duty if you have a combine flag."

CLASS.Commands = {"unflag", "citizen"}

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		if not ply:HasCombineFlag() then
			ply:SendChat("ERROR", "You're not part of the combine!")

			return
		end

		if not ply:GetCombineFlagged() then
			ply:SendChat("ERROR", "You're not flagged up!")

			return
		end

		ply:SetCombineFlagged(false)
	end
end
