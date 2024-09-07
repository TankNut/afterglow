local meta = FindMetaTable("Player")

Character.AddVar("Money", {
	Accessor = "Money",
	Default = 0
})

function meta:HasMoney(amount)
	return self:GetMoney() >= amount
end

if SERVER then
	function meta:AddMoney(amount)
		self:SetMoney(math.max(self:GetMoney() + amount, 0))
	end
end
