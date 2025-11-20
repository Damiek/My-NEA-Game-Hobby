local module = {}

local Debris = game:GetService("Debris")
function module.PlaySound(Sound, Parent)
	local Sound = Sound:Clone()
	Sound.Parent = Parent
	Sound:Play()
	
	Debris:AddItem(Sound,5)
end
return module
