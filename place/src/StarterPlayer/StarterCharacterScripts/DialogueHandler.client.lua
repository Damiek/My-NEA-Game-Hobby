
local PromptTypeWaitTime = 0.02 -- Set to 0 to remove type writer effect
local PromptWaitTime = 1

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.Character:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")

local UI = script.Parent
local PromptFrame = UI:FindFirstChild("PromptFrame",true)

local DialogueRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DialogueRemote",true)
local DialogueBindable = game:GetService("ReplicatedStorage"):FindFirstChild("DialogueBindable",true)

local CurrentParams = nil
local SkipTyping = false
local CanSkip = false

function GetRootNode(Tree)
	for _,Node in pairs(Tree:GetChildren()) do
		if Node:GetAttribute("Type") == "DialogueRoot" then
			return Node
		end
	end
end

function GetNodeFromValue(Value)
	return Value:FindFirstAncestorWhichIsA("Configuration")
end

function GetOutputNodes(InputNode)
	local Nodes = {}
	
	for _,Output in pairs(InputNode:GetDescendants()) do
		if Output.Parent.Name == "Outputs" and Output.Value ~= nil then
			local Node = GetNodeFromValue(Output.Value)
			if not table.find(Nodes,Node) then
				table.insert(Nodes,Node)
			end
		end
	end
	
	return Nodes
end

function GetInputNodes(InputNode)
	local Nodes = {}

	for _,Input in pairs(InputNode:GetDescendants()) do
		if Input.Parent.Name == "Inputs" and Input.Value ~= nil then
			local Node = GetNodeFromValue(Input.Value)
			if not table.find(Nodes,Node) then
				table.insert(Nodes,Node)
			end
		end
	end

	return Nodes
end

function GetInputs(Node)
	local Inputs = {}

	for _,Input in pairs(Node:GetDescendants()) do
		if Input.Parent.Name == "Inputs" and Input.Value ~= nil then
			table.insert(Inputs,Input)
		end
	end

	return Inputs
end

function GetHighestPriorityNode(Nodes)
	local HighestPriority = 0
	local ChosenNode = nil
	
	for _,Node in pairs(Nodes) do
		if Node:GetAttribute("Priority") > HighestPriority then
			HighestPriority = Node:GetAttribute("Priority")
			ChosenNode = Node
		end
	end
	
	return ChosenNode
end

function FindNodeWithPriority(Nodes,Priority)
	for _,Node in pairs(Nodes) do
		if Node:GetAttribute("Priority") == Priority then
			return Node
		end
	end
end

function GetLowestPriorityNode(Nodes)
	local LowestPriority = math.huge
	local ChosenNode = nil

	for _,Node in pairs(Nodes) do
		if Node:GetAttribute("Priority") < LowestPriority then
			LowestPriority = Node:GetAttribute("Priority")
			ChosenNode = Node
		end
	end

	return ChosenNode
end

function ClearResponses()
	for _,Response in pairs(UI:FindFirstChild("ResponseFrame",true):GetChildren()) do
		if Response:IsA("TextButton") and Response.Visible then
			Response:Destroy()
		end
	end
end

function FindNodeType(Nodes,Type)
	for _,Node in pairs(Nodes) do
		if Node:GetAttribute("Type") == Type then
			return Node
		end
	end
end

function FindInput(Inputs,Name)
	for _,Input in pairs(Inputs) do
		if Input.Value.Name == Name then
			return Input.Value
		end
	end
end

function FireEvents(Node)
	for _,Event in pairs(Node:GetChildren()) do
		if Event:IsA("RemoteEvent") then
			Event:FireServer(Node)
		elseif Event:IsA("BindableEvent") then
			Event:Fire(Node)
		end
	end
end

function RunCommands(Node)
	for _,InputNode in pairs(GetInputNodes(Node)) do
		if InputNode:GetAttribute("Type") ~= "Condition" and InputNode:FindFirstChildWhichIsA("ModuleScript") then
			if #GetInputs(InputNode) <= 0 then
				local Function = require(InputNode:FindFirstChildWhichIsA("ModuleScript"))
				if Function.Run then
					Function.Run()
				end
			end
		end
	end
end

function CheckForCondition(Node)
	for _,InputNode in pairs(GetInputNodes(Node)) do
		if InputNode:GetAttribute("Type") == "Condition" and InputNode:FindFirstChildWhichIsA("ModuleScript") then
			if #GetInputs(InputNode) <= 0 then
				local Function = require(InputNode:FindFirstChildWhichIsA("ModuleScript"))
				if Function.Run then
					if Function.Run() ~= Node:GetAttribute("Priority") then
						return true
					end
				end
			end
		end
	end
end

function ToggleLock(Node)
	for _,Input in pairs(GetInputs(Node)) do
		if Input.Value.Name == "Toggle" then
			Input.Value.Value = not Input.Value.Value
		end
	end
