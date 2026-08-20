local Wallrun = {}
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules

local Cast = require(RSModules.Cast)
local ClientTypes = require(RSModules.ClientTypes)
local FlowManager = require(RSModules.Movement.Ultils.Flow)
local Sprinting = require(RSModules.Movement.Mechnanics.Sprinting)
local MovementData = require(RSModules.Movement.Data)
local SpeedMods = require(RSModules.Movement.Ultils.Speed)

local WeaponAnimations = RS.Animations.Weapons

local WallrunCooldowns = {}

local AnimationCache = setmetatable({}, { __mode = "k" })

-- Helper function to fetch or cache animation tracks safely
local function GetCachedTrack(MovementObj, Hum, weapon, animType)
	if not AnimationCache[MovementObj] then
		AnimationCache[MovementObj] = {}
	end

	local cacheKey = weapon .. "_" .. animType
	if not AnimationCache[MovementObj][cacheKey] then
		local animAsset = WeaponAnimations[weapon].Movement[animType]
		AnimationCache[MovementObj][cacheKey] = Hum.Animator:LoadAnimation(animAsset)
	end

	return AnimationCache[MovementObj][cacheKey]
end

local function WallChecker(char)
	local HRP: BasePart = char.HumanoidRootPart
	if not HRP then
		return
	end

	local range = MovementData.Data.WallRunCheckRange
	local leniency = MovementData.Data.WallRunFacingLeniency
	local filter = { char, workspace.VFX }

	local lookVector  = HRP.CFrame.LookVector
	local rightVector = HRP.CFrame.RightVector

	local function CastDir(origin,direction)
		return Cast.Ray({
			Origin = origin,
			Direction = direction,
			Range = range,
			FilterList = filter
		})
	end

	local forwardClearance = CastDir(HRP.Position, lookVector)
	local forwardPush = forwardClearance and math.min(range * 0.5, forwardClearance.Distance * 0.5) or range * 0.5
	local forwardOrigin = HRP.Position + lookVector * forwardPush


	

	-- Perpendicular side rays: exact facing, highest priority.
	local LeftResult = CastDir(HRP.Position, -rightVector)
	local RightResult = CastDir(HRP.Position, rightVector)

	if LeftResult and math.abs(LeftResult.Normal.Y) < 0.2 then
		return LeftResult, -1
	elseif RightResult and math.abs(RightResult.Normal.Y) < 0.2 then
		return RightResult, 1
	end

	-- Gentle facing leniency: forward-leaning diagonal per side, so the player
	-- can stick slightly before being fully perpendicular to the wall.
	local LeftLean = CastDir(forwardOrigin, (-rightVector + lookVector * leniency).Unit)
	local RightLean = CastDir(forwardOrigin, (rightVector + lookVector * leniency).Unit)

	local facingMax = MovementData.Data.WallRunFacingMax

	if LeftLean and math.abs(LeftLean.Normal.Y) < 0.2 and math.abs(lookVector:Dot(LeftLean.Normal)) < facingMax then
		return LeftLean, -1
	elseif RightLean and math.abs(RightLean.Normal.Y) < 0.2 and math.abs(lookVector:Dot(RightLean.Normal)) < facingMax then
		return RightLean, 1
	end

	return nil
end

