local FlowManager = {}

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules
local Types = require(RSModules.Movement.Objects.Movement.Types)

local Config = {
    SprintToWallRunBonus = 1.15,        
    WallRunToSprintCarry = 0.95,        
    SlideToJumpCarry = 1.0,             
    DashMomentumRetention = 0.85,       
    LandingMomentumRetention = 0.9,     

    SpeedLerpAlpha = 0.18,              
    GroundedLerpAlpha = 0.22,           
    AirborneLerpAlpha = 0.12,           

    IntentMemoryDuration = 0.35,        
    LandingGracePeriod = 0.2,           

    SprintRestoreDelay = 0.05,          

    FlowBonusDecay = 0.92,              
    MaxFlowBonus = 1.4,                 

    TransitionCushion = 0.1,            

    MomentumDecayRate = 4.5,            
    MaxMomentumBonus = 0.50,            
}

local ActiveFlows = setmetatable({}, { __mode = "k" })

local function IsPlayerActing(MovementObj: Types.MovementObj) : boolean
    local acting = MovementObj.IsActing
    local states = MovementObj.States
    
    return acting.Dodging 
        or acting.WallRunning 
        or acting.Climbing 
        or acting.IsSprinting 
        or acting.IsEXSprinting
        or states.ISSliding
end

local function VerifyFlowStructure(MovementObj: Types.MovementObj)
    if not ActiveFlows[MovementObj] then
        local flow = MovementObj.Flow
        flow.FlowBonus = 1.0
        flow.Momentum = 0
        flow.MaxMomentum = 100
        flow.CurrentSpeed = 16
        flow.TargetSpeed = 16
        flow.BaseSpeed = 16
        flow.ChainCount = 0
        flow.LastChainTime = 0
        flow.SprintIntentTime = 0
        flow.WasSprinting = false
        flow.IsTransitioning = false
        flow.LastMechanic = "None"
        flow.StoredVelocity = Vector3.zero
        flow.EntryVelocity = Vector3.zero
        flow.LerpConnection = nil

        ActiveFlows[MovementObj] = flow
    end
    return ActiveFlows[MovementObj]
end

function FlowManager.Cleanup(MovementObj: Types.MovementObj)
    if not MovementObj then return end
    local flow = ActiveFlows[MovementObj]
    if not flow then return end

    if flow.LerpConnection then
        flow.LerpConnection:Disconnect()
        flow.LerpConnection = nil
    end

    ActiveFlows[MovementObj] = nil
    MovementObj.Flow = nil
end

