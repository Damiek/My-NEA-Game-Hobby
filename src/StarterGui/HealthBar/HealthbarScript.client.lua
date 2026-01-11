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
-- UTILS
-------------------------------------------------
local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

-------------------------------------------------
-- STATE
-------------------------------------------------
local lastHealth = humanoid.Health
local maxHealth = humanoid.MaxHealth

-------------------------------------------------
-- TWEENS
-------------------------------------------------
local tweenFast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenSlow = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-------------------------------------------------
-- CORE UPDATE FUNCTION
-------------------------------------------------
local function applyBars(newHealth, oldHealth, useKarma)
	local healthPercent = clamp(newHealth / maxHealth, 0, 1)
	local oldPercent = clamp(oldHealth / maxHealth, 0, 1)

	-- HEALTH BAR (instant)
	TweenService:Create(healthBar, tweenFast, {
		Size = UDim2.new(
			healthPercent,
			0,
			healthBar.Size.Y.Scale,
			healthBar.Size.Y.Offset
		)
	}):Play()

	-- KARMA BAR
	if useKarma then
		-- delayed decay
		TweenService:Create(karmaBar, tweenSlow, {
			Size = UDim2.new(
				healthPercent,
				0,
				karmaBar.Size.Y.Scale,
				karmaBar.Size.Y.Offset
			)
		}):Play()
	else
		-- instant catch-up
		TweenService:Create(karmaBar, tweenFast, {
			Size = UDim2.new(
				healthPercent,
				0,
				karmaBar.Size.Y.Scale,
				karmaBar.Size.Y.Offset
			)
		}):Play()
	end
end

-------------------------------------------------
-- UI EVENT (DAMAGE / KARMA)
-------------------------------------------------
local function updateHealthBars(karmaDamage, currentHealth, maxH, damage)
	maxHealth = maxH or maxHealth

	local newHealth = currentHealth - damage
	lastHealth = currentHealth

	local karma = char:GetAttribute("Karma") or 0
	applyBars(newHealth, currentHealth, karma > 0)
end

Ui_Update.OnClientEvent:Connect(updateHealthBars)

-------------------------------------------------
-- HEALTH SYNC (NO EVENT NEEDED)
-------------------------------------------------
humanoid.HealthChanged:Connect(function(newHealth)
	if newHealth ~= lastHealth then
		local karma = char:GetAttribute("Karma") or 0
		applyBars(newHealth, lastHealth, karma > 0)
		lastHealth = newHealth
	end
end)

-------------------------------------------------
-- RESPAWN SAFETY
-------------------------------------------------
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	humanoid = char:WaitForChild("Humanoid")

	lastHealth = humanoid.Health
	maxHealth = humanoid.MaxHealth

	applyBars(humanoid.Health, humanoid.Health, false)
end)
