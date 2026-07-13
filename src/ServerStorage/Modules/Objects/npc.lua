--[=[
	@class NPC

	Creates and manages NPC objects, analogous to the PlayerObject Roblox creates for players.
	Each NPC wraps a Character model with combat state, stats, and a behavior-tree Brain script,
	tracked via the internal CharToNPC and Combat_Data.ActiveNPCs lookup tables.
]=]
--[=[
	@interface NPCData
	.FirstName string -- The NPC's first name
	.LastName string -- The NPC's last name
	.Difficulty string -- e.g. "Boss", used to pick the model template and Brain script
	.MobType string -- e.g. "Humanoid", "Human"; affects model creation and element assignment
	.Character Model -- The NPC's physical character model in the workspace
	.Element string -- The NPC's combat element, or "None" for non-humanoid mobs without one
	.Brain Script -- The behavior-tree script driving this NPC, parented under Character
	.talents {} -- Reserved for future talent data
	.skills {} -- Reserved for future skill data
	.drops {} -- Loot table entries chosen on death (currently unused, see PickDrops)
	.MovementObj MovementTypes.MovementObj -- Handles this NPC's movement mechanics (dodge, climb, wall run)
	.Intent -- This is the buffer that holds what combat action is the actor waiting to do
	@within NPC
]=]

--[=[
	@interface NPCMethods
	.Destroy (self: NPC) -> () -- Cleans up connections, references, and Combat_Data entries
	.EquipWeapon (self: NPC) -> () -- Equips the NPC's CurrentWeapon attribute via EquipModule
	.UnequipWeapon (self: NPC) -> () -- Unequips the NPC's current weapon via EquipModule
	.Start (self: NPC) -> () -- Enables the NPC's Brain script, making it active in the game
	.Attack (self: NPC) -> () -- Performs an attack via CombatHelper
	.Idle (self: NPC) -> () -- Plays the idle animation for the NPC's current weapon
	.Block (self: NPC) -> () -- Activates blocking via BlockModule
	.Unblock (self: NPC) -> () -- Deactivates blocking via BlockModule
	.Dodge (self: NPC, Direction: Vector3?) -> () -- Performs a dodge via DodgeModule
	.Parry (self: NPC) -> () -- Attempts a parry via ParryModule
	.Phase2 (self: NPC) -> () -- Triggers a phase 2 transformation via ModeModule
	.CastAblity (self: NPC) -> () -- Stub, not yet implemented
	.Climb (self: NPC) -> () -- Stub, not yet implemented
	.WallRun (self: NPC) -> () -- Stub, not yet implemented
	@within NPC
]=]

local npc = {}
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SSModules = SS.Modules
local Dictionaries = SSModules.Dictionaries

local NPC_Dictionary = require(Dictionaries.NPC_Info)
local BlockModule = require(SSModules.BlockModule)
local ParryModule = require(SSModules.Parrying)
local DodgeModule = require(RS.Modules.Movement.Mechnanics.Dodge)
local ModeModule = require(SSModules.Combat.Mode_Module)
local CombatHelper = require(SSModules.Combat.CombatHelper)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local EquipModule = require(SSModules.Combat.EquipModule)
local HelpfullModule = require(ServerStorage.Modules.Other.Helpful)
local Movement = require(RS.Modules.Movement.Objects.Movement)
local MovementTypes = require(RS.Modules.Movement.Objects.Movement.Types)

local Brain_Folder = SS.Brains
local NPCFolder = game.workspace.NPC
local NPCModels = RS.Models.NPC
local WeaponAnimations = RS.Animations.Weapons

npc.__index = npc
local CharToNPC = {}

export type NPC = typeof(setmetatable(
	{} :: {
		FirstName: string,
		LastName: string,
		Difficulty: string,
		MobType: string,
		Character: Model,
		Element: string,
		Brain: Script,
		talents: {},
		skills: {},
		drops: {},
		MovementObj: MovementTypes.MovementObj,
	},
	npc
))

local function CreateModel(npcName, Difficulty, MobType)
	local TargetTemplate: Model = nil
	if Difficulty == "Boss" then
		TargetTemplate = NPCModels:FindFirstChild(npcName)
	elseif MobType == "Humanoid" or MobType == "Human" then
		TargetTemplate = NPCModels:FindFirstChild(npcName)
		-- Then i would randomise hair, skintone, face etc once i make a customastion module
	else
		TargetTemplate = NPCModels[npcName]
	end

	return TargetTemplate:Clone()
end

local function PickDrops(npcName)
	local npcInfo = NPC_Dictionary.getStats(npcName)
	local LootTable = npcInfo.Drops
	local ChosenDrops = {}
	-- Logic to randomly pick drops from the npc's drop table will go here

	return ChosenDrops
