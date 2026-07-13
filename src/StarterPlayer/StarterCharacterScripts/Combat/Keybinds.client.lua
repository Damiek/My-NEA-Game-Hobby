
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local uis = game:GetService("UserInputService")


local Movement = require(RS.Modules.Movement.Objects.Movement)
local Dodge = require(RS.Modules.Movement.Mechnanics.Dodge)



local Events = RS.Events


local blockingEvent =  Events.Blocking
local Transform = Events.Tranform
local WeaponsEvent= Events.WeaponsEvent
local combatEvent:RemoteEvent = Events.Combat
local Moves_Event = Events.SkillEvent
local updateEvent = Events.UpdateMovement
local InventoryEvent = Events.InventoryEvent

local debounce = false 

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local moveentobj = Movement.GetMovementObj(plr)


local MOVE_KEYS = {
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.D] = "D"
}

local heldKeys = {} 
local lastSentKey = "None"


local function isActuallyTyping()
	return uis:GetFocusedTextBox() ~= nil
end

local function updateMovementAttribute()
	local currentKey = "None"
	
	if #heldKeys > 0 then
		currentKey = heldKeys[1]
	end

	if currentKey ~= lastSentKey then
		lastSentKey = currentKey
		updateEvent:FireServer(currentKey)
	end
end

local function getEquippedTool(char)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") then
			return child
		end
	end
	return nil
end





local hl = Instance.new("Highlight")
hl.FillTransparency = 1
hl.OutlineColor = Color3.new(1, 1, 1)
hl.OutlineTransparency = 0.5
hl.DepthMode = Enum.HighlightDepthMode.Occluded


local enemy = nil

local AirBorneStates = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
}




--------------------------------------------------------------------------------------
-- Misc Keybinds
--------------------------------------------------------------------------------------

uis.InputBegan:Connect(function(input,isTyping)
	if isTyping  then return end
	local Tool = getEquippedTool(char)

	if input.KeyCode == Enum.KeyCode.Backspace then
		print("YO, I want to drop a tool")
		if Tool then 
			print("Dropping Tool", Tool.Name)
			InventoryEvent:FireServer("Drop",Tool,1, "HotBar")
		end 
		
	end

end)

--------------------------------------------------------------------------------------
-- Movement  Tracking
--------------------------------------------------------------------------------------
uis.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end 
	
	local keyName = MOVE_KEYS[input.KeyCode]
	if keyName then
		
		for _, v in ipairs(heldKeys) do
			if v == keyName then return end
		end
		
		table.insert(heldKeys, keyName)
		updateMovementAttribute()
	end
end)

-- Detect Key Releases
uis.InputEnded:Connect(function(input)
	local keyName = MOVE_KEYS[input.KeyCode]
	if keyName then
		-- Remove the key from the table
		for i, v in ipairs(heldKeys) do
			if v == keyName then
				table.remove(heldKeys, i)
				break
			end
		end
		updateMovementAttribute()
	end
end)


--------------------------------------------------------------------------------------
-- Defence Mechanics
--------------------------------------------------------------------------------------
local function startBlocking()

	debounce = true
	blockingEvent:FireServer("Blocking")
	task.wait(1)
	debounce =false
	
end


local function stopBlocking()
	blockingEvent:FireServer("UnBlocking")
end





uis.InputBegan:Connect(function(input)
    if isActuallyTyping() then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if char:GetAttribute("Dodging") then
            Dodge.DodgeCancel(moveentobj)
        elseif char:GetAttribute("Swing") then
			combatEvent:FireServer("Feint")      
        end
    end
end)



uis.InputBegan:Connect(function(input, gp)
    if gp or isActuallyTyping() then return end

    if input.KeyCode == Enum.KeyCode.Q then
		if not moveentobj then 
			moveentobj = Movement.GetMovementObj(plr)
		end
		Dodge.Dodge(moveentobj)
    end
end)



uis.InputBegan:Connect(function(key, istyping)
	if istyping or debounce then
		return
	end
	if char:GetAttribute("IsTransforming") then
		return
	end
	
	if key.KeyCode == Enum.KeyCode.F then
		blockingEvent:FireServer("Parry")
		startBlocking()
	end
end)

uis.InputEnded:Connect(function(key,IsTyping)
	if IsTyping then return end
	if char:GetAttribute("IsTransforming") then return end
	if key.KeyCode == Enum.KeyCode.F then
		stopBlocking()
	end
	
end)


