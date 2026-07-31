--- TODO: Use an invoke to get the dialogue info not the tree
local RS = game:GetService("ReplicatedStorage")
local ProxService = game:GetService("ProximityPromptService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local RSModules = RS.Modules
local TextModule = require(RSModules.text)

local Inforequest: RemoteFunction = RS:FindFirstChild("InfoRequest", true)
local DialogueRemote: RemoteEvent = RS:FindFirstChild("DialogueRemote", true)

local tweeninfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false)
local UI_TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false)

local UI_Template: BillboardGui = RS.UI.InteractUI.DialogueUI

local cachefolder = Instance.new("Folder", script)
local Cache = {}

local plr  = game:GetService("Players").LocalPlayer
local PLayerGui = plr:FindFirstChildOfClass("PlayerGui")

local InteractionUI = PLayerGui:WaitForChild("Interaction")
local Group = InteractionUI:FindFirstChildOfClass("CanvasGroup")

local TargetNpc = nil

ProxService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Name ~= "Interact" then
		return
	end
	print(prompt)
	local npc = prompt.Parent.Parent
	local highlight =  npc:FindFirstChild("Highlight") or Instance.new("Highlight", npc) 
	

	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.fromRGB(255,255,255)
	highlight.OutlineColor = Color3.new(213,231,255)
	TargetNpc = npc
	local UI: BillboardGui = Cache[npc]

	if not Cache[npc] then
		UI = UI_Template:Clone()
		Cache[npc] = UI
	end
	plr.Character:SetAttribute("CanInteract", true)

	UI.Parent = npc
	UI.Adornee = npc.Torso

	TS:Create(highlight, tweeninfo, { FillTransparency = 0.8, OutlineTransparency = 0.2 }):Play()
	TS:Create(Group, UI_TweenInfo, {GroupTransparency = 0}):Play()

	local ok, data = pcall(function()
		return Inforequest:InvokeServer(npc)
	end)
	if not ok or not data then
		return
	end

	local titleFrame = UI:FindFirstChild("Title", true)
	local Name_Frame = UI:FindFirstChild("Name", true)

    print(Name_Frame)

	if Name_Frame then
		TextModule.UI_inject(Name_Frame, npc.Name, nil, { letterDelay = 0 })
	end

	if titleFrame and data.Title then
		TextModule.UI_inject(titleFrame, data.Title, nil, { letterDelay = 0 })
	end

	TS:Create(UI, UI_TweenInfo, { Size = UDim2.new(4.5, 0, 1.5, 0) }):Play()
end)

ProxService.PromptHidden:Connect(function(prompt)
	if prompt.Name ~= "Interact" then
		return
	end
	local npc = prompt.Parent.Parent
	local ui = Cache[npc]
	local highlight = npc:FindFirstChild("Highlight")
	if not highlight then
		return
	end

	TargetNpc = nil
	plr.Character:SetAttribute("CanInteract", false)
	TS:Create(highlight, tweeninfo, { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	local sizeTween = TS:Create(ui, UI_TweenInfo, { Size = UDim2.new(0, 0, 1, 0) })
	TS:Create(Group, UI_TweenInfo, {GroupTransparency = 1}):Play()
    sizeTween:Play()
    sizeTween.Completed:Connect(function()
        ui.Parent = cachefolder
        ui.Adornee = nil
    end)
end)

UIS.InputBegan:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.E and TargetNpc and plr.Character:GetAttribute("CanInteract") then
		DialogueRemote:FireServer(TargetNpc)
	end
end)


