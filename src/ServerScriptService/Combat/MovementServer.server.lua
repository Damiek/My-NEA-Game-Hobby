local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local SS = game:GetService("ServerStorage")

local RSModules = RS.Modules
local Helpful = require(SS.Modules.Other.Helpful)
local Movement = require(RSModules.Movement.Objects.Movement)
local SoundsModule = require(RSModules.Combat.SoundsModule)
local Flowmanager = require(RSModules.Movement.Ultils.Flow)
local MovementData = require(RSModules.Movement.Data)
local StatusEffects = require(SS.Modules.StatusEffectsModule)
local Validator = require(SS.Modules.Movement.MovementValidator)
local DodgeModule = require(RSModules.Movement.Mechnanics.Dodge)
local SpeedMods = require(RSModules.Movement.Ultils.Speed)

local Events = RS.Events
local MovementEvent: RemoteEvent = Events.Movement
local VFX_Event: RemoteEvent = Events.VFX

local WeaponAnims = RS.Animations.Weapons

local ActiveDodges = {}
local ClimbTimers = {}

local function CleanupForPlayer(plr)
	ActiveDodges[plr] = nil
end

MovementEvent.OnServerEvent:Connect(function(plr, action, ...)
	local char = plr.Character
	if not char then
		return
	end

	--// Validation gate: provable spoofs get logged (debug: no kick), anything else is dropped.
	local ok, reason = Validator.Validate(plr, action, ...)
	if not ok then
		if Validator.ShouldKick(reason) then
			warn(string.format("[ANTI-CHEAT] %s illegal movement action: %s", plr.Name, tostring(action)))
		end
		return
	end

	local Humanoid = char:FindFirstChildOfClass("Humanoid")
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local HRP: Part = char.HumanoidRootPart
	local Torso = char.Torso
	local MovementObj = Movement.GetMovementObj(plr)

	if action == "SprintStart" then
		char:SetAttribute("Sprinting", true)
		if MovementObj then
			MovementObj.IsActing.IsSprinting = true
		end
	end

	if action == "SprintEnd" then
		char:SetAttribute("Sprinting", false)
		char:SetAttribute("IsEXSprinting", false)
		if MovementObj then
			MovementObj.IsActing.IsSprinting = false
			MovementObj.IsActing.IsEXSprinting = false
		end
	end

	if action == "WallRunStart" then
		if MovementObj then
			MovementObj.IsActing.WallRunning = true
		end
		Validator.ResetJumps(plr)
	end

	if action == "WallRunEnd" then
		if MovementObj then
			MovementObj.IsActing.WallRunning = false
		end
	end

	if action == "LedgeHold" then
		if not Humanoid or not HRP then
			return
		end
		local ledgeArg, intoWallArg = ...
		local LedgeY: number
		local HorizontalLedgeFoward: Vector3

		if typeof(ledgeArg) == "Vector3" and typeof(intoWallArg) == "Vector3" then
			LedgeY = ledgeArg.Y
			HorizontalLedgeFoward = Vector3.new(intoWallArg.X, 0, intoWallArg.Z).Unit
		else
			local ledge = ledgeArg
			if not ledge then
				return
			end
			HorizontalLedgeFoward = Vector3.new((-ledge.CFrame.LookVector).X, 0, (-ledge.CFrame.LookVector).Z).Unit
			LedgeY = ledge.Position.Y
		end

		local LedgeHoldAnimation = Humanoid.Animator:loadAnimation(WeaponAnims[CurrentWeapon].Movement.LedgeGrab)

		HRP.Anchored = true
		Humanoid.AutoRotate = false
		local yOffset = -1.5
		local LedgeDistance = MovementData.Data.LedgeDistance

		local currentXZ = Vector3.new(HRP.Position.X, 0, HRP.Position.Z)
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
			bv.Velocity = HRP.CFrame.LookVector * SpeedMods.GetJumpSpeed(char, "VaultBoost")
				+ Vector3.new(0, SpeedMods.GetJumpSpeed(char, "VaultUp"), 0)
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.P = 1250
			bv.Parent = HRP
			Debris:AddItem(bv, MovementData.Data.VaultDuration)

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

	if action == "SlideStart" then
		if MovementObj then
			MovementObj.States.ISSliding = true
			Flowmanager.OnSlideStart(MovementObj)
		end
	end

	if action == "SlideEnd" then
		if MovementObj then
			MovementObj.States.ISSliding = false
			Flowmanager.OnSlideEnd(MovementObj, function() end)
		end
	end

	if action == "Dodge" then
		local Config = {
			DashDur = MovementData.Data.DodgeDuration,
			Buffer_distance = 10.0, -- Increased slightly to fully cushion network-to-physics latency
		}

		local retainedSpeed = ...
		if retainedSpeed and retainedSpeed > 0 then
			local MaxIncoming = MovementData.Data.MaxDodgeSpeed * 2
			local MaxRetained = MaxIncoming * MovementData.Data.DodgeMomentumRetention + 20
			if retainedSpeed > MaxRetained then
				warn(string.format("[ANTI-CHEAT] %s Speed Spoofing for Dodge Momentum (retained: %.1f)", plr.Name, retainedSpeed))
				return
			end
		end

		if char:GetAttribute("Dodging") == true then
			return
		end
		if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, false) then
			return
		end

		-- STAMINA VALIDATION
		if Helpful.ManageStamina(char, action) then
			warn(string.format("[ANTI-CHEAT] %s Stamina Spoofing for Dodge", plr.Name))
			return
		end

		-- AUTHORITATIVE AIR STATE (mirrored from the server Humanoid)
		local isAir = Validator.IsAirborne(plr)

		char:SetAttribute("Dodging", true)
		StatusEffects.RemoveStatusEffect(char, nil, "Burn")

		local element = char:GetAttribute("Element")
		if element == "Astral" and char:GetAttribute("Mode2") then
			VFX_Event:FireAllClients("AfterImage", char, nil, "AstralDodge")
		end

		-- Authoritative speed from the SAME shared formula the client uses, so the
		-- validation budget always matches what the client can actually reach
		-- (honors the Astral 2x dodge bonus and future AGL scaling automatically).
		local baseSpeed = DodgeModule.CalculateDodgeSpeed(MovementObj, isAir) or MovementData.Data.DodgeSpeed

		-- DOUBLE JUMP -> AIR DODGE BONUS (server mirror): keeps the validation budget honest
		if isAir and MovementObj.InfoTable.DoubleJump then
			local lastDoubleJump = MovementObj.InfoTable.DoubleJump.LastTime or 0
			if lastDoubleJump > 0 and os.clock() - lastDoubleJump < MovementData.Data.AirDodgeBonusWindow then
				baseSpeed = baseSpeed * MovementData.Data.AirDodgeBonusMultiplier
				MovementObj.InfoTable.DoubleJump.LastTime = 0
			end
		end

		-- Now safe to start the flow transition state window
		Flowmanager.OnDodgeStart(MovementObj)
		MovementObj.IsActing.Dodging = true

		local StartTime = workspace:GetServerTimeNow()
		local StartPosition = HRP.Position

		ActiveDodges[plr] = {
			StartTime = StartTime,
			StartPos = StartPosition,
			Speed = baseSpeed + (retainedSpeed or 0),
			WasAirborne = isAir,
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

				-- The measurement window can outlast the client-side dodge burst, so the
				-- budget must also cover the fastest speed the character can legitimately
				-- sustain: ExSprint fallback tier x AGL x the 1.5x flow clamp (Flow
				-- Config.MaxFlowBonus). This keeps the check AGL/flow-aware and prevents
				-- false kicks when entering a dodge mid-combo at high AGL.
				local flowSpeedBound = SpeedMods.GetMovementSpeed(char, "ExSprintFallbackSpeed", "Sprint") * 1.5
				local expectedSpeed = math.max(TrackedVictim.Speed, flowSpeedBound)

				local ExpectedDistance = expectedSpeed * timeWindow

				if TrackedVictim.WasAirborne then
					local gravityVectorMagnitude = (workspace.Gravity * Config.DashDur) * timeWindow
					ExpectedDistance = ExpectedDistance + gravityVectorMagnitude
				end

				local MaxDistance = ExpectedDistance + Config.Buffer_distance

				if Travel > MaxDistance then
					warn(
						string.format(
							"[ANTI-CHEAT] %s speed mismatch detected! Distance: %.2f | Allowed: %.2f (Airborne: %s) | Elapsed Time: %.3f",
							plr.Name,
							Travel,
							MaxDistance,
							tostring(TrackedVictim.WasAirborne),
							actualTimeElapsed
						)
					)
					warn(string.format("[ANTI-CHEAT] %s Dodge Speed Validation Failure (Travel: %.2f / Allowed: %.2f)", plr.Name, Travel, MaxDistance))
				end
				ActiveDodges[plr] = nil
			end
		end)
	end

	if action == "DodgeCancel" then
		if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, false) then
			warn(string.format("[ANTI-CHEAT] %s State Stacking done on dodge cancel", plr.Name))
			return
		end
		Helpful.RefundStamina(char, action)

		-- Synchronize server object state tracking properties
		MovementObj.IsActing.Dodging = false
		Flowmanager.OnDodgeEnd(MovementObj, function() end)

		VFX_Event:FireAllClients("Highlight", char, 0.5, Color3.fromRGB(173, 173, 173), Color3.fromRGB(255, 255, 255))
	end

	if action == "WallRunJump" then
		VFX_Event:FireAllClients("Highlight", char, 0.4, Color3.fromRGB(255, 240, 240), Color3.fromRGB(235, 235, 235))
		Flowmanager.OnMechanicJump(MovementObj, "WallRunJump")
	end

	if action == "DoubleJump" then
		-- STAMINA VALIDATION: the free pool (declarable via
		-- MovementObj.InfoTable.DoubleJump.FreeJumps) is free out of combat;
		-- jumps past it cost stamina. In combat the validator hard-caps at the
		-- pool AND every jump costs stamina.
		local info = MovementObj and MovementObj.InfoTable and MovementObj.InfoTable.DoubleJump
		local freeJumps = (info and info.FreeJumps) or MovementData.Data.DoubleJumps
		if char:GetAttribute("InCombat") or Validator.GetJumpsUsed(plr) >= freeJumps then
			if Helpful.ManageStamina(char, "DoubleJump") then
				warn(string.format("[ANTI-CHEAT] %s Stamina Spoofing for DoubleJump", plr.Name))
				return
			end
		end

		Flowmanager.OnMechanicJump(MovementObj, "DoubleJump")

		-- Server-side bonus window so the dodge anti-cheat budget matches reality.
		-- os.clock() matches the client's own LastTime timebase (see DoubleJump.lua).
		if MovementObj and MovementObj.InfoTable and MovementObj.InfoTable.DoubleJump then
			MovementObj.InfoTable.DoubleJump.LastTime = os.clock()
		end
	end

	if action == "Climb" then
		local info = MovementObj and MovementObj.InfoTable and MovementObj.InfoTable.Climb
		local freeClimbs = (info and info.FreeClimbs) or MovementData.Data.MaxClimbsPerSet
		if char:GetAttribute("InCombat") or Validator.GetClimbsUsed(plr) >= freeClimbs then
			if Helpful.ManageStamina(char, "Climb") then
				warn(string.format("[ANTI-CHEAT] %s Stamina Spoofing for Climb", plr.Name))
				return
			end
		end

		-- IsClimbing drives the combat gate (CombatServer.ServerEnemyCheck).
		-- Refreshed on every accepted push, cleared when the set dies.
		if ClimbTimers[plr] then
			task.cancel(ClimbTimers[plr])
		end
		char:SetAttribute("IsClimbing", true)
		ClimbTimers[plr] = task.delay(2, function()
			if char and char.Parent then
				char:SetAttribute("IsClimbing", false)
			end
			ClimbTimers[plr] = nil
		end)
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

	if action == "FlowUpdate" then
		local bonus = ...
		Helpful.SetFlowBonus(plr, bonus)
	end
end)

local function OnPlayerAdded(plr)
	Validator.Track(plr)

	plr.CharacterAdded:Connect(function()
		Validator.Untrack(plr)
		Validator.Track(plr)
	end)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, plr in Players:GetPlayers() do
	OnPlayerAdded(plr)
end

Players.PlayerRemoving:Connect(function(plr)
	Validator.Untrack(plr)
	CleanupForPlayer(plr)
end)
