local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ui_Update = ReplicatedStorage.Events.UI_Update

local player = game.Players.LocalPlayer
local char = player.Character
local gui = player.PlayerGui
local healthBarFrame = gui.HealthBar.HealthFrame
local healthBar = healthBarFrame.HealthBar  -- Green bar
local karmaBar = healthBarFrame.KarmaBar -- Purple bar

local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

local function updateHealthBars(karmaDamage, currentHealth, maxHealth, damage)
	
	local newHealth = currentHealth - damage
	local healthPercent = clamp(newHealth / maxHealth, 0, 1)
	local karmaPercent = clamp(currentHealth / maxHealth, 0, 1) -- Shows the old health value temporarily

	local tweenInfoFast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Immediate drop
	local tweenInfoSlow = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Slow decay

	TweenService:Create(healthBar, tweenInfoFast, { Size = UDim2.new(healthPercent, 0, 1, 0) }):Play()
	if char:GetAttribute("Karma",0) then
		TweenService:Create(karmaBar, tweenInfoFast, { Size = UDim2.new(healthPercent, 0, 1, 0) }):Play()
	else
		TweenService:Create(karmaBar, tweenInfoSlow, { Size = UDim2.new(healthPercent, 0, 1, 0) }):Play()
	end
	
end

-- Event Listener
Ui_Update.OnClientEvent:Connect(updateHealthBars)
