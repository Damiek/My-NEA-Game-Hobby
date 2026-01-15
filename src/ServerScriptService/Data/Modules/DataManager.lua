
local DataManager = {}


-- Store profiles from  ProfileStore
DataManager.Profiles = {}

function DataManager.IncreaseStat(plr,statName)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        local currentValue = profile.Data[currentSlot][statName]
        profile.Data[currentSlot][statName] = currentValue + 1
    end
end

function DataManager.ChangeElemment(plr,newValue)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Element = newValue
    end
    
end

function DataManager.AddExperience(plr,amount)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Experience = profile.Data[currentSlot].Experience + amount
    end
end

function DataManager.UpdateAccessories(plr,accessoryType,accessoryName)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Accessories[accessoryType] = accessoryName
    end
end
   



--[[
 This is the rules for handeling player data
 1. Always access player data through DataManager.Profiles[player]
 2. Do not store player data locally in other modules, always access it when needed
 3. When modifying player data, ensure you are modifying the correct slot by checking the "Current_Slot" attribute on the player's character
 4. Modify data here only, do not create new data stores in other modules
]]





return DataManager