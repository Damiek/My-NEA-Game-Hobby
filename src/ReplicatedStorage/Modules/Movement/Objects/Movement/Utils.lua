local Ultils = {}
local TS = game:GetService("TweenService")
local cam: Camera = workspace.CurrentCamera

local TOP_TILT_NORMAL_LEFT = UDim2.new(-0.672, 0, -0.157, 0)
local BOTTOM_TILT_NORMAL_LEFT = UDim2.new(-1.325, 0, 0.646, 0)

local Left_TILT_ANGLE = 35
local Right_TILT_ANGLE = -35

local Tilt_TOP_HIDDEN_RIGHT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_RIGHT = UDim2.new(-1.325, 0, 2, 0)

local TOP_TILT_NORMAL_RIGHT = UDim2.new(-0.954, 0, -0.671, 0)
local BOTTOM_TILT_NORMAL_RIGHT = UDim2.new(-0.992, 0, 1.058, 0)

local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)

local tweenSlide = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local Type = require(script.Parent.Types)

local function GetFlowModifiers(MovementObj: Type.MovementObj)
    local flow = MovementObj.Flow
    if not flow then return 0, 1 end
    
    local momentumRatio = (flow.Momentum or 0) / (flow.MaxMomentum or 100)
    local speedRatio = (flow.CurrentSpeed or 16) / 16
    
    return momentumRatio, speedRatio
end

local function WallJumpBars(side, MovementObj: Type.MovementObj)
    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt
    local TOP = UDim2.new(-0.001, 0, -0.987, 0)
    local BOTTOM = UDim2.new(-0.034, 0, 0.95, 0)

    local _, speedRatio = GetFlowModifiers(MovementObj)
    local jumpFovTarget = math.clamp(100 * speedRatio, 80, 90)

    local FOVChange: Tween = TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = jumpFovTarget })
    FOVChange:Play()
    
    TS:Create(hum, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CameraOffset = Vector3.zero }):Play()
    
    local top: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP, Rotation = 0 })
    local bottom: Tween = TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM, Rotation = 0 })
    top:Play()
    bottom:Play()
    
    FOVChange.Completed:Connect(function()
        TS:Create(cam, TweenInfo.new(0.40, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
    end)

    top.Completed:Connect(function()
        local finalbarTween: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP_HIDDEN, Rotation = 0 })
        finalbarTween:Play()
        TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_HIDDEN, Rotation = 0 }):Play()
        finalbarTween.Completed:Connect(function()
            Top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
            Bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT
        end)
    end)    
end

function Ultils.StartWallrunBars(side: number, MovementObj: Type.MovementObj)
    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt

    local momentumRatio, speedRatio = GetFlowModifiers(MovementObj)
    local targetFov = math.clamp(75 + (20 * momentumRatio) * speedRatio, 70, 78)
    
    local offsetX = -side * (1.2 * speedRatio)
    local offsetY = -0.4 * momentumRatio
    local targetCameraOffset = Vector3.new(offsetX, offsetY, 0)

    TS:Create(cam, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = targetFov }):Play()
    
    local bobDownOffset = Vector3.new(offsetX, offsetY - (0.6 * speedRatio), 0)
    
    local hitBobTween = TS:Create(hum, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CameraOffset = bobDownOffset })
    local settleTween = TS:Create(hum, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CameraOffset = targetCameraOffset })
    
    hitBobTween:Play()
    hitBobTween.Completed:Connect(function()
        settleTween:Play()
    end)

    if side == 1 then
        TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
        TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
    elseif side == -1 then
        TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
        TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
    end    
end

function Ultils.StopWallrunBars(side: number, MovementObj: Type.MovementObj, action)
    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt

    if not action then action = "Stop" end

    if action == "Stop" then
        TS:Create(hum, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CameraOffset = Vector3.zero }):Play()
        TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()

        if side == 1 then
            TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_RIGHT, Rotation = 15 }):Play()
            TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_RIGHT, Rotation = 15 }):Play()
        elseif side == -1 then
            TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_LEFT, Rotation = -15 }):Play()
            TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_LEFT, Rotation = -15 }):Play()
        end

    elseif action == "Jump" then
        WallJumpBars(side, MovementObj)
    end
end

function Ultils.StartDodgeCam(Speed, MovementObj: Type.MovementObj)
    local hum = MovementObj and MovementObj.char and MovementObj.char:FindFirstChildOfClass("Humanoid")
    local dodgeDir = MovementObj and MovementObj.InfoTable.Dodge.Dir or Vector3.zero
    
    local FovBoost = math.clamp(70 + (Speed * 0.30), 75, 80)
    
    TS:Create(cam, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = FovBoost }):Play()
    
    if hum and dodgeDir ~= Vector3.zero then
        local char = MovementObj.char
        local HRP = char:FindFirstChild("HumanoidRootPart")
        if HRP then
            local localDir = HRP.CFrame:VectorToObjectSpace(dodgeDir)
            
            local lagAmount = 2.2
            local lagOffset = -localDir.Unit * lagAmount
            
            local bobAmountY = -0.5
            local targetOffset = Vector3.new(lagOffset.X, lagOffset.Y + bobAmountY, lagOffset.Z)
            
            TS:Create(hum, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CameraOffset = targetOffset }):Play()
        end
    end
end

function Ultils.RestDodgeCam(MovementObj: Type.MovementObj)
    local hum = MovementObj and MovementObj.char and MovementObj.char:FindFirstChildOfClass("Humanoid")
    
    TS:Create(cam, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
    
    if hum then
        TS:Create(hum, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CameraOffset = Vector3.zero }):Play()
    end
end
return Ultils