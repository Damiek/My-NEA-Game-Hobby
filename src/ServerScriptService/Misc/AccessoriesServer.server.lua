
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local DataManager = require(script.Parent.Parent.Data.Modules.DataManager)
local AccessoriesModule = require(SS.Modules.Other.AccessoriesManager)

local Events = RS.Events
local AccessoryEvent = Events.AccessoryEvent

Players.PlayerAdded:Connect(function(plr)
    local char = plr.Character  or plr.CharacterAdded:Wait()
    local currentSlot = char:GetAttribute("CurrentSlot")
    local AccessoriesFolder = Instance.new("Folder")
    local WeldsFolder = Instance.new("Folder")
    WeldsFolder.Name = "Welds"
    WeldsFolder.Parent = AccessoriesFolder
    AccessoriesFolder.Name = "Accessories"
    AccessoriesFolder.Parent = char


    local profile
    while true do
		profile = DataManager.Profiles[plr]
        if profile then break end
        task.wait(0.1)
    end

    while profile.Data[currentSlot] == nil do
        task.wait()
        currentSlot = char:GetAttribute("CurrentSlot")
    end

    for accessoryType, accessoryName in pairs(profile.Data[currentSlot].Accessories) do
        if accessoryName ~= "" then
            AccessoriesModule.EquipAccessory(char, accessoryName)
        end
    end

   
end)

AccessoryEvent.OnServerEvent:Connect(function(plr,action, accessoryName, accessoryType)
    if action == "EquipAccessory" then
        local char = plr.Character
        if char:GetAttribute("InCombat") then return end  -- Cant change accessories in combat
      
        AccessoriesModule.EquipAccessory(char, accessoryName)
        DataManager.UpdateAccessories(plr, accessoryType, accessoryName)
    end
end)


Players.PlayerRemoving:Connect(function(plr)
    AccessoriesModule.cleanup(plr)
end)