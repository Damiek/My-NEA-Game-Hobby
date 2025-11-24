local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local UserInputService = game:GetService("UserInputService")
local DodgeEvent = game:GetService("ReplicatedStorage").Events.Dodge

local DODGE_SPEED = 100
local DODGE_TIME = 0.15

local debounce = false

local function doDodge()
	-- Smooth client dash using BodyVelocity
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e6, 0, 1e6)
	bv.Velocity = hrp.CFrame.LookVector * DODGE_SPEED
	bv.Parent = hrp

	game.Debris:AddItem(bv, DODGE_TIME)

	task.delay(DODGE_TIME, function()
		debounce = false
	end)
end

-- Input
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Q then
		DodgeEvent:FireServer("Dodge")

		
	end
end)


for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
	if anim.Name == "Dodge" then
		anim.GetMarkerReachedSignal("Dodge"):Connect(function()
			doDodge()
		end)
	end
end