end

function IsLocked(Node)
	local LockNode = FindNodeType(GetInputNodes(Node),"Lock")
	
	if LockNode and LockNode.Toggle.Value == true then
		local LockFound = false
		
		for _,Input in pairs(GetInputs(Node)) do
			if Input.Value.Name == "MainPathway" and Input.Value.Parent == LockNode then
				LockFound = true
			end
		end
		
		return LockFound
	else
		return false
	end
end

function RunInternalCommands(Node)
	if Node:FindFirstChildWhichIsA("ModuleScript") then
		local Function = require(Node:FindFirstChildWhichIsA("ModuleScript"))
		if Function.Run then
			Function.Run()
		else
			error("Module found inside a node does not have a .Run function!")
		end
	end
end

function CommonNodeFunctions(Node)
	RunCommands(Node)
	ToggleLock(Node)
	FireEvents(Node)
	RunInternalCommands(Node)
end

function LoadNode(Node)
	local Type = Node:GetAttribute("Type")
	
	if IsLocked(Node) or not UI.Enabled then
		return
	end
	
	if CheckForCondition(Node) then
		return
	end
	
	if Type == "Response" then
		
		local NewResponse = UI:FindFirstChild("SampleResponse",true):Clone()
		NewResponse.Parent = UI:FindFirstChild("ResponseFrame",true)
		NewResponse.Visible = true
		NewResponse.Text = Node.Text.Value
		NewResponse.Name = "Response"
		
		NewResponse.LayoutOrder = Node:GetAttribute("Priority")
		
		NewResponse.Size = UDim2.new(1,0,0,NewResponse.TextBounds.Y+5)
		
		NewResponse.Activated:Connect(function()
			CommonNodeFunctions(Node)
			LoadNodes(GetOutputNodes(Node))
		end)
		
	elseif Type == "Prompt" then
		
		CommonNodeFunctions(Node)
		
		UI:FindFirstChild("Speaker",true).Text = CurrentParams.Speaker or "?"
		
		PromptFrame.Text = Node.Text.Value
		
		PromptFrame.MaxVisibleGraphemes = 0
		
		SkipTyping = false
		
		CanSkip = Node.Skippable.Value
		
		spawn(function()
			if PromptTypeWaitTime > 0 then
				PromptFrame.MaxVisibleGraphemes = 0
				for L = 1,#PromptFrame.Text do
					if (not UI.Enabled or SkipTyping) and CanSkip then
						break
					else
						PromptFrame.MaxVisibleGraphemes += 1
						task.wait(PromptTypeWaitTime)
					end
				end
			else
				PromptFrame.MaxVisibleGraphemes = -1
			end
			
			PromptFrame.MaxVisibleGraphemes = -1
			
			if not SkipTyping or not CanSkip then
				task.wait(PromptWaitTime)
			end
			
			SkipTyping = false
			LoadNodes(GetOutputNodes(Node))
		end)
	elseif Node:FindFirstChildWhichIsA("ModuleScript") then
		CommonNodeFunctions(Node)
		FireEvents(Node)
		LoadNodes(GetOutputNodes(Node))
	end
end

function Close()
	UI.Enabled = false
	CurrentParams = nil
end

function LoadNodes(Nodes)
	if #Nodes <= 0 then
		Close()
	else
		ClearResponses()
		for _,Node in pairs(Nodes) do
			LoadNode(Node)
		end
	end
end

function OnEvent(DialogueTree, Params)
	if UI.Enabled then
		return
	end
	
	local RootNode = GetRootNode(DialogueTree)
	UI.Enabled = true

	CurrentParams = Params or {}

	for _,Condition in pairs(DialogueTree:GetChildren()) do
		if Condition:GetAttribute("Type") == "Condition" then
			Condition:SetAttribute("ReturnedValue",nil)
		end
	end

	LoadNodes(GetOutputNodes(RootNode))
end

DialogueRemote.OnClientEvent:Connect(OnEvent)
DialogueBindable.Event:Connect(OnEvent)

PromptFrame.Activated:Connect(function()
	SkipTyping = true
end)

while wait(1) do
	if CurrentParams and CurrentParams.Range and CurrentParams.Position then
		local Dist = (Root.Position-CurrentParams.Position).Magnitude
		if Dist > CurrentParams.Range then
			Close()
		end
	end
end

local Folder = workspace:FindFirstChild("DialogueSystem",true) 

if game.ServerStorage:FindFirstChild("NodePresets",true) then 
	game.ServerStorage:FindFirstChild("NodePresets",true):Destroy() 
end 

Folder.DialogueEvents.Parent = game.ReplicatedStorage 
Folder.NodePresets.Parent = game.ServerStorage 
Folder.DialogueUI.Parent = game.StarterGui
Folder.TestDialogue.Parent = workspace

Folder:Destroy()