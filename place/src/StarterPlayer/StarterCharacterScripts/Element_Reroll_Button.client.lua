local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rerollEvent = ReplicatedStorage.Events.RerollElement

-- Example UI Button to trigger element reroll
local playerGui = player:WaitForChild("PlayerGui")

-- Create a simple UI button for rerolling element
local rerollButton = playerGui.RerollUi.Element_Reroll

-- When the button is clicked, trigger the reroll
rerollButton.MouseButton1Click:Connect(function()
	rerollEvent:FireServer()  -- Trigger the server-side element reroll
end)