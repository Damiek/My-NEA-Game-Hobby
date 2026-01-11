local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Helpful = require(ServerStorage.Modules.Other.Helpful)


-- Function to initialize health on spawn/respawn
local function initializeHumanoid(char)
    local hum = char:WaitForChild("Humanoid")
    hum.MaxHealth = 250
    hum.Health = hum.MaxHealth
end

-- Function to continuously check low health without resetting health
local function monitorLowHealth()
    while true do
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health <= hum.MaxHealth * 0.3 then
                        plr.Character:SetAttribute("IsLow", true)
                        Helpful.ResetMobility(plr.Character)
                    else
                        plr.Character:SetAttribute("IsLow", false)
                        Helpful.ResetMobility(plr.Character)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(initializeHumanoid)
end)

-- Start continuous low health monitoring
task.spawn(monitorLowHealth)