end

--[=[
	Constructs a new NPC. Pulls stats from NPC_Dictionary, generates or reuses a Character model,
	equips its default weapon, and starts its idle animation. If the given Character already has
	a "Brain" script (e.g. a dummy NPC set up for testing), its existing Brain and Element are
	reused instead of being regenerated.

	@param NpcName string -- Name used to look up stats via NPC_Dictionary.getStats
	@param char Model? -- Optional pre-existing model to use instead of generating one from templates
	@return NPC
	@within NPC
]=]

function npc.new(NpcName: string, char: Model?): NPC
	-- TODO: remove debug prints once out of beta
	print("➔ npc.new() called! NpcName provided:", tostring(NpcName), "| Type:", type(NpcName))
	local self = setmetatable({
		FirstName = "",
		LastName = "",
		Difficulty = "",
		MobType = "",
		Character = nil :: any,
		Element = "",
		Brain = nil :: any,
		talents = {},
		skills = {},
		drops = {},
	}, npc) :: NPC

	local NPCinfo = NPC_Dictionary.getStats(NpcName)
	print(NPCinfo)
	print(NPC_Dictionary)
	self.MobType = NPCinfo.Mobtype
	self.Difficulty = NPCinfo.Difficulty
	self.Character = char or CreateModel(NpcName, self.Difficulty, self.MobType)

	self.MovementObj = Movement.new(self)

	if self.FirstName ~= "" and self.LastName ~= "" then --- first i would need to make a name generator module that would generate a name based on the npc type and mobtype and then i would use that to set the first and last name of the npc
		self.Character.Name = self.FirstName .. self.LastName
	end

	self.Character.Humanoid.MaxHealth = NPCinfo.Health
	self.Character.Humanoid.Health = NPCinfo.Health

	-- Check if the npc model is in the NPC folder
	if self.Character.Parent ~= NPCFolder then
		self.Character.Parent = NPCFolder
	end

	-- Load the npc's brain (script) based on its type and parent it to the npc model
	-- But first we need to see if the brain already exists in the model (Just in case for dummy npcs that are only used for testing and have the brain already in the model)
	-- The Debuging brains are always going to be called "Brain" and the rest of the brains are going to be called after the npc type (ex: "Boss", "Smallfry", ect)
	-- And because if the npc isn't a debug npc it wont have a brain we can use it as a flag for other things aswell
	if not self.Character:FindFirstChild("Brain") then
		local Brain: Script = Brain_Folder[self.Difficulty]:Clone()
		Brain.Parent = self.Character
		self.Brain = Brain
		for i, v in pairs(NPCinfo.STAT_POINTS) do
			self[i] = v
			self.Character:SetAttribute(i, v)
		end

		self.Character:SetAttribute("CurrentWeapon", "ShootingStar") -- defulat is meant to fists for tesing purposes i am using the kunai
		local Torso = self.Character:FindFirstChild("Torso")
		HelpfullModule.ChangeWeapon(self, self.Character, Torso)
		self:EquipWeapon()

		if self.Difficulty == "Boss" then
			self.Element = NPCinfo.Element
			self.Character:SetAttribute("Element", self.Element)
		elseif self.MobType == "Humanoid" then
			-- Handle humanoid-specific initialization will be random from a table of movesets in the npc info
			-- But for now
			self.Element = NPCinfo.Element
			self.Character:SetAttribute("Element", self.Element)
		else
			-- These are non-humanoids that dont use an element -- I might be wrong here though since mobs would have their own movesets so might create thier own element class for it
			self.Element = "None"
			self.Character:SetAttribute("Element", "None")
		end
	else
		self.Brain = self.Character.Brain
		self.Element = self.Character:GetAttribute("Element")
	end

	CharToNPC[self.Character] = self

	-- This is where the npc's drops are loaded into the npc object so that they can be accessed later when the npc dies
	--self.drops = PickDrops(NpcName)

	Combat_Data.ActiveNPCs[self.Character] = self
	--^ fall back for getting npcs in combat data, this is incase there is a situation where i need to get an npc but i cant use the GetNpcFromCharacter function for some reason, this way i can still get the npc object from the character for example the many cyclic errors that would happen if i try to require the npc module in the combat modules, this way i can just get the npc from the combat data without having to require the npc module in the combat modules and cause cyclic errors

	-- The NPC should be ready by now
	self:Idle()

	return self
end

--[=[
	Looks up the NPC object associated with a given Character model. Useful for retrieving
	an NPC from anywhere in the game as long as you have a reference to its Character.

	@param char Model -- The Character model to look up
	@return NPC? -- The associated NPC, or nil if the character has no NPC object
	@within NPC
]=]

