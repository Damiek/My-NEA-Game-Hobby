local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events = RS.Events
local AccessoryEvent = Events.AccessoryEvent

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local Hum = char:WaitForChild("Humanoid")

local AnimationsFolder = script.Animations
local AnimationsTable = {}

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
        if IsLow  and InCombat then 
			targetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
			warn(char.Name, "Is Low and has changed walking to hurt")
        else 
			targetFolder = AnimationsFolder.Weapons[currentWeapon]
			warn(char.Name, "Has been set back to normal")
        end
            
    else
        if IsLow  and InCombat then 
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
    if not AnimationsTable.WalkForward then return end
    
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