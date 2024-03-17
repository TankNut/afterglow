AddCSLuaFile()

SWEP.PrintName     = "Hands"
SWEP.Author        = "TankNut"

SWEP.Slot          = 1
SWEP.SlotPos       = 1

SWEP.DrawCrosshair = false

SWEP.UseHands      = true
SWEP.ViewModel     = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel    = ""

SWEP.Primary.Ammo          = "none"
SWEP.Primary.Automatic     = false
SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1

SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Automatic   = false
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1

function SWEP:Deploy()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end
