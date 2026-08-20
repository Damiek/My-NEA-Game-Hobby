local RS = game:GetService("ReplicatedStorage")

local FlowManager = require(RS.Modules.Movement.Ultils.Flow)
local proxy = require(RS.Modules.Movement.Ultils.Proxy)
local Signal = require(RS.Modules.Packages.Signal) 
local MovementData = require(RS.Modules.Movement.Data)

local Events = RS.Events

local MovementEvent: RemoteEvent = Events.Movement

local Movement = {}
Movement.__index = Movement

local AnimationsFolder = script.Animations

-- Ui Stuff
local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)

local Utils = require(script.Utils)
local Type = require(RS.Modules.ClientTypes)

local objTable = {} -- This stores the movementobjs
local SpeedMods = require(RS.Modules.Movement.Ultils.Speed)

local function BaseWalkSpeed(MovementObj)
	local baseSpeed = MovementData.Data.WalkSpeed
	if MovementObj and MovementObj.char then
		baseSpeed = SpeedMods.GetMovementSpeed(MovementObj.char, "WalkSpeed", "Walk")
	end
	return baseSpeed
end

local function Ui_init(movementObJ: Type.MovementObj)
	local plr = movementObJ.identifer
	if plr == nil or not plr:IsA("Player") then
		return
	end
	local UItable = movementObJ.UI
	local PlayerGui = plr:WaitForChild("PlayerGui", 5)
	if not PlayerGui then
		return
	end

	local MovementUI = PlayerGui:WaitForChild("MovementUI", 5)
	if not MovementUI then
		return
	end

	movementObJ.UI.top = MovementUI:WaitForChild("Top")
	UItable.bottom = MovementUI:WaitForChild("Bottom")
	UItable.top_tilt = MovementUI:WaitForChild("Top_Tilt")
	UItable.bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt")

	UItable.top.Position = TOP_HIDDEN
	UItable.bottom.Position = BOTTOM_HIDDEN

	UItable.top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
	UItable.bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT

	UItable.top_tilt.Rotation = 0
	UItable.bottom_tilt.Rotation = 0
end

local function StartFlow(MovementObj)
	local rawFlow = {
		BaseSpeed = BaseWalkSpeed(MovementObj),
		CurrentSpeed = BaseWalkSpeed(MovementObj),
		TargetSpeed = BaseWalkSpeed(MovementObj),
		WasSprinting = false,
		SprintIntentTime = 0,
		LastMechanic = nil,
		StoredVelocity = Vector3.zero,
		LastAirVelocity = Vector3.zero,
		EntryVelocity = Vector3.zero,
		Momentum = 0,
		MaxMomentum = SpeedMods.GetMaxMomentum(MovementObj.char),
		FlowBonus = 1.0,
		ChainCount = 0,
		LastChainTime = 0,
		IsTransitioning = false,
		LerpConnection = nil,
	}

	MovementObj.Flow = proxy.WrapTable(MovementObj, rawFlow, "Flow")
	FlowManager.StartSpeedLerp(MovementObj)
end

--[Module Functions]--
function Movement.new(identifer): Type.MovementObj
	if objTable[identifer] then
		pcall(function()
			objTable[identifer]:ClearWalkAnims()
			objTable[identifer]:Destroy()
		end)
	end

	local self = (
		setmetatable({
			identifer = identifer,
			char = identifer.Character or (identifer:IsA("Player") and identifer.CharacterAdded:Wait()),
			IsReady = false,

			IsActing = {
				Dodging = false,
				WallRunning = false,
				Climbing = false,
				IsSprinting = false,
				IsEXSprinting = false,
			},
			States = {
				IsGrounded = false,
				IsInAir = false,
				IsOnWall = false,
				IsCrouching = false,
				ISSliding = false,
				IsResting = false,
			},

			InfoTable = {
				Wallrun = {
					Side = 0,
					Normal = Vector3.new(0, 0, 0),
					Stop = "",
				},

				DoubleJump = {
					Used = 0,
					LastTime = 0,
					-- Declarable free-jump pool: talents write this to grant
					-- extra free air jumps. Defaults to the Data.lua value.
					FreeJumps = MovementData.Data.DoubleJumps,
				},

				Dodge = {
					Dir = Vector3.zero,
					Type = "",
					Speed = 0,
					Stop = function() end,
				},

				Climb = {
					FreeClimbs = MovementData.Data.MaxClimbsPerSet,
					Used = 0,
					LastTime =0,
					Stop = function() end,
				},

				Sprint = {
					Stop = function() end,
					SprintAnim = nil,
				},

				EXSprint = {
					Stop = function() end,
				},

				WallHold = {
					Type = "",
					Stop = function() end,
				},

				Crouch = {
					Stop = function() end,
				},

				Slide = {
					Stop = function() end,
				},

				Resting = {
					Stop = function() end,
				}
			},

			WalkCycleAnims = {
				WalkForward = nil,
				WalkRight = nil,
				WalkLeft = nil,
				WalkBack = nil,
			},

			UI = {
				top = nil,
				bottom = nil,
				top_tilt = nil,
				bottom_tilt = nil,
			},

			Flow = {},
		}, Movement) :: any
	) :: Type.MovementObj

	objTable[identifer] = self

	self._attributeSignals = {}
	self._attributePaths = {}

	self.IsActing = proxy.WrapTable(self, self.IsActing, "IsActing")
	self.States = proxy.WrapTable(self, self.States, "States")
	self.InfoTable = proxy.WrapTable(self, self.InfoTable, "InfoTable")

	StartFlow(self)

	local plrflag = game:GetService("Players"):GetPlayerFromCharacter(self.char)

	if plrflag then
		Ui_init(self)
	end

	self.IsReady = true

	return self
