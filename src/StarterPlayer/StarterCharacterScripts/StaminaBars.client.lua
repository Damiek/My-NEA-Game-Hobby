
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules

local MovementClass = require(RSModules.Movement.Objects.Movement)
local types = require(RSModules.Movement.Objects.Movement.Types)
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



obj:GetAttributeChangedSignal("Momentum"):Connect(function(newMomentum, oldMomentum)
    UI_Grad.Offset = Vector2.new(0, 1 - (newMomentum / obj.Flow.MaxMomentum))
end)

    StatusBars.Adornee = torso
    StatusBars.Parent = torso
    StatusBars.StudsOffset = Vector3.new(-4.5, 0, 0) 


    MomentumUI.Adornee = torso
    MomentumUI.Parent = torso
    MomentumUI.StudsOffset = Vector3.new(4.5, 0, 0) 





