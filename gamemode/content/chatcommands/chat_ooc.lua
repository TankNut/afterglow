CLASS.Name = "OOC"
CLASS.Description = "Global out-of-character chat."

CLASS.Commands = {"ooc"}
CLASS.Aliases = {"//"}

if SERVER then
    function CLASS:Parse(ply, lang, cmd, text)
        return {
            Name = ply:GetCharacterName(),
            Text = text
        }
    end
end