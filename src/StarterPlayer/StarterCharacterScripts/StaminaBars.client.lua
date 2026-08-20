
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules
local RunService = game:GetService("RunService")

local MovementClass = require(RSModules.Movement.Objects.Movement)
local TS = game:GetService("TweenService")
local plr = game.Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local StatusBars = PlayerGui:WaitForChild("StatusBars")
local MomentumUI = PlayerGui:WaitForChild("Momentum") :: BillboardGui

local MomentumFrame = MomentumUI:FindFirstChild("Momentum")
local UI_Grad = MomentumFrame.Fill.Grad



local obj = MovementClass.GetMovementObj(plr)

while not obj do
    obj = MovementClass.GetMovementObj(plr)
    print(obj)
    task.wait(0.1)
end







local MDBar = StatusBars.Frame.MFBar.Mental_Fill

local UIFolder = RS.UI.StatusBar

local Events = RS.Events
local UI_Update_Event = Events.UI_Update


local CONFIG = {
    IconText = {
        [1] = "I",
        [2] = "II",
        [3] = "III",
        [4] = "IV",
        [5] = "V",
    },

    Offsets = {
        StatusBars = Vector3.new(-4.5, 0, 0),
        Momentum = Vector3.new(3.5, 0, 0),
    },

    Lag = {
        SettleRate = 8,       -- lerp rate at rest (higher = snaps back faster)
        TrailRate = 3,        -- lerp rate at full speed (lower = lags more)
        SpeedForMaxLag = 45,  -- horizontal studs/s that maxes the lag (ExSprint)
        MaxLagDistance = 8,   -- hard cap, studs behind the target offset
    },

}


UI_Update_Event.OnClientEvent:Connect(function(action,...)
    if action == "StatusEffectAdded" then
        local effectName, stacks = ...

        local icon = StatusBars.Frame.StatusEffectsFRame:FindFirstChild(effectName)

        if icon then
            icon.Stacks.Text = stacks
        else
            local newIcon = UIFolder:FindFirstChild(effectName)
            if newIcon then
                local clonedIconGroup = newIcon:Clone()
                clonedIconGroup.Parent = StatusBars.Frame.StatusEffectsFRame
                local IconFrame = clonedIconGroup[effectName]
                IconFrame.Stacks.Text = CONFIG.IconText[stacks] or tostring(stacks)
                IconFrame.Name = effectName
            else
                warn("No icon found in UIFolder for effect:", effectName)
            end
        end
        
       
    elseif action == "StatusEffectRemoved" then
        local effectName = ...
        local icon = StatusBars.Frame.StatusEffectsFRame:FindFirstChild(effectName)
        if icon then
            print("removing",icon)
            local TweenInfo = TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)
            local tween = TS:Create(icon, TweenInfo, {GroupTransparency = 1})
            tween:Play()

            tween.Completed:Connect(function()
                icon:Destroy()

            end)
        
          
        end
    end
end)


local char = plr.Character or plr.CharacterAdded:Wait()
local torso = char:WaitForChild("HumanoidRootPart")
print(char,torso,StatusBars)

char:GetAttributeChangedSignal("MF"):Connect(function()
  MDBar:TweenSize(
    UDim2.new(1,0,char:GetAttribute("MF")/char:GetAttribute("MaxMF"),0),
     "Out", 
     "Quint", 
     1, 
     true
    )
end)



obj:GetAttributeChangedSignal("Momentum"):Connect(function(newMomentum)
    UI_Grad.Offset = Vector2.new(0, 1 - (newMomentum / obj.Flow.MaxMomentum))
end)

    StatusBars.Adornee = torso
    StatusBars.Parent = torso
    MomentumUI.Adornee = torso
    MomentumUI.Parent = torso

    local GUIS = {
        { gui = StatusBars, offset = CONFIG.Offsets.StatusBars },
        { gui = MomentumUI, offset = CONFIG.Offsets.Momentum },
    }

    local currentPos = {}
    for _, entry in GUIS do
        currentPos[entry.gui] = torso.Position + torso.CFrame:VectorToWorldSpace(entry.offset)
    end

    RunService.RenderStepped:Connect(function(dt)
        local velocity = torso.AssemblyLinearVelocity
        local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        local lagFactor = math.clamp(speed / CONFIG.Lag.SpeedForMaxLag, 0, 1)
        local rate = math.lerp(CONFIG.Lag.SettleRate, CONFIG.Lag.TrailRate, lagFactor)
        local alpha = 1 - math.exp(-rate * dt)

        for _, entry in GUIS do
            local target = torso.Position + torso.CFrame:VectorToWorldSpace(entry.offset)
            local pos = currentPos[entry.gui]:Lerp(target, alpha)

            local delta = pos - target
            if delta.Magnitude > CONFIG.Lag.MaxLagDistance then
                pos = target + delta.Unit * CONFIG.Lag.MaxLagDistance
            end

            currentPos[entry.gui] = pos
            entry.gui.StudsOffset = torso.CFrame:PointToObjectSpace(pos)
        end
    end)





