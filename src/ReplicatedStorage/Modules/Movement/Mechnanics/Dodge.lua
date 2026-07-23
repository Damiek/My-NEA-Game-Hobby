local Dodge = {}
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)
local FlowManager = require(RSModules.Movement.Ultils.Flow)
local cam = workspace.CurrentCamera

local WeaponAnims = RS.Animations.Weapons

local CONFIG = {
    DEFAULT_DASH_SPEED = 75, 
    MAX_DASH_SPEED = 120,    
    DASH_DURATION = 0.25,     
}

local DodgeCoolDowns = {}
local CancelCoolDown = {}

local function SetIntent(char, intent)
	if not RunService:IsServer() then return end
	local SSModules = game:GetService("ServerStorage").Modules
	local IntentService = require(SSModules.Combat.IntentService)
	IntentService.SetIntent(char, nil, intent)
end



local function CalculateDodgeSpeed(MovementObj: MovementTypes.MovementObj, isAir: boolean): number?
    local char = MovementObj.char
    if not char then return nil end 
    local Element = char:GetAttribute("Element")
    local baseSpeed = CONFIG.DEFAULT_DASH_SPEED
    if Element == "Astral" and char:GetAttribute("Mode2") then
        baseSpeed  = baseSpeed * 1.5
    end
   

    ---- I need to make a formula for dodge speed later
    if isAir then
        baseSpeed = baseSpeed * 0.9 -- you go little slower in the air 
    end

    
    return math.min(baseSpeed, CONFIG.MAX_DASH_SPEED)
end