char:GetAttributeChangedSignal("Blocking"):Connect(function()
	if char:GetAttribute("Blocking") > 100 then
		stopBlocking()
	end
end)

---------------------------------------------------------------------------------------
-- Transform Mechanics
---------------------------------------------------------------------------------------


uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.G and not char:GetAttribute("Mode1") then
		if char:GetAttribute("Mode1",true) or char:GetAttribute("Mode2",true)  then return end
		Transform:FireServer("Mode 1")


	end
	
	if input.keyCode == Enum.KeyCode.G and char:GetAttribute("Mode1",true)  then
		if char:GetAttribute("Mode2",true) then return end
		Transform:FireServer("Mode 2")
	end
	
	

end)
-----------------------------------------------------------------------------------------
--- Attack Mechanics (Swinging, Blink and Skills)
-----------------------------------------------------------------------------------------
--- Swinging and Blink

local function MouseCast()
	local mousePos = uis:GetMouseLocation()
	local ray = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(ray.Origin, ray.Direction * 100, raycastParams)

	if not result then
		return nil
	end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChildOfClass("Humanoid") then
		return model
	end

	return nil
end


local function EnemyCheck(character)
	if not character then
		return false
	end

	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return false
	end

	local enemyPlayer = Players:GetPlayerFromCharacter(character)

	-- Player
	if enemyPlayer then
		if enemyPlayer == plr then
			return false
		end

		local movementObj = Movement.GetMovementObj(enemyPlayer)
		if not movementObj then
			return false
		end

		if movementObj.IsActing.Climbing then
			return true
		end

		if movementObj.IsActing.WallRunning then
			return true
		end

		if movementObj.IsActing.Dodging
			and movementObj.InfoTable.Dodge.Type == "Airdodge" then
			return true
		end

	

		return false
	end

	-- NPC
	if character:GetAttribute("IsWallRunning") then
		return true
	end

	if character:GetAttribute("IsClimbing") then
		return true
	end

	if character:GetAttribute("Dodging")
		and character:GetAttribute("DodgeType") == "Airdodge" then
		return true
	end


	return false
end


RunService.RenderStepped:Connect(function()
	if char:GetAttribute("IsTransforming") then
		return
	end

	local target = MouseCast()
	local newEnemy = nil

	if target and EnemyCheck(target) then
		newEnemy = target
	end

	-- Only update the highlight when the target changes.
	if newEnemy ~= enemy then
		enemy = newEnemy

		if enemy then
			hl.Parent = enemy
			hl.Adornee = enemy
		else
			hl.Parent = RS
			hl.Adornee = nil
		end
	end
end)
	

uis.InputBegan:Connect(function(input, gameProcessed)
	if isActuallyTyping() then return end
	if char:GetAttribute("IsTransforming") then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		print(moveentobj)
		if moveentobj == nil then moveentobj = Movement.GetMovementObj(plr) end
		print(plr)
		
		 
			if EnemyCheck(enemy) and AirBorneStates[char.Humanoid:GetState()] then
				print("passed 2")
				combatEvent:FireServer("Blink", enemy)
			elseif moveentobj.States.IsCrouching then
				print("Once i make the backstab logic this is where it woiuld be")

			else
				print("STandardswong1")
				combatEvent:FireServer("Swing")
			end
		
	end
end)


-- R Z X C V  Skills (Theese can be changed to any keys you want later on)
---Comments indicate which move each key corresponds to so I dont get confused when add key rebind options later on

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.R then
		Moves_Event:FireServer("R Move") --- This is the moveset's Special Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.Z then
		Moves_Event:FireServer("Z Move") -- This is the moveset's First Move
	end

end)


uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.X then
		Moves_Event:FireServer("X Move") -- This is the moveset's Second Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.C then
		Moves_Event:FireServer("C Move")-- This is the moveset's Third Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.V then
		Moves_Event:FireServer("V Move") --This is the moveset's ultimate Move
	end

end)


------------------------------------------------------------------------------------------
-- Weapon Equip/Unequip and Revert Transformations
------------------------------------------------------------------------------------------

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 
	
	if input.keyCode == Enum.KeyCode.E then
		if char:GetAttribute("Mode2") then return end

		if char:GetAttribute("Mode1") or char:GetAttribute("Mode2") then 
			Transform:FireServer("Revert")
		else
           WeaponsEvent:FireServer("Equip/UnEquip")
		   print("hell")
		end
		
		
	end
end)





