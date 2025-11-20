local uis = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")




local Events =RS.Events
local Transform = Events.Tranform

local WeaponsEvent= Events.WeaponsEvent
local plr = game.Players.LocalPlayer
local char =plr.Character





uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 
	
	if input.keyCode == Enum.KeyCode.E then
		WeaponsEvent:FireServer("Equip/UnEquip")
		
	     
	end
	
end)

