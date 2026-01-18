local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


--- Data Constants  DO NOT TOUCH THIS WILL NUKE THE PLAYERS DATA IF HANDLED WRONG
local DataManager = require(ServerScriptService.Data.Modules.DataManager)


--- Functions
local function updatePlayerStats(plr,char,Stat)
	DataManager.IncreaseStat(plr, Stat)
end



Players.PlayerAdded:Connect(function(plr)
    -- Wait for profile to be ready
    local profile
    while true do
		profile = DataManager.Profiles[plr]
        if profile then break end
        task.wait(0.1)
	end
	
	local char = plr.Character

	
	local CurrentSlot = char:GetAttribute("CurrentSlot")
	for statName, value in pairs(profile.Data[CurrentSlot].STAT_POINTS) do 
		char:SetAttribute(statName, value)
	end
	
end)
