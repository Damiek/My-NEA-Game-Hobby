local module = {}

local BlockingModule = require(script.Parent.Parent.BlockModule)


function module.CheckInFront(char,enemyChar)
	local enemyHRP = enemyChar.HumanoidRootPart
	local attackDirection = (char.HumanoidRootPart.Position - enemyHRP.Position).Unit
	local frontDirection = enemyHRP.CFrame.LookVector
	local direction = math.acos(attackDirection:Dot(frontDirection)) < math.rad(90)
	
	 if not direction then
		print("Not infront")
			return false
	 else
			print("infront")
			return true
	 end
end

function module.CheckForStatus(eChar,char,blockingDamage,hitPos,CheckForBlocking,CheckForParrying)
	local stop = false
	
	if CheckForParrying and not stop then
		if eChar:GetAttribute("Parrying") and module.CheckInFront(char,eChar) then 
			BlockingModule.Parrying(char,eChar,hitPos)  stop = true end
	end
	
	
	
	if CheckForBlocking and not stop then
		if eChar:GetAttribute("IsBlocking") and module.CheckInFront(char,eChar) then
			 BlockingModule.Blocking(eChar,blockingDamage,hitPos) stop = true end
		
	end
	
	if eChar.Humanoid.Health <= 0 or  eChar:GetAttribute("Iframes") then stop  = true end
	
	return stop
		
	
	
end

function module.CheckForAttributes(char,attack,swing,stun,ragdoll,equipped,blocking,Dodging)
	local attacking = char:GetAttribute("Attacking")
	local swing   = char:GetAttribute("Swing")
	local stunned  = char:GetAttribute("Stunned")
	local isEquipped = char:GetAttribute("Equipped")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	local isBlocking = char:GetAttribute("isBlocking")
	local isDodging = char:GetAttribute("Dodging")
	
	local stop = false
	
	
	if attacking and attack then stop = true end
	if swing and swing then stop = true end
	if stunned and stun then stop = true end
	if isRagdoll and ragdoll then stop = true end
	if equipped ~= nil and not isEquipped then stop = true end
	if blocking ~= nil and isBlocking then stop = true end
	if Dodging ~= nil and isDodging then stop = true end
	
	return stop
end






function module.Ragdoll(char,ragdollTime)
	task.spawn(function()
		if char:GetAttribute("IsRagdoll") then return end
		
		char:SetAttribute("IsRagdoll", true)
		task.wait(ragdollTime)
		char:SetAttribute("IsRagdoll",false)
		char:SetAttribute("iframes",true)
		Instance.new("Highlight",char)
		task.wait(.6)
		char.Highlight:Destroy()
		char:SetAttribute("iframes",false)
	end)
end
return module