function FlowManager.StartSpeedLerp(MovementObj: Types.MovementObj)
    local flow = VerifyFlowStructure(MovementObj)
    local char = MovementObj.char
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if flow.LerpConnection then
        flow.LerpConnection:Disconnect()
    end

    local debugTimer = 0

    flow.LerpConnection = RunService.Heartbeat:Connect(function(dt)
        if not hum or not hum.Parent then
            if flow.LerpConnection then flow.LerpConnection:Disconnect() end 
            return
        end

        local isGrounded = hum.FloorMaterial ~= Enum.Material.Air
        local lerpAlpha = isGrounded and Config.GroundedLerpAlpha or Config.AirborneLerpAlpha

        if flow.FlowBonus > 1.0 then
            flow.FlowBonus = math.max(1.0, flow.FlowBonus * (Config.FlowBonusDecay ^ dt))
        end

        -- MOMENTUM PROFILE HANDLING
        if MovementObj.IsActing.IsEXSprinting then
            flow.Momentum = math.min(flow.MaxMomentum, flow.Momentum + (15 * dt))
        elseif MovementObj.IsActing.IsSprinting then
            flow.Momentum = math.min(flow.MaxMomentum, flow.Momentum + (7.5 * dt))
        elseif not IsPlayerActing(MovementObj) and flow.Momentum > 0 then
            flow.Momentum = math.max(0, flow.Momentum - (Config.MomentumDecayRate * dt))
        end

        flow.CurrentSpeed = flow.CurrentSpeed + (flow.TargetSpeed - flow.CurrentSpeed) * lerpAlpha

        local momentumMultiplier = 1.0 + ((flow.Momentum / flow.MaxMomentum) * Config.MaxMomentumBonus)
        local finalSpeed = flow.CurrentSpeed * flow.FlowBonus * momentumMultiplier
        local clampedSpeed = math.clamp(finalSpeed, 0, flow.TargetSpeed * Config.MaxFlowBonus)

        -- GLOBAL MECHANIC DEBUG MONITOR (Throttled to every 100ms)
        local acting = MovementObj.IsActing
        local states = MovementObj.States
        local isAnyMechanicActive = acting.Dodging or acting.WallRunning or acting.Climbing or acting.IsSprinting or acting.IsEXSprinting or states.ISSliding

        if isAnyMechanicActive or flow.IsTransitioning then
            debugTimer += dt
            if debugTimer >= 0.1 then
                debugTimer = 0
                
                -- Determine active mechanic string for accurate reporting
                local currentActiveLabel = "Idle/None"
                if acting.IsEXSprinting then currentActiveLabel = "EXSprint"
                elseif acting.IsSprinting then currentActiveLabel = "Sprint"
                elseif acting.Dodging then currentActiveLabel = "Dodge"
                elseif acting.WallRunning then currentActiveLabel = "WallRun"
                elseif acting.Climbing then currentActiveLabel = "Climb"
                elseif states.ISSliding then currentActiveLabel = "Slide"
                end

                print(string.format(
                    "[FLOW DEBUG] ActiveMec: %s | LastMec: %s | TargetSpd: %.1f | CurSpd: %.1f | FlowBonus: %.2f | Momentum: %.1f | FinalSpd: %.1f | Clamped: %.1f | Locked: %s | Grounded: %s",
                    currentActiveLabel,
                    tostring(flow.LastMechanic),
                    flow.TargetSpeed,
                    flow.CurrentSpeed,
                    flow.FlowBonus,
                    flow.Momentum,
                    finalSpeed,
                    clampedSpeed,
                    tostring(flow.IsTransitioning),
                    tostring(isGrounded)
                ))
            end
        end

        -- SPEED ASSIGNMENT & OVERRIDE SAFETY GUARD
        if MovementObj.IsActing.Dodging or flow.LastMechanic == "Dodge" then
            hum.WalkSpeed = math.min(flow.BaseSpeed, 16) 
        elseif not flow.IsTransitioning then
            hum.WalkSpeed = clampedSpeed
        end
    end)
end


function FlowManager.MarkSprinting(MovementObj: Types.MovementObj, isSprinting: boolean)
    local flow = VerifyFlowStructure(MovementObj)
    flow.WasSprinting = isSprinting
    flow.SprintIntentTime = os.clock() 
end

function FlowManager.ShouldRestoreSprint(MovementObj: Types.MovementObj): boolean
    local flow = ActiveFlows[MovementObj]
    if not flow then return false end
    local timeSinceIntent = os.clock() - flow.SprintIntentTime
    return flow.WasSprinting and timeSinceIntent < Config.IntentMemoryDuration
end

function FlowManager.ClearIntent(MovementObj: Types.MovementObj)
    local flow = ActiveFlows[MovementObj]
    if not flow then return end

    flow.WasSprinting = false
    flow.SprintIntentTime = 0
end

function FlowManager.StoreVelocity(MovementObj: Types.MovementObj, velocityMultiplier: number?)
    local flow = VerifyFlowStructure(MovementObj)
    local hrp = MovementObj.char:FindFirstChild("HumanoidRootPart") :: BasePart
    if not hrp then return end

    local multiplier = velocityMultiplier or 1.0
    flow.StoredVelocity = hrp.AssemblyLinearVelocity * multiplier
    flow.EntryVelocity = hrp.AssemblyLinearVelocity
end

