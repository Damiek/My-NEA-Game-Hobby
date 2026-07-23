local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local ElementModule_Folder = SSModules.Element
local HelpfullModule = require(SSModules.Other.Helpful)
local SkillInfo = require(SSModules.Dictionaries.SkillInfo)
local IntentService = require(SSModules.Combat.IntentService)


local Events = RS.Events
local MoveEvent = Events.SkillEvent

local SlotMap = {
	["Z Move"] = "Z",
	["X Move"] = "X",
	["C Move"] = "C",
	["R Move"] = "R",
	["V Move"] = "V",
}

local function GetMode(char)
	if char:GetAttribute("Mode2") then
		return "Mode2"
	elseif char:GetAttribute("Mode1") then
		return "Mode1"
	end
	return nil
end

local function ResolveIntentType(element, slot, mode)
	local elementData = SkillInfo.Elements[element]
	if not elementData then return nil end

	local slotData = elementData[slot]
	if not slotData then return nil end

	if mode then
		local skillData = slotData[mode]
		if skillData and skillData.Type then
			if skillData.Type == "Heavy" then
				return "HeavySkill"
			elseif skillData.Type == "Light" then
				return "LightSkill"
			end
		end
	end

	return nil
end


MoveEvent.OnServerEvent:Connect(function(plr, action)

	local char = plr.Character
	if not char then return end


	local element = char:GetAttribute("Element")
	if not element then warn("No Element attribute for", plr.Name) return end




	local elementModule = ElementModule_Folder:FindFirstChild(element)
	if not elementModule then return end



	local module = require(elementModule)


	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true) then
		warn("CheckForAttributes blocked the move")
		return
	end

	local slot = SlotMap[action]
	if not slot then return end

	local mode = GetMode(char)
	local intentType = ResolveIntentType(element, slot, mode)
	if intentType then
		IntentService.SetIntent(char, nil, intentType)
	end

	if action == "Z Move" then
		module.Z(char)
	elseif action == "X Move" then
		module.X(char)
	elseif action == "C Move" then
		module.C(char)
	elseif action == "R Move" then
		module.R(char)
	elseif action == "V Move" then
		module.V(char)
	end
end)
