--[[ System By @Liam 
-> Version 1.3.3
 ♥ Thanks for using this!! ♥ 
--]] 



--||Character||--
local char = script.Parent
local hum = char:WaitForChild("Humanoid")
local torso = nil

if char:FindFirstChild("Torso") then
	torso = char:FindFirstChild("Torso") 
elseif char:FindFirstChild("UpperTorso") then
	torso = char:FindFirstChild("UpperTorso")
end

------------------------------------------------------------------------------------------------------------------




--//When the player gets ragdolled / unRagdolled
char:GetAttributeChangedSignal("IsRagdoll"):Connect(function()
	local isRagdoll = char:GetAttribute("IsRagdoll")
	if isRagdoll and torso then
		hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
		hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		torso:ApplyImpulse(torso.CFrame.LookVector * 75)
	else
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

--//this happens when the player dies
hum.Died:Connect(function()
	if not torso then return end
	torso:ApplyImpulse(torso.CFrame.LookVector * 100)
end)