end

function Movement:GetAttributeChangedSignal(attributeName)
    if not self._attributeSignals then
        warn("[Movement] _attributeSignals was nil on object for", self.identifer, "- lazily initializing. Check that this object went through Movement.new properly.")
        self._attributeSignals = {}
        self._attributePaths = {}
    end

    local signals = self._attributeSignals
    if not signals[attributeName] then
        signals[attributeName] = Signal.new()
    end
    return signals[attributeName]
end

function Movement.GetMovementObj(Identifer): Type.MovementObj?
	if objTable[Identifer] ~= nil then
		return objTable[Identifer]
	else
		warn("[MovementObjects]: Identifier or the movementObj was nil")
		return nil
	end
end

function Movement:BarTween(infoTable)
	local plrflag = self.identifer
	if plrflag:IsA("Player") then
		plrflag = nil
	end
	if plrflag then
		return
	end

	local action = infoTable.Action

	if action == "Wallrun" then
		local side = self.InfoTable.Wallrun.Side
		Utils.StartWallrunBars(side, self)
	end

	if action == "Dodge" then
		local Speed = self.InfoTable.Dodge.Speed
		Utils.StartDodgeCam(Speed, self)
	end
end

function Movement:BarTweenStop(infoTable)
	local plrflag = self.identifer
	if plrflag:IsA("Player") then
		plrflag = nil
	end
	if plrflag then
		return
	end
	local action = infoTable.Action

	if action == "Wallrun" then
		local side = self.InfoTable.Wallrun.Side
		Utils.StopWallrunBars(side, self, nil)
	end

	if action == "Dodge" then
		Utils.RestDodgeCam(self)
	end
end

function Movement:UpdateWalkTracks()
	local AnimationsTable = self.WalkCycleAnims

	for i, track in pairs(AnimationsTable) do
		if track ~= nil then
			track:Stop(0.1)
			track:Destroy()
		end
	end

	local char = self.char
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end

	local isEquipped = char:GetAttribute("Equipped")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local IsLow = char:GetAttribute("IsLow")
	local HasCombatTag = char:GetAttribute("InCombat")
	local TargetFolder

	if
		isEquipped
		and currentWeapon
		and not self.States.IsCrouching
		and AnimationsFolder.Weapons:FindFirstChild(currentWeapon)
	then
		if IsLow and HasCombatTag then
			TargetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
		else
			TargetFolder = AnimationsFolder.Weapons[currentWeapon]
		end
	else
		if IsLow and HasCombatTag then
			TargetFolder = AnimationsFolder.IsLow
		else
			TargetFolder = AnimationsFolder
		end
	end

	AnimationsTable.WalkForward = hum:LoadAnimation(TargetFolder.WalkForward)
	AnimationsTable.WalkRight = hum:LoadAnimation(TargetFolder.WalkRight)
	AnimationsTable.WalkLeft = hum:LoadAnimation(TargetFolder.WalkLeft)
	AnimationsTable.WalkBack = hum:LoadAnimation(TargetFolder.WalkBack)

	for i, track in pairs(AnimationsTable) do
		if track then
			track:Play(0.1, 0, 0)
		end
	end
end

function Movement:WalkCycle()
	local char = self.char
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local Hum = char:FindFirstChildOfClass("Humanoid")
	local AnimationsTable = self.WalkCycleAnims

	if not HRP or not Hum or not AnimationsTable.WalkForward then
		return
	end

	local DirectionOfMovement = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)
	local walkSpeed = Hum.WalkSpeed

	local Forward = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, -1, -0.001))
	local Backwards = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, 0.001, 1))
	local Right = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, 0.001, 1))
	local Left = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, -1, -0.001))
	local SpeedUnit = DirectionOfMovement.Magnitude / walkSpeed

	if DirectionOfMovement.Z / walkSpeed < 0.1 then
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkBack:AdjustWeight(Backwards)
		AnimationsTable.WalkRight:AdjustWeight(Right)
		AnimationsTable.WalkLeft:AdjustWeight(Left)

		local playbackSpeed = (DirectionOfMovement.Z > 0) and SpeedUnit or -SpeedUnit
		AnimationsTable.WalkForward:AdjustSpeed(playbackSpeed)
		AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)
	else
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkBack:AdjustWeight(Backwards)
		AnimationsTable.WalkRight:AdjustWeight(Left)
		AnimationsTable.WalkLeft:AdjustWeight(Right)

		AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit * -1)
	end
