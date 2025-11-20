local RS = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character

local Events = RS.Events

local blockingEvent =  Events.Blocking

local debounce = false 



local function startBlocking()

	debounce = true
	blockingEvent:FireServer("Blocking")
	task.wait(1)
	debounce =false
	
end


local function stopBlocking()
	blockingEvent:FireServer("UnBlocking")
	
end

uis.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end
	if char:GetAttribute("IsTransforming") then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		blockingEvent:FireServer("Parry")

	end
end)







	

uis.InputBegan:Connect(function(key,istyping)
	if istyping or debounce then return end
	if char:GetAttribute("IsTransforming") then return end
	
	if key.KeyCode == Enum.KeyCode.F then
		startBlocking()
	end
end)

uis.InputEnded:Connect(function(key)
	if char:GetAttribute("IsTransforming") then return end
	if key.KeyCode == Enum.KeyCode.F then
	
		stopBlocking()
		
	end
	
end)


char:GetAttributeChangedSignal("Blocking"):Connect(function()
	if char:GetAttribute("Blocking") > 100 then
		stopBlocking()
	end
end)