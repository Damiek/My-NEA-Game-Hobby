local RS = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")


local plr = game:GetService("Players").LocalPlayer
local char = plr.Character

local Events = RS.Events

local combatEvent = Events.Combat

uis.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end
	if char:GetAttribute("IsTransforming") then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		combatEvent:FireServer("Swing")
	end
end)


uis.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end
	if char:GetAttribute("IsTransforming") then return end

	if input.KeyCode == Enum.KeyCode.Q then
		combatEvent:FireServer("Dodge")
	end
end)