end



function Movement:ClearWalkAnims()
	local AnimationsTable = self.WalkCycleAnims

	for i, track in pairs(AnimationsTable) do
		if track ~= nil then
			track:Stop(0.1)
			track:Destroy()
			AnimationsTable[i] = nil
		end
	end
end

function Movement:ServerRequest(action,...)
	if action == "CrouchStart" then
		MovementEvent:FireServer(action)
	end
	if action == "CrouchEnd" then
		MovementEvent:FireServer(action)
	end
	if action == "SlideStart" then
		MovementEvent:FireServer(action)
	end
	if action == "SlideEnd" then
		MovementEvent:FireServer(action)
	end
	if action == "SprintStart" then
		MovementEvent:FireServer(action)
	end
	if action == "SprintEnd" then
		MovementEvent:FireServer(action)
	end
	if action == "Dodge" then
		MovementEvent:FireServer(action,...)
	end
	if action == "DodgeCancel" then
		MovementEvent:FireServer(action)
	end
	if action == "ExSprintStart" then
		MovementEvent:FireServer(action)
	end
	if action == "ExSprintEnd" then
		MovementEvent:FireServer(action)
	end
	if action == "WallRunStart" then
		MovementEvent:FireServer(action)
	end
	if action == "WallRunEnd" then
		MovementEvent:FireServer(action)
	end
	if action == "WallRunJump" then
		MovementEvent:FireServer(action)
	end
	if action == "DoubleJump" then
		MovementEvent:FireServer(action)
	end

	if action == "Climb" then
		MovementEvent:FireServer(action)
	end
end

function Movement:StateChecker(self: Type.MovementObj, action: string, Ignore: boolean): boolean
	if not action then
		warn("[" .. script.Name .. "] - You forgot to add the action for a StateChecker")
		return true
	end

	if action == "Dodge" then
		if self.IsActing.Climbing then
			return true
		end
		if self.IsActing.WallRunning then
			return true
		end
		if self.States.IsResting then
			return true
		end
		if not Ignore and self.IsActing.Dodging then
			return true
		end
	elseif action == "SprintStart" or action == "ExSprintStart" then
		if self.IsActing.Climbing then
			return true
		end
		if self.IsActing.WallRunning then
			return true
		end
		if self.States.IsCrouching then
			return true
		end
	elseif action == "WallRunStart" then
		if self.IsActing.WallRunning then
			return true
		end
		if self.IsActing.Climbing then
			return true
		end
		if self.States.IsOnWall then
			return true
		end
		if self.States.IsCrouching then
			return true
		end
		if not self.States.IsInAir then
			return true
		end
	elseif action == "WallRunJump" then
		if not self.IsActing.WallRunning then
			return true
		end
	elseif action == "DoubleJump" then
		if not self.States.IsInAir then
			return true
		end
		if self.IsActing.WallRunning then
			return true
		end
		if self.IsActing.Climbing then
			return true
		end
	elseif action == "Climb" then
		if self.IsActing.WallRunning then
			return true
		end
		if self.IsActing.Climbing then
			return true
		end
	elseif action == "CrouchStart" then
		if self.IsActing.Climbing then
			return true
		end
		if self.IsActing.Dodging then
			return true
		end
		if self.IsActing.WallRunning then
			return true
		end
		if self.States.IsCrouching then
			return true
		end
	elseif action == "Resting" then
		if self.States.IsResting then
			return true
		end
	end

	return false
end


function Movement:Destroy()
	FlowManager.Cleanup(self)

	self:ClearWalkAnims()

	for _, sig in pairs(self._attributeSignals) do
		pcall(function()
			sig:Destroy()
		end)
	end
	self._attributeSignals = {}
	self._attributePaths = {}

	for _, key in ipairs({"Wallrun", "Dodge", "Climb", "Sprint", "EXSprint", "WallHold", "Crouch", "Slide", "Resting"}) do
		local entry = self.InfoTable[key]
		if type(entry) == "table" and type(entry.Stop) == "function" then
			pcall(function()
				entry.Stop()
			end)
			entry.Stop = function() end
		end
	end

	objTable[self.identifer] = nil

	self.char = nil
	self.identifer = nil
	self.UI = nil
	self.Flow = nil
end

return Movement
