local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rerollEvent = ReplicatedStorage.Events.RerollElement


char:GetAttributeChangedSignal("Race"):Connect(function()
	rerollEvent:FireServer()
end)