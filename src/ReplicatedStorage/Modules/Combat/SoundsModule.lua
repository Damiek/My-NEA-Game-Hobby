local module = {}

local Debris = game:GetService("Debris")
function module.PlaySound(TargetSound, Parent)
	local Sound = TargetSound:Clone()
	Sound.Parent = Parent
	Sound:Play()
	
	Debris:AddItem(Sound,5)
end


return module
