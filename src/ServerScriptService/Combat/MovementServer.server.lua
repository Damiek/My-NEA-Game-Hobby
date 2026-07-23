local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local SS = game:GetService("ServerStorage")

local RSModules = RS.Modules
local Helpful = require(SS.Modules.Other.Helpful)
local Movement = require(RSModules.Movement.Objects.Movement)
local SoundsModule = require(RSModules.Combat.SoundsModule)
local Flowmanager = require(RSModules.Movement.Ultils.Flow)
local StatusEffects = require(SS.Modules.StatusEffectsModule)

local Events = RS.Events
local MovementEvent: RemoteEvent = Events.Movement
local VFX_Event: RemoteEvent = Events.VFX

local WeaponAnims = RS.Animations.Weapons

local ActiveDodges = {}

local function CleanupForPlayer(plr)
	ActiveDodges[plr] = nil
end

MovementEvent.OnServerEvent:Connect(function(plr, action, ...)
	local char = plr.Character
	local Humanoid = char:FindFirstChildOfClass("Humanoid")
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local HRP: Part = char.HumanoidRootPart
	local Torso = char.Torso
	local MovementObj = Movement.GetMovementObj(plr)

	if action == "LedgeHold" then
		if not Humanoid or not HRP then
			return
		end
		local ledge: Part = ...
		local LedgeHoldAnimation = Humanoid.Animator:loadAnimation(WeaponAnims[CurrentWeapon].Movement.LedgeGrab)

		HRP.Anchored = true
		Humanoid.AutoRotate = false
		local yOffset = -1.5
		local LedgeDistance = 0.4

		local ledgeForward = -ledge.CFrame.LookVector
		local HorizontalLedgeFoward = Vector3.new(ledgeForward.X, 0, ledgeForward.Z).Unit

		local currentXZ = Vector3.new(HRP.Position.X, 0, HRP.Position.Z)
		local LedgeY = ledge.Position.Y
		local offset = currentXZ + HorizontalLedgeFoward * -LedgeDistance
		local finalPostion = Vector3.new(offset.X, LedgeY + yOffset, offset.Z)

		local lookat = finalPostion + HorizontalLedgeFoward
		HRP.CFrame = CFrame.new(finalPostion, lookat)

		LedgeHoldAnimation:Play(0.3)
	end

	if action == "ReleaseLedge" then
		local Vault = ...
		for i, anim in Humanoid:GetPlayingAnimationTracks() do
			if anim.Name == "LedgeGrab" then
				anim:Stop()
			end
		end

		if Vault then
			local jumpAnim = Humanoid.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Movement.Vault)
			jumpAnim:Play()
			HRP.Anchored = false
			Humanoid.AutoRotate = true

			local bv = Instance.new("BodyVelocity")
			bv.Velocity = HRP.CFrame.LookVector * 35 + Vector3.new(0, 25, 0)
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.P = 1250
			bv.Parent = HRP
			Debris:AddItem(bv, 0.3)

			SoundsModule.PlaySound(SFX.SFX.Movement.LeapSound, HRP)

			VFX_Event:FireAllClients(
				"Highlight",
				char,
				0.9,
				Color3.fromRGB(173, 173, 173),
				Color3.fromRGB(176, 175, 175)
			)
		else
			HRP.Anchored = false
			Humanoid.AutoRotate = true
		end
	end

	if action == "CrouchStart" then
		print("Server has gotton crouch request")
		print(MovementObj.States)
		if MovementObj.States.IsCrouching then
			return
		end
		print("SOundPLAyes?")
		SoundsModule.PlaySound(SFX.SFX.Movement.Crouch, Torso)
		MovementObj.States.IsCrouching = true
	end

	if action == "Dodge" then
	print("Dodge gotten")
    local Config = {
        DashDur = 0.25,
        Buffer_distance = 10.0, -- Increased slightly to fully cushion network-to-physics latency
        Speed = 85
    }

    if char:GetAttribute("Dodging") == true then return end 
    if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, true) then return end 
    
    -- STAMINA VALIDATION
    if Helpful.ManageStamina(char, action) then 
        plr:Kick("Stamina Spoofing for Dodge")
        return
    end

    -- 1. CAPTURE THE SNAPSHOT BEFORE RUNNING MODIFIERS/RESETS
    local flowBonus = Flowmanager.GetFlowBonus(MovementObj)
    -- Fallback to verify we read the momentum before any OnDodgeStart resets it to 0
    local preDodgeMomentum = (MovementObj.Flow and MovementObj.Flow.Momentum) or 0
    local isAir = MovementObj.States.IsInAir or (HRP.AssemblyLinearVelocity.Y > 5) -- Secondary check for rapid jump-cancels

    char:SetAttribute("Dodging", true)
    StatusEffects.RemoveStatusEffect(char, nil, "Burn")

    local element = char:GetAttribute("Element")
    if element == "Astral" and char:GetAttribute("Mode2") then
        VFX_Event:FireAllClients("AfterImage", char, nil, "AstralDodge")
    end

    -- 2. Calculate the authoritative speed using the pre-snapshot data
    local momentumMultiplier = 1.0 + ((preDodgeMomentum / 100) * 0.50)
    local baseSpeed = Config.Speed * flowBonus * momentumMultiplier
    if isAir then baseSpeed = baseSpeed * 1.15 end

    -- Now safe to start the flow transition state window
    Flowmanager.OnDodgeStart(MovementObj)
    MovementObj.IsActing.Dodging = true

    local StartTime = workspace:GetServerTimeNow()
    local StartPosition = HRP.Position

    ActiveDodges[plr] = {
        StartTime = StartTime,
        StartPos = StartPosition,
        Speed = baseSpeed,
        WasAirborne = isAir
    }

    task.delay(Config.DashDur, function()
        if not char or not HRP then 
            ActiveDodges[plr] = nil
            return
        end

        char:SetAttribute("Dodging", false)
        MovementObj.IsActing.Dodging = false
        
        Flowmanager.OnDodgeEnd(MovementObj, function() end)

        local TrackedVictim = ActiveDodges[plr]
        if TrackedVictim then
            local endpos = HRP.Position
            local Travel = (endpos - TrackedVictim.StartPos).Magnitude
        
            local actualTimeElapsed = workspace:GetServerTimeNow() - TrackedVictim.StartTime
            local timeWindow = math.max(Config.DashDur, actualTimeElapsed)

  
            local ExpectedDistance = TrackedVictim.Speed * timeWindow
     
            if TrackedVictim.WasAirborne then
                local gravityVectorMagnitude = (workspace.Gravity * Config.DashDur) * timeWindow
                ExpectedDistance = ExpectedDistance + gravityVectorMagnitude
            end

            local MaxDistance = ExpectedDistance + Config.Buffer_distance

            if Travel > MaxDistance then
                warn(string.format("[ANTI-CHEAT] %s speed mismatch detected! Distance: %.2f | Allowed: %.2f (Airborne: %s) | Elapsed Time: %.3f", 
                    plr.Name, Travel, MaxDistance, tostring(TrackedVictim.WasAirborne), actualTimeElapsed))
                Humanoid.Health = 0
                plr:Kick("Dodge Speed Validation Failure")
            end
            ActiveDodges[plr] = nil
        end
    end)
