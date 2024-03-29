local meta = FindMetaTable("Player")

-- Badges are sorted in-game in reverse order, bottom to top
Badge.Add("admin", "Admin", "icon16/shield.png", function(ply) return ply:GetUserGroup() == "admin" end)
Badge.Add("superadmin", "Superadmin", "icon16/shield_add.png", function(ply) return ply:GetUserGroup() == "superadmin" end)
Badge.Add("developer", "Developer", "icon16/tag.png", function(ply) return ply:GetUserGroup() == "developer" end)

Badge.Add("template", "Template Character", "icon16/computer.png", meta.IsTemplateCharacter)
Badge.Add("bot", "Bot", "icon16/monkey.png", meta.IsBot)

Badge.Add("betatester", "Beta Tester", "icon16/controller.png")
Badge.Add("bughunter", "Bug Hunter", "icon16/bug.png")
