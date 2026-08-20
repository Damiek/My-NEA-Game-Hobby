local Dodge = {}
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules
local ClientTypes = require(RSModules.ClientTypes)
local FlowManager = require(RSModules.Movement.Ultils.Flow)
local MovementData = require(RSModules.Movement.Data)
local SpeedMods = require(RSModules.Movement.Ultils.Speed)

local WeaponAnims = RS.Animations.Weapons

-- Camera read fresh at use-time: the CurrentCamera reference can swap (respawn,
-- cutscene, etc.), so capturing it at require-time is a footgun.
local function GetCamera()
	return workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end

local DodgeCoolDowns = {}
local CancelCoolDown = {}

local function SetIntent(char, intent)
	if not RunService:IsServer() then return end
	local SSModules = game:GetService("ServerStorage").Modules
	local IntentService = require(SSModules.Combat.IntentService)
	IntentService.SetIntent(char, nil, intent)
end



local function CalculateDodgeSpeed(MovementObj: ClientTypes.MovementObj, isAir: boolean): number?
    local char = MovementObj.char
    if not char then return nil end 
    local Element = char:GetAttribute("Element")
    -- AGL-scaled (softly) via SpeedMods, honoring the DodgeSpeedMultiplier attribute.
    local baseSpeed = SpeedMods.GetDodgeSpeed(char)
    local maxspeed = SpeedMods.GetMaxDodgeSpeed(char)
    if Element == "Astral" and char:GetAttribute("Mode2") then
        baseSpeed  = baseSpeed * 2
        maxspeed = maxspeed *2
    end
   
    if isAir then
        baseSpeed = baseSpeed * MovementData.Data.AirDodgeMultiplier -- you go little slower in the air 
    end

    return math.min(baseSpeed, maxspeed)
end

local function Get3DMovement(MovementObj: ClientTypes.MovementObj)
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
        local cam = GetCamera()
        if cam then
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
    end

    local cam = GetCamera()
    if cam then
        local flatCam = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        return flatCam
    end

    return Vector3.zero
end

function Dodge.Dodge(MovementObj: ClientTypes.MovementObj)
    if not MovementObj or not MovementObj.char or MovementObj.IsActing.Dodging then
        return
    end

    local char = MovementObj.char
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local isServer = RunService:IsServer()

    if DodgeCoolDowns[MovementObj] and os.clock() - DodgeCoolDowns[MovementObj] < MovementData.Data.DodgeCooldown then
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


    ---  Introduce Moementum from previous actions in direction of dodge 

    local retained = Vector3.zero
    local dashMag = dashdir.Magnitude

    if dashMag > 0 then
        local incomingFlat = Vector3.new(HRP.AssemblyLinearVelocity.X,0,HRP.AssemblyLinearVelocity.Z)
        local dashflat = dashdir/dashMag
        retained = dashflat * (math.max(0,incomingFlat:Dot(dashflat)) * MovementData.Data.DodgeMomentumRetention)
    end

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
        MovementObj:ServerRequest("Dodge", retained.Magnitude) 
    end

    local lv, algin
    if MovementObj.InfoTable.Dodge.Type ~= "SpotDodge" then
        local DodgeSpeed = CalculateDodgeSpeed(MovementObj, isAir)
        if not DodgeSpeed then return end

        -- DOUBLE JUMP -> AIR DODGE BONUS: fresh double jump makes the next air dodge faster
        if isAir and MovementObj.InfoTable.DoubleJump then
            local lastDoubleJump = MovementObj.InfoTable.DoubleJump.LastTime or 0
            if lastDoubleJump > 0 and os.clock() - lastDoubleJump < MovementData.Data.AirDodgeBonusWindow then
                DodgeSpeed = DodgeSpeed * MovementData.Data.AirDodgeBonusMultiplier
                MovementObj.InfoTable.DoubleJump.LastTime = 0 -- consume the bonus
            end
        end

        local att = HRP:FindFirstChild("DodgeAtt") or Instance.new("Attachment", HRP)
        att.Name = "DodgeAtt"

        lv = Instance.new("LinearVelocity")
        lv.Name = "DashForce"
        lv.Attachment0 = att
        lv.MaxForce = math.huge

        if isAir then
            -- TIGHTENED GRAVITY COMPENSATION: 
            -- Uses an optimized baseline curve to keep the player afloat without executing a vertical launch.
            local gravityCounter = Vector3.new(0, workspace.Gravity * (MovementData.Data.DodgeDuration * 0.75), 0)
            
            -- Flatten dashdir Y components to keep air dodges horizontal by default.
            local flatDashDir = Vector3.new(dashdir.X, 0, dashdir.Z).Unit

            -- CAMERA PITCH (up-only): looking up tilts the air dodge up to
            -- AirDodgeCamUpAngle degrees; horizontal/down keeps it flat.
            -- Server/NPC dodges have no camera and stay flat.
            local cam = GetCamera()
            local pitch = 0
            if cam and cam.CFrame then
                local upLook = math.max(0, cam.CFrame.LookVector.Y)
                pitch = math.rad(MovementData.Data.AirDodgeCamUpAngle) * math.clamp(upLook, 0, 1)
                if cam.CFrame.LookVector.Y < 0 then
                    print(string.format("[Dodge] Air dodge with camera pitched down (Y=%.2f) -- dive mechanic fuse", cam.CFrame.LookVector.Y))
                end
            end

            if not isServer then
                local lookY = cam and cam.CFrame and cam.CFrame.LookVector.Y or 0
                print(string.format("[Dodge] AIR DODGE | isAir=%s | cam=%s | LookY=%.2f | pitch=%.1fdeg",
                    tostring(isAir), tostring(cam ~= nil), lookY, math.deg(pitch)))
            end

            local launchDir = (flatDashDir + Vector3.new(0, math.tan(pitch), 0)).Unit
            lv.VectorVelocity = (launchDir * DodgeSpeed) + retained+gravityCounter 
        else
            lv.VectorVelocity = dashdir * DodgeSpeed + retained
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

    task.delay(MovementData.Data.DodgeDuration, function()
        Stop()
    end)
end

Dodge.CalculateDodgeSpeed = CalculateDodgeSpeed

function Dodge.DodgeCancel(MovementObj: ClientTypes.MovementObj)
    if not MovementObj or not MovementObj.IsActing.Dodging then return end
    local isServer = RunService:IsServer()
    local cooldownTime = isServer and os.clock() or tick()

    if CancelCoolDown[MovementObj] and (cooldownTime - CancelCoolDown[MovementObj] < MovementData.Data.DodgeCancelCooldown) then return end

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