local function StartWallRun(MovementObj: ClientTypes.MovementObj, hit: RaycastResult, side)
	if not MovementObj or not MovementObj.char or not MovementObj.identifer then
		return
	end
	local char = MovementObj.char
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local Hum = char.Humanoid
	local HRP: Part = char.HumanoidRootPart
	local WallrunSpeed = SpeedMods.GetMovementSpeed(char, "WallRunSpeed", "WallRun")

	if not Hum or not HRP then
		return
	end

	if MovementObj.IsActing.WallRunning then
		return
	end

	if MovementObj.IsActing.IsSprinting then
		WallrunSpeed = SpeedMods.GetMovementSpeed(char, "WallRunSprintSpeed", "WallRun")
	elseif MovementObj.IsActing.IsEXSprinting then
		WallrunSpeed = SpeedMods.GetMovementSpeed(char, "WallRunExSprintSpeed", "WallRun")
	end

	local Sprintflag = MovementObj.IsActing.IsSprinting or MovementObj.IsActing.IsEXSprinting
	local finalespeed = FlowManager.OnWallRunStart(MovementObj, WallrunSpeed, Sprintflag)

	WallrunSpeed = finalespeed

	local conn

	local Normal = hit.Normal.Unit

	local R_anim = GetCachedTrack(MovementObj, Hum, CurrentWeapon, "WallrunR")
	local L_anim = GetCachedTrack(MovementObj, Hum, CurrentWeapon, "WallrunL")

	if AnimationCache[MovementObj] then
		local hopR = AnimationCache[MovementObj][CurrentWeapon .. "_WallhopR"]
		local hopL = AnimationCache[MovementObj][CurrentWeapon .. "_WallhopL"]

		if hopR and hopR.IsPlaying then
			hopR:Stop(0.15)
		end
		if hopL and hopL.IsPlaying then
			hopL:Stop(0.15)
		end
	end

	if math.abs(Normal.Y) > 0.2 then
		warn("[Wallrun Module] = Normal Y failed to be in range")
	end

	local WallDir = Normal:Cross(Vector3.new(0, 1, 0)).Unit

	if WallDir:Dot(HRP.CFrame.LookVector) < 0 then
		WallDir = -WallDir
	end

	local entryvel = HRP.AssemblyLinearVelocity
	MovementObj.InfoTable.Wallrun.Side = side

	local playerFlag = MovementObj.identifer
	if playerFlag:IsA("Player") then
		local infotable = {
			Action = "Wallrun",
		}

		MovementObj:BarTween(infotable)
	end

	char:SetAttribute("IsWallRunning", true) -- for server to tell clients
	MovementObj.IsActing.WallRunning = true -- for the client to know they are wallrunning

	if not RunService:IsServer() then
		MovementObj:ServerRequest("WallRunStart")
	end

	if MovementObj.InfoTable.DoubleJump then
		MovementObj.InfoTable.DoubleJump.Used = 0
	end

	local Att = HRP:FindFirstChild("WallRunAttachment")

	if not Att then
		Att = Instance.new("Attachment")
		Att.Name = "WallRunAttachment"
		Att.Parent = HRP
	end

	local vel = Instance.new("LinearVelocity")
	vel.Attachment0 = Att
	vel.RelativeTo = Enum.ActuatorRelativeTo.World
	vel.Parent = HRP
	vel.ForceLimitsEnabled = true
	vel.ForceLimitMode = Enum.ForceLimitMode.PerAxis

	local mass = HRP.AssemblyMass * 1500
	vel.MaxAxesForce = Vector3.new(mass, mass, mass)

	local algin = Instance.new("AlignOrientation")
	algin.Attachment0 = Att
	algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
	algin.Responsiveness = 50
	algin.Parent = HRP

	Hum.AutoRotate = false

	if side == 1 then
		R_anim:Play()
	elseif side == -1 then
		L_anim:Play()
	end

	local duration = MovementData.Data.WallRunDuration
	local elapsed = 0

	local function StopWallRun(reason)
		conn:Disconnect()

		if not MovementObj.IsActing.WallRunning then
			return
		end

		WallrunCooldowns[MovementObj] = tick()

		if reason ~= "Jump" then
			HRP.AssemblyLinearVelocity += Normal * MovementData.Data.WallRunEntryPush
		end

		vel.Enabled = false
		algin.Enabled = false

		vel:Destroy()
		algin:Destroy()
		Att:Destroy()

		Hum.AutoRotate = true
		MovementObj.IsActing.WallRunning = false
		char:SetAttribute("IsWallRunning", false)

		if not RunService:IsServer() then
			MovementObj:ServerRequest("WallRunEnd")
		end

		R_anim:Stop()
		L_anim:Stop()

		FlowManager.OnWallRunEnd(MovementObj, function()
			if MovementObj.IsActing.IsEXSprinting then
				MovementObj.IsActing.IsSprinting = false
				Sprinting.NormalToggle(MovementObj)

				MovementObj.IsActing.IsEXSprinting = false
				Sprinting.ExToggle(MovementObj)
			else
				MovementObj.IsActing.IsSprinting = false
				Sprinting.NormalToggle(MovementObj)
			end
		end)

		MovementObj:UpdateWalkTracks()
		MovementObj:BarTweenStop({
			Action = "Wallrun",
		})
	end

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt

		if elapsed >= duration then
			StopWallRun()
			return
		end

		if Hum.FloorMaterial ~= Enum.Material.Air then
			StopWallRun()
			return
		end

		local check = Cast.Ray({
			Origin = HRP.Position,
			Direction = -Normal,
			Range = MovementData.Data.WallRunContactRange,
			FilterList = { char, workspace.VFX },
		})

		if not check then
			local FPS = workspace:GetRealPhysicsFPS()
			local coyotetime = (1 / FPS) * 5
			local frozenNormal = Normal

			task.delay(coyotetime, function()
				if not MovementObj.IsActing.WallRunning then
					return
				end

				local checkv2 = Cast.Ray({
					Origin = HRP.Position,
					Direction = -frozenNormal,
					Range = MovementData.Data.WallRunContactRange,
					FilterList = { char },
				})

				if not checkv2 then
					StopWallRun()
				end
			end)
			return
		end

		-- FOLLOW WALL CURVATURE: re-derive the wall direction from the fresh hit
		local freshNormal = check.Normal.Unit
		if math.abs(freshNormal.Y) > 0.2 then
			StopWallRun()
			return
		end

		local freshWallDir = freshNormal:Cross(Vector3.new(0, 1, 0)).Unit
		if freshWallDir:Dot(HRP.CFrame.LookVector) < 0 then
			freshWallDir = -freshWallDir
		end

		-- Drop the run on corners sharper than the allowed curve
		local angleChange = math.deg(math.acos(math.clamp(WallDir:Dot(freshWallDir), -1, 1)))
		if angleChange > MovementData.Data.WallRunCurveMaxAngle then
			StopWallRun()
			return
		end

		local steerAlpha = 1 - math.exp(-MovementData.Data.WallRunCurveSteerRate * dt)
		WallDir = WallDir:Lerp(freshWallDir, steerAlpha).Unit
		Normal = Normal:Lerp(freshNormal, steerAlpha).Unit

		local gforce = Vector3.new(0, -workspace.Gravity * MovementData.Data.WallRunGravityScale, 0)

		vel.VectorVelocity = WallDir * WallrunSpeed + gforce * dt + entryvel * MovementData.Data.WallRunCarry
		algin.CFrame = CFrame.lookAt(HRP.Position, HRP.Position + WallDir, Vector3.new(0, 1, 0))
		MovementObj.InfoTable.Wallrun.Stop = StopWallRun
		MovementObj.InfoTable.Wallrun.Side = side
		MovementObj.InfoTable.Wallrun.Normal = Normal
	end)
