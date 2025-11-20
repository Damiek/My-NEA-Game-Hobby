local module = {}

local RS = game:GetService("ReplicatedStorage")

local AnimationsFolder = RS.Animations
local WeaponsAnimationsFolder = AnimationsFolder.Weapons

local lastSwing ={}
local MaxCombo = 4

function module.stopAnims(hum)
	for i,v in pairs(hum.Animator:GetPlayingAnimationTracks()) do
		if v.Name ~= "Idle" and v.Name ~= "Animation" then
			v:Stop()
		end

		
	end
end

function module.ChangeCombo(char)
	local combo = char:GetAttribute("Combo")
	
	if lastSwing[char] then
		local passedTime = tick() - lastSwing[char]
		if passedTime <=2 then
			if combo >= MaxCombo then
				char:SetAttribute("Combo",1)
			else
				char:SetAttribute("Combo",combo+1)
			end
		else
			char:SetAttribute("Combo",1)
		end
	end
	lastSwing[char] = tick()
end

function module.getSwingAnims(char, weaponName)
	local combo = char:GetAttribute("Combo")
	local currAnim = WeaponsAnimationsFolder[weaponName].Combat["Swing" .. combo]

	return currAnim
end






return module
