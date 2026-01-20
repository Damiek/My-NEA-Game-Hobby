local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cam = game.Workspace.CurrentCamera

local Events = RS.Events
local AccessoryEvent = Events.AccessoryEvent

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local Hum = char:WaitForChild("Humanoid")

local AnimationsFolder = script.Animations
local AnimationsTable = {}

local LastKeyPressTime = 0
local SprintDebounce = false
local doubleTapThreshold = 0.3
local isSprinting = false
local debounce = false
local SprintAnim = nil
local SprintTrack = nil

-- 1. Function to clear old tracks and load new ones
local function UpdateWalkTracks()
	-- Stop and destroy current playing tracks in the table
	for _, track in pairs(AnimationsTable) do
		track:Stop(0.1)
		track:Destroy()
	end

	local isEquipped = char:GetAttribute("Equipped")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local IsLow = char:GetAttribute("IsLow")
	local InCombat = char:GetAttribute("InCombat")

	local targetFolder

	-- Determine which folder to pull animations from
	if isEquipped and currentWeapon and AnimationsFolder.Weapons:FindFirstChild(currentWeapon) then
		if IsLow and InCombat then
			targetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
			warn(char.Name, "Is Low and has changed walking to hurt")
		else
			targetFolder = AnimationsFolder.Weapons[currentWeapon]
			warn(char.Name, "Has been set back to normal")
		end
	else
		if IsLow and InCombat then
			targetFolder = AnimationsFolder.IsLow
			warn(char.Name, "Is Low and has changed walking to hurt no waepon")
		else
			targetFolder = AnimationsFolder
			warn(char.Name, "Has been set back to normal - No weapon")
		end
	end

	-- Load the new tracks
	AnimationsTable.WalkForward = Hum:LoadAnimation(targetFolder.WalkForward)
	AnimationsTable.WalkRight = Hum:LoadAnimation(targetFolder.WalkRight)
	AnimationsTable.WalkLeft = Hum:LoadAnimation(targetFolder.WalkLeft)

	-- Start them all with 0 weight (RenderStepped handles weights)
	for _, track in pairs(AnimationsTable) do
		track:Play(0.1, 0, 0)
	end
end

-- 2. Listen for both attribute changes
char:GetAttributeChangedSignal("CurrentWeapon"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("Equipped"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("IsLow"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("InCombat"):Connect(UpdateWalkTracks)
AccessoryEvent.OnClientEvent:Connect(function(action)
	if action == "RefreshAnimations" then
		UpdateWalkTracks()
	end
end)
-- Initial Load
UpdateWalkTracks()

-- 3. The Animation Engine (RenderStepped)
RunService.RenderStepped:Connect(function()
	if not AnimationsTable.WalkForward then
		return
	end

	local DirectionOfMovement = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)
	local walkSpeed = Hum.WalkSpeed

	-- Calculate Weights
	local Forward = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, -1, -0.001))
	local Backwards = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, 0.001, 1))
	local Right = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, 0.001, 1))
	local Left = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, -1, -0.001))

	local SpeedUnit = (DirectionOfMovement.Magnitude / walkSpeed)

	-- Apply Weights and Speeds
	if DirectionOfMovement.Z / walkSpeed < 0.1 then
		AnimationsTable.WalkForward:AdjustWeight(math.max(Forward, Backwards)) -- Handles forward/backward weight
		AnimationsTable.WalkRight:AdjustWeight(Right)
		AnimationsTable.WalkLeft:AdjustWeight(Left)

		-- Reverse speed if walking backwards
		local playbackSpeed = (DirectionOfMovement.Z > 0) and -SpeedUnit or SpeedUnit
		AnimationsTable.WalkForward:AdjustSpeed(playbackSpeed)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)
	else
		-- Strafe logic while moving backwards
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkRight:AdjustWeight(Left)
		AnimationsTable.WalkLeft:AdjustWeight(Right)

		AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit * -1)
	end
end)

local function canSprint()
	return not (
		char:GetAttribute("Stunned")
		or char:GetAttribute("IsRagdoll")
		or char:GetAttribute("IsBlocking")
		or char:GetAttribute("Attacking")
	)
end

local function ResetSpeedCheck()
	return not (
		char:GetAttribute("Stunned")
		and not char:GetAttribute("IsBlocking")
		and not char:GetAttribute("Attacking")
	)
end

local function selectSprintAnim()
    if SprintAnim then SprintAnim:Stop()end

    if char:GetAttribute("Equipped") == true then 
        if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
            SprintTrack = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].IsLow.Sprint
        else 
            SprintTrack = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].Sprint
        end

    elseif char:GetAttribute("InCombat") and char:GetAttribute("IsLow")then
        SprintTrack = AnimationsFolder.IsLow.Sprint
    else
        SprintTrack = AnimationsFolder.Sprint
    end

    if  char:GetAttribute("Sprinting") then
        SprintAnim = Hum.Animator:LoadAnimation(SprintTrack)
        SprintAnim:Play()
    end
end

local function toggleSprintState()
	if isSprinting and not debounce then
		debounce = true
		print("SPRINT")
		
		if ResetSpeedCheck() then
			Hum.WalkSpeed = 16
		end

		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()
		isSprinting = false

		if SprintAnim then
			SprintAnim:Stop()
		end

        UpdateWalkTracks()

		char:SetAttribute("Sprinting", false)
        task.wait(0.1)

		debounce = false
	elseif not isSprinting and not debounce then
		print("No sprint")

        char:SetAttribute("Sprinting", true)
        if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then 
            Hum.WalkSpeed = Hum.WalkSpeed * 1.25
        else
            Hum.WalkSpeed = Hum.WalkSpeed * 2
        end
       
        TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 80 }):Play()
		isSprinting = true
       
        selectSprintAnim()

		for _, track in pairs(AnimationsTable) do
			track:Stop(0.1)
			track:Destroy()
		end


	end
end

local function onKeyPress(Key, isTyping)
	if isTyping then
		return
	end
	if Key.KeyCode == Enum.KeyCode.W and canSprint() then
		local currentTime = tick()
		if currentTime - LastKeyPressTime <= doubleTapThreshold then
			toggleSprintState()
		end
		LastKeyPressTime = currentTime
	end
end

local function onKeyRelease(Key, isTyping)
	if isTyping then
		return
	end
	if Key.KeyCode == Enum.KeyCode.W and isSprinting then
		toggleSprintState()
	end
end

char:GetAtrributeChangedSignal("Equipped"):Connect(function()
 selectSprintAnim()   
end)


local function OnCharStateChanged()
    if not canSprint() or HRP.Anchored then 
        if isSprinting then toggleSprintState() end
    end
end


uis.InputBegan:Connect(onKeyPress)
uis.InputEnded:Connect(onKeyRelease)
char:GetAtrributeChangedSignal("Attacking"):Connect(OnCharStateChanged)
char:GetAtrributeChangedSignal("Stunned"):Connect(OnCharStateChanged)
char:GetAtrributeChangedSignal("IsBlocking"):Connect(OnCharStateChanged)

