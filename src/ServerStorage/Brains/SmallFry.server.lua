task.wait(1.5)

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Events = RS.Events

local RSModules = RS.Modules
local SSModules = SS.Modules

local CombatEvent = Events.Combat
local WeaponsModels = RS.Models.Weapons
local WeaponsWeld = RS.Welds.Weapons
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons

local BehaviourTreeCreator = require(RS.BehaviorTreeCreator)
local NPC_Class = require(SSModules.Objects.npc)

local CombatHelperModule = require(SSModules.Combat.CombatHelper)
local HelpfullModule = require(SSModules.Other.Helpful)
local Mode_Module = require(SSModules.Combat.Mode_Module)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local AI_TREE = BehaviourTreeCreator:_createTree(RS.AI_Trees.NasicEnemy_Test)

-- NEW: AI system modules
local NPC_Info = require(SSModules.Dictionaries.NPC_Info)
local ThreatTable = require(SSModules.AI.ThreatTable)

local char = script.Parent
local HRP = char.HumanoidRootPart
local Humanoid = char.Humanoid

char:SetAttribute("Equipped", true)
char:SetAttribute("Combo", 1)
char:SetAttribute("Stunned", false)
char:SetAttribute("Swing", false)
char:SetAttribute("Attacking", false)
char:SetAttribute("Iframes", false)
char:SetAttribute("IsBlocking", false)
char:SetAttribute("Blocking", 0)
char:SetAttribute("Karma", 0)

char:SetAttribute("Mode1", false)
char:SetAttribute("Mode2", false)
char:SetAttribute("Parrying", false)

char:SetAttribute("Dodges", 0)
char:SetAttribute("Sprinting", false)
char:SetAttribute("IsCrouching", false)

local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local TransformAnims = Combat_Data.TransformAnims
local ParryAnims = Combat_Data.ParryAnims
local DodgeAnims = Combat_Data.DodgeAnims
local EquipDebounce = Combat_Data.EquipDebounce
local DodgeDebounce = Combat_Data.DodgeDebounce

local npc = NPC_Class.GetNpcFromCharacter(char)

local Object = {
	Name = char.Name,
	npc = npc,
	model = char,
	human = Humanoid,
	isPathRunning = false,
	Target = nil,
	LastPlayerActions = {},
}

-- NEW: pull AI params (AggroRange, AttackRange, ReactionTime, etc.) from
-- NPC_Info by looking up this NPC's Difficulty tier, and init its ThreatTable
local function InitAI(Object, npcName)
	local stats = NPC_Info.getStats(npcName)
	local aiParams = NPC_Info.getAIParams(stats.Difficulty)
	print("Looking up NPC:", char.Name, "stats:", NPC_Info.getStats(char.Name))

	Object.AggroRange = aiParams.AggroRange
	Object.AttackRange = aiParams.AttackRange
	Object.ReactionTime = aiParams.ReactionTime
	Object.LowHealthThreshold = aiParams.LowHealthThreshold
	Object.RetreatDuration = aiParams.RetreatDuration
	Object.BlockChance = aiParams.BlockChance
	Object.ParryChance = aiParams.ParryChance
	Object.DodgeChance = aiParams.DodgeChance
	Object.StaminaCost = aiParams.StaminaCost
	Object.ParryChance = aiParams.ParryChance
	Object.HyprParryChance = aiParams.HyprParryChance -- NEW
	Object.DodgeChance = aiParams.DodgeChance

	ThreatTable.Init(Object)
	npc.AIObject = Object
end

InitAI(Object, char.Name)

local function Update()
	if char and Humanoid.Health > 0 then
		task.wait()
		AI_TREE:Run(Object)
	end
end

RunService.Stepped:Connect(Update)
