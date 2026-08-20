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

local plr = game:GetService("Players").LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")

local InteractionUI = PlayerGui:WaitForChild("Interaction")
local Group = InteractionUI:FindFirstChildOfClass("CanvasGroup")

local TargetNpc = nil
local Info = { Font = nil, Speaker = nil, Sound = nil, ViewportModel = nil , IsAPerson = nil}

local function getNpcAndAdornee(prompt: ProximityPrompt): (Instance?, Instance?)
	local parent = prompt.Parent
	if not parent then
		return nil, nil
	end

	if parent:IsA("BasePart") then
		local modelParent = parent.Parent
		if modelParent and modelParent:IsA("Model") and modelParent ~= workspace then
			return modelParent, parent
		end
		return parent, parent
	end

	if parent:IsA("Model") and parent ~= workspace then
		local adornee = parent:FindFirstChild("Torso")
			or parent:FindFirstChild("UpperTorso")
			or parent:FindFirstChild("HumanoidRootPart")
			or parent:FindFirstChildWhichIsA("BasePart")
			or parent
		return parent, adornee
	end

	return parent, parent
end

ProxService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Name ~= "Interact" then
		return
	end

	local npc, adorneePart = getNpcAndAdornee(prompt)
	if not npc or not adorneePart then
		return
	end

	TargetNpc = npc

	local highlight = npc:FindFirstChild("Highlight") or Instance.new("Highlight", npc)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.new(213, 231, 255)

	local UI: BillboardGui = Cache[npc]
	local isNewUI = false

	if not Cache[npc] then
		UI = UI_Template:Clone()
		Cache[npc] = UI
		isNewUI = true
	end

	if plr.Character then
		plr.Character:SetAttribute("CanInteract", true)
	end

	UI.Parent = npc
	UI.Adornee = adorneePart

	TS:Create(highlight, tweeninfo, { FillTransparency = 0.8, OutlineTransparency = 0.2 }):Play()
	TS:Create(Group, UI_TweenInfo, { GroupTransparency = 0 }):Play()

	local ok, data = pcall(function()
		return Inforequest:InvokeServer(npc)
	end)

	if not ok or not data then
		return
	end

	Info = data

	if isNewUI then
		local titleFrame = UI:FindFirstChild("Title", true)
		local Name_Frame = UI:FindFirstChild("Name", true)

		local function getAlignment(frame)
			local textObj = frame
				and (frame:FindFirstChildWhichIsA("TextLabel") or frame:FindFirstChildWhichIsA("TextBox"))
			if not textObj then
				return Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center
			end
			return Enum.HorizontalAlignment[textObj.TextXAlignment.Name],
				Enum.VerticalAlignment[textObj.TextYAlignment.Name]
		end

		if Name_Frame then
			local hAlign, vAlign = getAlignment(Name_Frame)
			TextModule.UI_inject(Name_Frame, npc.Name, nil, {
				letterDelay = 0,
				useScale = true,
				textScale = 3.3, -- was 3.3
				horizontalAlignment = hAlign,
				verticalAlignment = vAlign,
			})
		end

		if titleFrame and data.Title then
			local hAlign, vAlign = getAlignment(titleFrame)
			TextModule.UI_inject(titleFrame, data.Title, nil, {
				letterDelay = 0,
				useScale = true,
				textScale = 3.3,
				horizontalAlignment = hAlign,
				verticalAlignment = vAlign,
			})
		end
	end

	TS:Create(UI, UI_TweenInfo, { Size = UDim2.new(4.5, 0, 1.5, 0) }):Play()
end)

ProxService.PromptHidden:Connect(function(prompt)
	if prompt.Name ~= "Interact" then
		return
	end

	local npc = getNpcAndAdornee(prompt)
	if not npc then
		return
	end

	local ui = Cache[npc]
	local highlight = npc:FindFirstChild("Highlight")

	TargetNpc = nil
	Info = { Font = nil, Speaker = nil, Sound = nil, ViewportModel = nil , IsAPerson = nil}
	if plr.Character then
		plr.Character:SetAttribute("CanInteract", false)
	end

	if highlight then
		TS:Create(highlight, tweeninfo, { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	end

	TS:Create(Group, UI_TweenInfo, { GroupTransparency = 1 }):Play()

	if ui then
		local sizeTween = TS:Create(ui, UI_TweenInfo, { Size = UDim2.new(0, 0, 1, 0) })
		sizeTween:Play()
		sizeTween.Completed:Connect(function()
			ui.Parent = cachefolder
			ui.Adornee = nil
		end)
	end
end)

UIS.InputBegan:Connect(function(input, gp)
	if
		input.KeyCode == Enum.KeyCode.E
		and TargetNpc
		and plr.Character
		and plr.Character:GetAttribute("CanInteract")
	then
		if Info.IsAPerson then
			DialogueRemote:FireServer(TargetNpc)
		else
			local hook = script:FindFirstChild(TargetNpc.Name)
			if hook and hook:IsA("ModuleScript") then
				require(hook).OnInteract(TargetNpc, plr)
			end
		end
	end
end)