end

function Wallrun.Start(MovementObj: ClientTypes.MovementObj)
	local char = MovementObj.char
	if not char then
		return
	end
	local hum = char.Humanoid
	if not hum then
		return
	end

	if hum.FloorMaterial ~= Enum.Material.Air then
		return
	end

	if
		MovementObj.IsActing.WallRunning
		or MovementObj.IsActing.Climbing
		or MovementObj.States.IsOnWall
		or MovementObj.States.IsCrouching
	then
		return
	end

	if WallrunCooldowns[MovementObj] and tick() - WallrunCooldowns[MovementObj] < MovementData.Data.WallRunCooldown then
		return
	end

	local hit, side = WallChecker(char)
	if not hit then
		return
	end

	MovementObj:ClearWalkAnims()

	StartWallRun(MovementObj, hit, side)
end

function Wallrun.Jump(MovementObj: ClientTypes.MovementObj)
	if not MovementObj or not MovementObj.IsActing.WallRunning then
		return
	end

	local char = MovementObj.char
	local Hum = char.Humanoid
	local HRP = char.HumanoidRootPart
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	if not HRP then
		return
	end

	MovementObj:ServerRequest("WallRunJump")
	MovementObj.InfoTable.Wallrun.Stop("Jump")

	FlowManager.OnMechanicJump(MovementObj, "WallRunJump")

	local R_animJump = GetCachedTrack(MovementObj, Hum, CurrentWeapon, "WallhopR")
	local L_animJump = GetCachedTrack(MovementObj, Hum, CurrentWeapon, "WallhopL")
	local side = MovementObj.InfoTable.Wallrun.Side
	local Normal = MovementObj.InfoTable.Wallrun.Normal

	if not side or not Normal then
		return
	end

	local D = MovementData.Data

	local WallDir = Normal:Cross(Vector3.new(0, 1, 0)).Unit
	if WallDir:Dot(HRP.CFrame.LookVector) < 0 then
		WallDir = -WallDir
	end

	local uppower = SpeedMods.GetJumpSpeed(char, "WallJumpUp")
	local forwardPower = SpeedMods.GetJumpSpeed(char, "WallJumpForward")

	-- Preserve horizontal velocity and layer the launch on top of it
	local flatVel = Vector3.new(HRP.AssemblyLinearVelocity.X, 0, HRP.AssemblyLinearVelocity.Z)

	-- Camera-only launch with a hint of wall direction so it never dives into the wall
	local launchDir = WallDir
	local cam = workspace.CurrentCamera
	if not RunService:IsServer() and cam then
		local camLook = cam.CFrame.LookVector
		local camFlat = Vector3.new(camLook.X, 0, camLook.Z)
		if camFlat.Magnitude > 0.1 then
			launchDir = camFlat.Unit:Lerp(WallDir, D.WallJumpWallDirBlend).Unit
		end
	end

	-- Input decides whether we hop to the next wall (pushing away from it) or
	-- just launch forward. S and D intentionally do nothing lateral.
	local inputDir = Vector3.new(Hum.MoveDirection.X, 0, Hum.MoveDirection.Z)
	local hop = Vector3.zero
	local forwardScale = 1
	if inputDir.Magnitude > 0.1 then
		inputDir = inputDir.Unit
		if inputDir:Dot(Normal) > 0.1 then
			hop = Normal * SpeedMods.GetJumpSpeed(char, "WallJumpHop")
			forwardScale = 0.8
		end
	end

	local boostFlat = flatVel + launchDir * (forwardPower * forwardScale) + hop
	local launchVect = boostFlat + Vector3.new(0, uppower, 0)

	if side == 1 then
		R_animJump:Play(0)
	elseif side == -1 then
		L_animJump:Play(0)
	end

	local attachment = HRP:FindFirstChild("RootAttachment") or Instance.new("Attachment", HRP)

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attachment
	lv.MaxForce = math.huge
	lv.VectorVelocity = launchVect
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = HRP

	local boostDuration = D.WallJumpBoostDuration

	task.delay(boostDuration, function()
		if lv and lv.Parent then
			lv:Destroy()
		end
	end)
end

return Wallrun
