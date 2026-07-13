--[Services]--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TS = game:GetService("TweenService")


local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local Cast = require(RS.Modules.Cast)
local Movement = require(RS.Modules.Movement.Objects.Movement)
local Crouch = require(RS.Modules.Movement.Mechnanics.Crouch)
local Wallrun = require(RS.Modules.Movement.Mechnanics.Wallrun)
local Sprint = require(RS.Modules.Movement.Mechnanics.Sprinting)
--[Player Variables]--
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HRP: Part = char:WaitForChild("HumanoidRootPart")
local Hum = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera

--[UI Variables]--
local playerGui = plr:WaitForChild("PlayerGui")
local MovementUI = playerGui:WaitForChild("MovementUI")
local top = MovementUI:WaitForChild("Top")
local bottom = MovementUI:WaitForChild("Bottom")
local Top_tilt = MovementUI:WaitForChild("Top_Tilt")
local Bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt")

local Events = RS.Events
local MovementEvent = Events.Movement
local AccessoryEvent = Events.AccessoryEvent

-- Wait for CurrentWeapon and the movement object
local CurrentWeapon = char:GetAttribute("CurrentWeapon")
while CurrentWeapon == nil do
	CurrentWeapon = char:GetAttribute("CurrentWeapon")
	if CurrentWeapon then
		break
	end
	task.wait(0.3)
end

local object = Movement.new(plr)

--[Animation Setup]--
local WeaponAnimations = RS.Animations.Weapons
local MovementAnimationsFolder = WeaponAnimations[CurrentWeapon].Movement

local WallClimbAnim = Hum.Animator:LoadAnimation(MovementAnimationsFolder.WallClimb)

--[State]--
local canClimb = false
local lastClimbState = nil
local heldKeys = {}
local IsHoldingLedge = false
local LedgeGrabCoolDown = false



local LastKeyPressTime = 0
local doubleTapThreshold = 0.3
local velocityDecay = 0.3
local MaxClimbheight = 40


-- Offscreen positions (top slides up, bottom slides down)
local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)


-- Normal (resting) positions
local TOP_NORMAL = UDim2.new(-0.001, 0, -0.187, 0)
local BOTTOM_NORMAL = UDim2.new(-0.034, 0, 0.75, 0)

-- Breathe positions
local TOP_INHALE = UDim2.new(-0.001, 0, -0.15, 0)
local BOTTOM_INHALE = UDim2.new(-0.034, 0, 0.72, 0)

local tweenSlide = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenBreathe = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- Set bars offscreen initially
top.Position = TOP_HIDDEN
bottom.Position = BOTTOM_HIDDEN

Top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
Bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT

Top_tilt.Rotation = 0
Bottom_tilt.Rotation = 0

-------------------------------------------------
-- WALK  Cycles
-------------------------------------------------

