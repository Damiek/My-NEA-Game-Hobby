--[[ System By @Liam 
-> Version 1.3.3
 ♥ Thanks for using this!! ♥ 
--]] 



--||Services||--
local UIS = game:GetService("UserInputService")

--||Character||--
local char = script.Parent
local hum = char:WaitForChild("Humanoid")
local torso = nil
local capturedBehavior = nil

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
		capturedBehavior = UIS.MouseBehavior
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
		hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		torso:ApplyImpulse(torso.CFrame.LookVector * 75)
	else
		if capturedBehavior then
			UIS.MouseBehavior = capturedBehavior
			capturedBehavior = nil
		end
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

--//this happens when the player dies
hum.Died:Connect(function()
	if capturedBehavior then
		UIS.MouseBehavior = capturedBehavior
		capturedBehavior = nil
	end
	if not torso then return end
	torso:ApplyImpulse(torso.CFrame.LookVector * 100)
end)