end

	if action == "DodgeCancel" then
		if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, false) then
			plr:Kick("Illegal action: State Stacking done on dodge cancel")
			return
		end
		Helpful.RefundStamina(char, action)

		-- Synchronize server object state tracking properties
		MovementObj.IsActing.Dodging = false
		Flowmanager.OnDodgeEnd(MovementObj, function() end)

		VFX_Event:FireAllClients("Highlight", char, 0.5, Color3.fromRGB(173, 173, 173), Color3.fromRGB(255, 255, 255))
	end
	if action == "DodgeCancel" then
		if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, false) then
			plr:Kick("Illgal action: State Stacking done on dodge cancel")
		end
		Helpful.RefundStamina(char, action)
		VFX_Event:FireAllClients("Highlight", char, 0.5, Color3.fromRGB(173, 173, 173), Color3.fromRGB(255, 255, 255))
	end

	if action == "WallRunStart" then
		--- Stuff
	end

	if action == "WallRunEnd" then
		-- end stuff
	end

	if action == "WallRunJump" then
		VFX_Event:FireAllClients("Highlight", char, 0.4, Color3.fromRGB(255, 240, 240), Color3.fromRGB(235, 235, 235))
		Flowmanager.OnMechanicJump(MovementObj, "WallRunJump")
	end

	if action == "ExSprintStart" then
		local isOutOfStamina = Helpful.ManageStamina(char, "ExSprint")

		if isOutOfStamina then
			char:SetAttribute("IsEXSprinting", false)
			char:SetAttribute("Sprinting", false)
			if MovementObj then
				MovementObj.IsActing.IsEXSprinting = false
				MovementObj.IsActing.IsSprinting = false
			end
		else
			char:SetAttribute("IsEXSprinting", true)
			char:SetAttribute("Sprinting", true)
			if MovementObj then
				MovementObj.IsActing.IsEXSprinting = true
				MovementObj.IsActing.IsSprinting = true
			end
		end
	end

	if action == "ExSprintEnd" then
		char:SetAttribute("IsEXSprinting", false)
		if MovementObj then
			MovementObj.IsActing.IsEXSprinting = false
		end
	end
end)
