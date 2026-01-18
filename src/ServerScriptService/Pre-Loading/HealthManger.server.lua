
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Helpful = require(ServerStorage.Modules.Other.Helpful)
local DataManager = require(ServerScriptService.Data.Modules.DataManager)



-- Configs
local LOW_HEALTH_THRESHOLD = 0.3 -- 30% of Max Health   
local INITIAL_MAX_HEALTH = 250




-- Function to initialize health on spawn/respawn
local function UpdateHealth(char)
    local VIT = char:GetAttribute("VIT")
    while VIT == nil do
        task.wait()
        VIT = char:GetAttribute("VIT")
    end
    
    print(VIT)
    local hum = char:WaitForChild("Humanoid")
   task.defer(function()
       hum.MaxHealth = INITIAL_MAX_HEALTH + VIT
       hum.Health = hum.MaxHealth
   end)
   
end

-- Function to continuously check low health without resetting health
local function monitorHealth()
    while true do
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health <= hum.MaxHealth * LOW_HEALTH_THRESHOLD then
                        plr.Character:SetAttribute("IsLow", true)
                        Helpful.ResetMobility(plr.Character)
                    else
                        plr.Character:SetAttribute("IsLow", false)
                        Helpful.ResetMobility(plr.Character)
                    end

                    plr.Character:GetAttributeChangedSignal("VIT"):Connect(function()
                        hum.MaxHealth = INITIAL_MAX_HEALTH + (plr.Character:GetAttribute("VIT"))
                    end)

                end
            end
        end
        task.wait(0.1)
    end
end

Players.PlayerAdded:Connect(function(plr)
    local char = plr.Character  or plr.CharacterAdded:Wait()
    char:SetAttribute("CurrentSlot", "SLOT_1")


    local profile
    while true do
		profile = DataManager.Profiles[plr]
        if profile then break end
        task.wait(0.1)
	end
    UpdateHealth(char)
end)

-- Start continuous low health monitoring
task.spawn(monitorHealth)