char:GetAttributeChangedSignal("CurrentWeapon"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("Equipped"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("IsLow"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("InCombat"):Connect(function()
	object:UpdateWalkTracks()
end)
AccessoryEvent.OnClientEvent:Connect(function(action)
	if action == "RefreshAnimations" then
		object:UpdateWalkTracks()
	end
end)

object:UpdateWalkTracks()






-------------------------------------------------
-- WALL CLIMB
-------------------------------------------------
local function triggerWallClimb()
	if object.IsActing.WallRunning then
		return
	end
	object.States.IsGrounded = true
	object.IsActing.Climbing = true
	-- here i would use the request to update the servers movemnt obj and vaildate 
	

	WallClimbAnim:Play()

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = HRP.CFrame.LookVector + Vector3.new(0, MaxClimbheight, 0)
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Parent = HRP
	Debris:AddItem(bv, velocityDecay)

	task.delay(0.2, function()
		SoundsModule.PlaySound(SFX.SFX.Movement.ClimbSound)
	end)

	task.delay(1, function()
		object.IsActing.Climbing = false
		-- I would use the request to update the server's movement obj
	end)
end

-------------------------------------------------
-- SPRINT SYSTEM
-------------------------------------------------


local baseSpeed = StarterPlayer.CharacterWalkSpeed






MovementEvent.OnClientEvent:Connect(function(action)
    if action == "AstralDodge" then
        local WasSprinting = object.IsActing.IsSprinting
        local WasExSprinting = object.IsActing.IsEXSprinting

        if WasSprinting or WasExSprinting then
            Sprint.NormalToggle(object)
        end

        local dodgeSpeed = baseSpeed * 5
        Hum.WalkSpeed = dodgeSpeed
        TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 160 }):Play()

        task.delay(5, function()
            if not object.IsActing.IsSprinting and not object.IsActing.IsEXSprinting then
                Hum.WalkSpeed = baseSpeed
                TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()

                if WasSprinting then
                    Sprint.NormalToggle(object)
                    if WasExSprinting then
                        Sprint.ExToggle(object)
                    end
                end
            end
        end)
    end
end)


char:GetAttributeChangedSignal("Attacking"):Connect(function()
    Sprint.OnCharStateChanged(object)
end)

char:GetAttributeChangedSignal("Stunned"):Connect(function()
    Sprint.OnCharStateChanged(object)
end)

char:GetAttributeChangedSignal("IsBlocking"):Connect(function()
    Sprint.OnCharStateChanged(object)
end)

-------------------------------------------------
-- RENDER STEPPED — Walk weights
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	object:WalkCycle()
end)


local function FindFowardwall(char)
	local HRP = char.HumanoidRootPart
	if not HRP then
		return
	end

	local hitClimable = false

	local offsets = {
		Vector3.new(0, 0, 0), -- Center
		Vector3.new(0, 1.5, 0), -- Upper
		Vector3.new(0, -1.5, 0), -- Lower
	}

	for _, offset in ipairs(offsets) do
		local origin = HRP.Position + offset

		local result = Cast.Ray({
			Origin = origin,
			Direction = HRP.CFrame.LookVector,
			Range = 5,
			FilterList = { char },
		})

		if result and result.Instance:GetAttribute("Climable") == true then
			hitClimable = true
			break
		end
	end

	canClimb = hitClimable
	if hitClimable ~= lastClimbState then
		lastClimbState = hitClimable
	end
end


RunService.Heartbeat:Connect(function(dt)
	Wallrun.Start(object)
end)