function FlowManager.GetStoredVelocity(MovementObj: Types.MovementObj): Vector3
    local flow = ActiveFlows[MovementObj]
    return flow and flow.StoredVelocity or Vector3.zero
end

function FlowManager.ApplyStoredMomentum(MovementObj: Types.MovementObj, additive: boolean?)
    local flow = ActiveFlows[MovementObj]
    local hrp = MovementObj.char:FindFirstChild("HumanoidRootPart") :: BasePart
    if not flow or not hrp then return end

    if additive then
        hrp.AssemblyLinearVelocity += flow.StoredVelocity
    else
        hrp.AssemblyLinearVelocity = flow.StoredVelocity
    end
end

function FlowManager.OnSprintStart(MovementObj: Types.MovementObj, sprintSpeed: number, isEXSprint: boolean)
    local flow = VerifyFlowStructure(MovementObj)

    FlowManager.MarkSprinting(MovementObj, true)

    flow.TargetSpeed = sprintSpeed
    flow.BaseSpeed = sprintSpeed
    
    if isEXSprint then
        flow.LastMechanic = "ExSprint"
    else
        flow.LastMechanic = "Sprint"
    end

    local hrp = MovementObj.char:FindFirstChild("HumanoidRootPart") :: BasePart
    if hrp then
        local currentVel = hrp.AssemblyLinearVelocity
        if currentVel.Magnitude > sprintSpeed then
            flow.CurrentSpeed = math.min(currentVel.Magnitude, sprintSpeed * 1.3)
        end
    end
end

function FlowManager.OnSprintStop(MovementObj: Types.MovementObj, walkSpeed: number)
    local flow = VerifyFlowStructure(MovementObj)

    local hrp = MovementObj.char:FindFirstChild("HumanoidRootPart") :: BasePart
    if hrp then
        flow.StoredVelocity = hrp.AssemblyLinearVelocity * Config.DashMomentumRetention
        flow.EntryVelocity = hrp.AssemblyLinearVelocity
    end

    flow.TargetSpeed = walkSpeed
    flow.BaseSpeed = walkSpeed
end

function FlowManager.OnWallRunStart(MovementObj: Types.MovementObj, wallrunSpeed: number, wasSprinting: boolean)
    local flow = VerifyFlowStructure(MovementObj)

    flow.LastMechanic = "WallRun"
    flow.IsTransitioning = true

    if os.clock() - flow.LastChainTime < 1.0 then 
        flow.ChainCount = math.min(7, flow.ChainCount + 1)
        flow.FlowBonus = math.min(Config.MaxFlowBonus, 1.0 + (flow.ChainCount * 0.05))
    else
        flow.ChainCount = 1
        flow.FlowBonus = 1.0
    end

    flow.LastChainTime = os.clock()
    flow.Momentum = math.min(flow.MaxMomentum, flow.Momentum + 10)

    local speedMult = wasSprinting and Config.SprintToWallRunBonus or 1.0
    return wallrunSpeed * speedMult
end

function FlowManager.OnWallRunEnd(MovementObj: Types.MovementObj, onSprintRestore: () -> ())
    local flow = ActiveFlows[MovementObj]
    local char = MovementObj.char
    if not flow or not char then return end 
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    flow.IsTransitioning = false
    FlowManager.StoreVelocity(MovementObj, Config.WallRunToSprintCarry)

    task.delay(Config.SprintRestoreDelay, function()
        if FlowManager.ShouldRestoreSprint(MovementObj) then
            if hum.MoveDirection.Magnitude > 0 then
                onSprintRestore()
            end
        end
    end)
end

function FlowManager.OnSlideStart(MovementObj: Types.MovementObj)
    local flow = VerifyFlowStructure(MovementObj)

    flow.LastMechanic = "Slide"
    flow.IsTransitioning = true
    flow.Momentum = math.min(flow.MaxMomentum, flow.Momentum + 15)

    FlowManager.StoreVelocity(MovementObj, 1.0)
end