local function Get3DMovement(MovementObj: MovementTypes.MovementObj)
    local isServer = RunService:IsServer()
    if isServer then
        return Vector3.zero
    end

    local char = MovementObj.char
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return Vector3.zero
    end

    local MoveInput = hum.MoveDirection
    local HeldKey = char:GetAttribute("CurrentMoveKey") or "None"

    if MoveInput.Magnitude > 0 then
        return MoveInput.Unit
    end

    if HeldKey ~= "None" then
        local camCF = cam.CFrame
        local forward = camCF.LookVector
        local right = camCF.RightVector

        -- Flatten vectors to prevent camera tilt from altering launch angles
        forward = Vector3.new(forward.X, 0, forward.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit

        if HeldKey == "W" then return forward end
        if HeldKey == "S" then return -forward end
        if HeldKey == "A" then return -right end
        if HeldKey == "D" then return right end
    end

    local flatCam = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
    return flatCam
end

function Dodge.Dodge(MovementObj: MovementTypes.MovementObj)
    if not MovementObj or not MovementObj.char or MovementObj.IsActing.Dodging then
        return
    end

    local char = MovementObj.char
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local isServer = RunService:IsServer()

    if DodgeCoolDowns[MovementObj] and os.clock() - DodgeCoolDowns[MovementObj] < 0.55 then
        return
    end
    if not HRP or not hum then
        return
    end

    if not isServer then
        local ClientHelpful = require(RSModules.ClientHelpfull)
        if ClientHelpful.CheckForAttributes(char, true, true, true, true, false, true, true, false) then
            return
        end
        if ClientHelpful.CheckStamina(char, "Dodge") then
            return
        end
    end

    local dashdir = Get3DMovement(MovementObj)
    local isAir = MovementObj.States.IsInAir

    if dashdir == Vector3.zero and isAir then
        return
    end

    local HeldKey = char:GetAttribute("CurrentMoveKey")
    local CurrentWeapon = char:GetAttribute("CurrentWeapon") or "BareFists"
    local DodgeAnim = nil

    FlowManager.OnDodgeStart(MovementObj)
    MovementObj.IsActing.Dodging = true
    SetIntent(char, "Dodge")

    if isAir then
        if HeldKey == nil or HeldKey == "None" then HeldKey = "W" end
        DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging.InAir[HeldKey])
        MovementObj.InfoTable.Dodge.Type = "AirDodge"
    else
        if dashdir == Vector3.zero or HeldKey == "None" then
            HeldKey = "None"
            MovementObj.InfoTable.Dodge.Type = "SpotDodge"
        else
            if HeldKey == nil then HeldKey = "W" end
            MovementObj.InfoTable.Dodge.Type = "Normal"
        end
        DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging[HeldKey])
    end

    if DodgeAnim then DodgeAnim:Play() end
    MovementObj.InfoTable.Dodge.Dir = dashdir

    if not isServer then
        MovementObj:ServerRequest("Dodge")
    end

    local lv, algin
    if MovementObj.InfoTable.Dodge.Type ~= "SpotDodge" then
        local DodgeSpeed = CalculateDodgeSpeed(MovementObj, isAir)
        if not DodgeSpeed then return end 
        local att = HRP:FindFirstChild("DodgeAtt") or Instance.new("Attachment", HRP)
        att.Name = "DodgeAtt"

        lv = Instance.new("LinearVelocity")
        lv.Name = "DashForce"
        lv.Attachment0 = att
        lv.MaxForce = math.huge

        if isAir then
            -- TIGHTENED GRAVITY COMPENSATION: 
            -- Uses an optimized baseline curve to keep the player afloat without executing a vertical launch.
            local gravityCounter = Vector3.new(0, workspace.Gravity * (CONFIG.DASH_DURATION * 0.75), 0)
            
            -- Flatten dashdir Y components to keep air dodges linear rather than angled upwards
            local flatDashDir = Vector3.new(dashdir.X, 0, dashdir.Z).Unit
            lv.VectorVelocity = (flatDashDir * DodgeSpeed) + gravityCounter
        else
            lv.VectorVelocity = dashdir * DodgeSpeed
        end
        lv.Parent = HRP

        algin = Instance.new("AlignOrientation")
        algin.Name = "DashRotation"
        algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
        algin.Attachment0 = att
        algin.MaxTorque = math.huge
        algin.Responsiveness = 50
        algin.CFrame = CFrame.lookAlong(Vector3.zero, Vector3.new(dashdir.X, 0, dashdir.Z).Unit)
        algin.Parent = HRP
    end

    if not isServer then
        local infoTable = { Action = "Dodge" }
        MovementObj:BarTween(infoTable)
    end

    local function Stop()
        if not MovementObj.IsActing.Dodging then return end

        if DodgeAnim then DodgeAnim:Stop(); DodgeAnim:Destroy() end
        if lv then lv:Destroy() end
        if algin then algin:Destroy() end

        MovementObj.IsActing.Dodging = false
        MovementObj.InfoTable.Dodge.Type = "None"
        SetIntent(char, "None")

        FlowManager.OnDodgeEnd(MovementObj, function()
            if isServer then return end 
            local Sprinting = require(RSModules.Movement.Mechnanics.Sprinting)
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

        if not isServer then
            local infoTable = { Action = "Dodge" }
            MovementObj:BarTweenStop(infoTable)
        end
        DodgeCoolDowns[MovementObj] = os.clock()
    end

    MovementObj.InfoTable.Dodge.Stop = Stop

    task.delay(CONFIG.DASH_DURATION, function()
        Stop()
    end)
end

function Dodge.DodgeCancel(MovementObj: MovementTypes.MovementObj)
    if not MovementObj or not MovementObj.IsActing.Dodging then return end
    local isServer = RunService:IsServer()
    local cooldownTime = isServer and os.clock() or tick()

    if CancelCoolDown[MovementObj] and (cooldownTime - CancelCoolDown[MovementObj] < 0.5) then return end

    local char = MovementObj.char
    local hum = char:FindFirstChildOfClass("Humanoid")
    local currentWeapon = char:GetAttribute("CurrentWeapon")
    local DodgeCancelAnim = hum.Animator:LoadAnimation(WeaponAnims[currentWeapon].Dodging.DodgeCancel)

    if typeof(MovementObj.InfoTable.Dodge.Stop) == "function" then
        MovementObj.InfoTable.Dodge.Stop()
    end

    DodgeCancelAnim:Play()
    CancelCoolDown[MovementObj] = cooldownTime
    DodgeCoolDowns[MovementObj] = 0

    if not isServer then
        MovementObj:ServerRequest("DodgeCancel")
    end
end

return Dodge