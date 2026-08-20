local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local HelpfullModule = require(SSModules.Other.Helpful)
local SkillInfo = require(SSModules.Dictionaries.SkillInfo)
local IntentService = require(SSModules.Combat.IntentService)
local plrModule = require(SSModules.Objects.plr)


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

	local plrObj = plrModule.GetPLRFromPlayer(plr)
	if not plrObj or not plrObj.Element then return end

	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true, nil, true) then
		warn("CheckForAttributes blocked the move")
		return
	end

	local slot = SlotMap[action]
	if not slot then return end

	local mode = GetMode(char)
	local intentType = ResolveIntentType(plrObj.Element.Name, slot, mode)
	if intentType then
		IntentService.SetIntent(char, nil, intentType)
	end

	if action == "Z Move" then
		plrObj.Element:Z(char)
	elseif action == "X Move" then
		plrObj.Element:X(char)
	elseif action == "C Move" then
		plrObj.Element:C(char)
	elseif action == "R Move" then
		plrObj.Element:R(char)
	elseif action == "V Move" then
		plrObj.Element:V(char)
	end
end)