local function slideOutBars()
	TS:Create(top, tweenSlide, { Position = TOP_HIDDEN }):Play()
	TS:Create(bottom, tweenSlide, { Position = BOTTOM_HIDDEN }):Play()
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UIS.InputBegan:Connect(function(input, isTyping)
    if isTyping then
        return
    end
    local key = input.KeyCode

    if key == Enum.KeyCode.W then
        heldKeys.W = true

        if Sprint.CanSprint(object) then
            local currentTime = tick()
            if currentTime - LastKeyPressTime <= doubleTapThreshold then
                Sprint.NormalToggle(object)
            end
            LastKeyPressTime = currentTime
        end
    elseif key == Enum.KeyCode.LeftShift then
        Sprint.ExToggle(object)
    elseif key == Enum.KeyCode.S then
        if IsHoldingLedge then
            IsHoldingLedge = false
            char:SetAttribute("LedgeHold", false)
            MovementEvent:FireServer("ReleaseLedge", false)
            TS:Create(cam, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
            return
        end
    end

    if key == Enum.KeyCode.Space then
        if IsHoldingLedge then
            IsHoldingLedge = false
            char:SetAttribute("LedgeHold", true)
            MovementEvent:FireServer("ReleaseLedge", true)
            TS:Create(cam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 95 }):Play()

            if top.Position ~= TOP_HIDDEN then
                slideOutBars()
            end
            task.delay(0.15, function()
                TS:Create(cam, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
            end)
            return
        end

        FindFowardwall(char)

        if object.States.IsInAir and heldKeys.W and canClimb and not object.IsActing.Climbing then
            if object.IsActing.IsSprinting or object.IsActing.IsEXSprinting then
                Sprint.NormalToggle(object)
                task.wait(0.15)
            end
            triggerWallClimb()
        end

        if object.IsActing.WallRunning then
            Wallrun.Jump(object)
        end
    end

    if key == Enum.KeyCode.LeftControl then
        Crouch.Start(object)
    end
end)

UIS.InputEnded:Connect(function(input, isTyping)
    if isTyping then
        return
    end
    local key = input.KeyCode

    if key == Enum.KeyCode.W then
        heldKeys.W = nil
        if object.IsActing.IsSprinting or object.IsActing.IsEXSprinting then
            Sprint.NormalToggle(object)
        end
    elseif key == Enum.KeyCode.LeftAlt then
        if object.IsActing.IsEXSprinting then
            Sprint.ExToggle(object)
        end
    end
end)

-------------------------------------------------
-- HUMANOID STATE
-------------------------------------------------
Hum.StateChanged:Connect(function(_, newState) -- other state stuff
	if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
		object.States.IsInAir = true 
		object.States.IsGrounded = false
	elseif newState == Enum.HumanoidStateType.Landed then
		object.States.IsInAir = false
		object.States.IsGrounded = true
	end
end)

function CrouchStatesChecker(_, Newstates)
	if object.States.IsCrouching then
		if
			Newstates == Enum.HumanoidStateType.Dead
			or Newstates == Enum.HumanoidStateType.Climbing
			or Newstates == Enum.HumanoidStateType.Swimming
			or Newstates == Enum.HumanoidStateType.Seated
			or Newstates == Enum.HumanoidStateType.Physics
		then
			object.InfoTable.Crouch.Stop()
		end
	end
end

Hum.StateChanged:Connect(CrouchStatesChecker)
-------------------------------------------------
-- LEDGES
-------------------------------------------------
task.wait(3)
local ledges = workspace.ParkorTeststuff.Ledges:GetChildren()

local function breatheFOV()
	if not IsHoldingLedge then
		TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
		slideOutBars()
		return
	end

	-- FOV tweens
	local inhale = TS:Create(cam, tweenBreathe, { FieldOfView = 63 })
	local exhale = TS:Create(cam, tweenBreathe, { FieldOfView = 65 })

	-- Bar tweens (inhale = bars close in, exhale = bars open back)
	local barsInhale_Top = TS:Create(top, tweenBreathe, { Position = TOP_INHALE })
	local barsInhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_INHALE })
	local barsExhale_Top = TS:Create(top, tweenBreathe, { Position = TOP_NORMAL })
	local barsExhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_NORMAL })

	inhale:Play()
	barsInhale_Top:Play()
	barsInhale_Bottom:Play()

	inhale.Completed:Connect(function()
		if not IsHoldingLedge then
			TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 70 })
				:Play()
			slideOutBars()
			return
		end

		exhale:Play()
		barsExhale_Top:Play()
		barsExhale_Bottom:Play()

		exhale.Completed:Connect(function()
			breatheFOV()
		end)
	end)
end

local function startBreath()
	-- Slide bars in first, then start breathing once they arrive
	TS:Create(top, tweenSlide, { Position = TOP_NORMAL }):Play()
	local slideIn = TS:Create(bottom, tweenSlide, { Position = BOTTOM_NORMAL })
	slideIn:Play()
	slideIn.Completed:Connect(function()
		if IsHoldingLedge then
			breatheFOV()
		end
	end)
end

for _, ledge in ledges do
	ledge.Touched:Connect(function(part)
		if LedgeGrabCoolDown or IsHoldingLedge or not object.IsActing.Climbing then
			return
		end
		if not part:IsDescendantOf(char) then
			return
		end

		LedgeGrabCoolDown = true
		IsHoldingLedge = true
		object.IsActing.Climbing = false
		MovementEvent:FireServer("LedgeHold", ledge)

		task.delay(0.1, function()
			if IsHoldingLedge then
				startBreath()
			end
		end)

		task.wait(0.4)
		LedgeGrabCoolDown = false
	end)
end