function FlowManager.OnSlideEnd(MovementObj: Types.MovementObj, onSprintRestore: () -> ())
    local flow = ActiveFlows[MovementObj]
    local char = MovementObj.char
    if not flow or not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    flow.IsTransitioning = false

    task.delay(Config.SprintRestoreDelay, function()
        if FlowManager.ShouldRestoreSprint(MovementObj) then
            if hum.MoveDirection.Magnitude > 0 then
                onSprintRestore()
            end
        end
    end)
end

function FlowManager.OnDodgeStart(MovementObj: Types.MovementObj)
    local flow = VerifyFlowStructure(MovementObj)

    flow.LastMechanic = "Dodge"
    flow.IsTransitioning = true

    print("[FLOW INFO] Dodge Started. Velocity stored.")
    FlowManager.StoreVelocity(MovementObj)
end

function FlowManager.OnDodgeEnd(MovementObj: Types.MovementObj, OnSprintRestore: () -> ())
    local flow = ActiveFlows[MovementObj]
    local char = MovementObj.char
    if not flow or not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    flow.IsTransitioning = false
    print("[FLOW INFO] Dodge Ended. Transition lock released.")

    task.delay(Config.SprintRestoreDelay, function()
        if FlowManager.ShouldRestoreSprint(MovementObj) then
            if hum.MoveDirection.Magnitude > 0 then
                OnSprintRestore()
            end
        end
    end)
end

function FlowManager.OnLanding(MovementObj: Types.MovementObj, OnSprintRestore: () -> (), fallVelocity: number)
    local flow = VerifyFlowStructure(MovementObj)
    local char = MovementObj.char
    local HRP = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not HRP or not hum then return end

    local velMagnitude = HRP.AssemblyLinearVelocity.Magnitude
    if velMagnitude > flow.BaseSpeed then
        flow.StoredVelocity = HRP.AssemblyLinearVelocity * Config.LandingMomentumRetention
        flow.CurrentSpeed = math.min(velMagnitude * Config.LandingMomentumRetention, flow.BaseSpeed * 1.5)
    end

    task.delay(Config.LandingGracePeriod, function()
        if FlowManager.ShouldRestoreSprint(MovementObj) then
            if hum.MoveDirection.Magnitude > 0 then
                OnSprintRestore()
            end
        end
    end)
end

function FlowManager.OnMechanicJump(MovementObj: Types.MovementObj, mechanicName: string)
    local flow = VerifyFlowStructure(MovementObj)

    if os.clock() - flow.LastChainTime < 1.5 then
        flow.ChainCount = math.min(7, flow.ChainCount + 1)
        flow.FlowBonus = math.min(Config.MaxFlowBonus, 1.0 + (flow.ChainCount * 0.08))
    end 
    
    flow.LastChainTime = os.clock()
end

function FlowManager.GetFlowBonus(MovementObj: Types.MovementObj): number
    local flow = ActiveFlows[MovementObj]
    return flow and flow.FlowBonus or 1.0
end

function FlowManager.GetChainCount(MovementObj: Types.MovementObj): number
    local flow = ActiveFlows[MovementObj]
    return flow and flow.ChainCount or 0
end

function FlowManager.ResetChain(MovementObj: Types.MovementObj)
    local flow = ActiveFlows[MovementObj]
    if not flow then return end

    flow.ChainCount = 0
    flow.FlowBonus = 1.0
end

function FlowManager.SetTargetSpeed(MovementObj: Types.MovementObj, speed: number)
    local flow = VerifyFlowStructure(MovementObj)
    flow.TargetSpeed = speed
end

function FlowManager.SetLocked(MovementObj: Types.MovementObj, locked: boolean)
    local flow = VerifyFlowStructure(MovementObj)
    flow.IsTransitioning = locked
end

Players.PlayerRemoving:Connect(function(player)
    for obj, _ in pairs(ActiveFlows) do
        if obj.identifer == player or (obj.char and Players:GetPlayerFromCharacter(obj.char) == player) then
            FlowManager.Cleanup(obj)
        end
    end
end)

return FlowManager