function npc.GetNpcFromCharacter(char): NPC?
	if CharToNPC[char] then
		return CharToNPC[char]
	end
	return nil
end

--[=[
	Destroys the NPC: removes it from CharToNPC and Combat_Data.ActiveNPCs, destroys its
	Character model, then clears and freezes the NPC object itself so it can no longer be
	mutated or reused. Also scrubs any remaining references to this NPC out of every table
	in Combat_Data.
	@within NPC
]=]

function npc:Destroy()
	CharToNPC[self.Character] = nil
	Combat_Data.ActiveNPCs[self.Character] = nil
	self.Character:Destroy()
	table.clear(self)
	table.freeze(self)
	for k, v in pairs(Combat_Data) do
		if type(v) == "table" then
			table.remove(v, table.find(v, self))
		end
	end
end

--[=[
	Equips the NPC's current weapon (per its CurrentWeapon attribute) via EquipModule.
	@within NPC
]=]
function npc:EquipWeapon()
	EquipModule.EquipWeapon(self.Character, self)
end

--[=[
	Unequips the NPC's current weapon via EquipModule.
	@within NPC
]=]
function npc:UnequipWeapon()
	EquipModule.UnequipWeapon(self.Character, self)
end

--[=[
	Enables the NPC's Brain script, activating its behavior tree.
	@within NPC
]=]
function npc:Start()
	if self.Brain and self.Brain:IsA("Script") then
		self.Brain.Disabled = false
	end
end

--[=[
	Loads and plays the idle animation matching the NPC's current weapon. If an idle
	animation is already playing for this NPC, does nothing (prevents restarting the
	animation on repeated calls).
	@within NPC
]=]
function npc:Idle()
	if Combat_Data.IdleAnims[self] and Combat_Data.IdleAnims[self].IsPlaying then
		return
	end
	local hum = self.Character.Humanoid
	local CurrentWeapon = self.Character:GetAttribute("CurrentWeapon")
	Combat_Data.IdleAnims[self] = hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Main.Idle)
	Combat_Data.IdleAnims[self]:Play()
end

--[=[
	Performs an attack via CombatHelper. No-ops if the NPC is currently transforming.
	@within NPC
]=]
function npc:Attack()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	CombatHelper.Attack(self.Character, self)
end

--[=[
	Activates blocking via BlockModule. No-ops if the NPC is transforming or if
	HelpfullModule.CheckForAttributes reports a blocking-incompatible state.
	@within NPC
]=]
function npc:Block()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, nil, true, false, true, nil) then
		return
	end
	BlockModule.ActivateBlocking(self.Character, self)
end

--[=[
	Deactivates blocking via BlockModule. Same guard conditions as Block.
	@within NPC
]=]
function npc:Unblock()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, nil, true, false, true, nil) then
		return
	end
	BlockModule.DeactivateBlocking(self.Character, self)
end

--[=[
	Performs a dodge via DodgeModule, using the NPC's MovementObj. No-ops if transforming.

	@param Direction Vector3? -- Currently unused; DodgeModule.Dodge does not read this argument yet
	@within NPC
]=]
function npc:Dodge(Direction)
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	DodgeModule.Dodge(self.MovementObj)
end

--[=[
	Attempts a parry via ParryModule. No-ops if transforming or if
	HelpfullModule.CheckForAttributes reports a parry-incompatible state.
	@within NPC
]=]
function npc:Parry()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, true, true, false, true, true) then
		return
	end
	ParryModule.ParryAttempt(self.Character, self)
end

--[=[
	Triggers a phase 2 transformation via ModeModule. No-ops if already transforming.
	@within NPC
]=]
function npc:Phase2()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	ModeModule.Mode2(self.Character, self)
end

--[=[
	:::caution Not implemented
	Reserved wrapper for a future cast-ability module. Currently a no-op.
	:::
	@within NPC
]=]
function npc:CastAblity()
	-- My wrap round to use the already made cast ability module but i dont want to require it each time so i put it here
end

--[=[
	:::caution Not implemented
	Reserved wrapper for wall-jump movement. Currently a no-op.
	:::
	@within NPC
]=]
function npc:Climb()
	-- My wrap round to use the already made wall jump module but i dont want to require it each time so i put it here
end

--[=[
	:::caution Not implemented
	Reserved wrapper for wall-run movement. Currently just logs to console.
	:::
	@within NPC
]=]
function npc:WallRun()
	-- My wrap round to use the already made wall run module but i dont want to require it each time so i put it here
end

return npc
