local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ui_Update = ReplicatedStorage.Events.UI_Update

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local healthBarGui = script.Parent
local healthBar = healthBarGui.HealthBar
local karmaBar = healthBarGui.KarmaBar

-------------------------------------------------
-- TWEENS
-------------------------------------------------
local tweenFast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenSlow = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-------------------------------------------------
-- CORE UPDATE FUNCTION
-------------------------------------------------
local function applyBars(useKarma)
    -- Always pull fresh values to prevent "overshooting" or scaling issues
    local currentHealth = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    
    -- Ensure we never divide by zero and clamp between 0 and 1
    local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)

    -- HEALTH BAR
    TweenService:Create(healthBar, tweenFast, {
        Size = UDim2.fromScale(healthPercent, healthBar.Size.Y.Scale)
    }):Play()

    -- KARMA BAR
    local karmaTween = useKarma and tweenSlow or tweenFast
    TweenService:Create(karmaBar, karmaTween, {
        Size = UDim2.fromScale(healthPercent, karmaBar.Size.Y.Scale)
    }):Play()
end

-------------------------------------------------
-- CONNECTIONS
-------------------------------------------------

-- Listen for Health changes
humanoid.HealthChanged:Connect(function()
    local karma = char:GetAttribute("Karma") or 0
    applyBars(karma > 0)
end)

-- FIX: Listen for MaxHealth changes (important for level-ups/buffs)
humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
    applyBars(false)
end)

-- UI EVENT (If triggered by server for specific damage effects)
Ui_Update.OnClientEvent:Connect(function()
    local karma = char:GetAttribute("Karma") or 0
    applyBars(karma > 0)
end)

-- RESPAWN SAFETY
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = char:WaitForChild("Humanoid")
    
    -- Re-bind listeners to the new humanoid
    humanoid.HealthChanged:Connect(function()
        local karma = char:GetAttribute("Karma") or 0
        applyBars(karma > 0)
    end)
    
    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        applyBars(false)
    end)

    applyBars(false)
end)