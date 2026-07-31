local plr = {}
plr.__index = plr
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local SSModules = SS.Modules
local RSModules = RS.Modules

local DataManger = require(ServerScriptService.Data.Modules.DataManager)
local Movement = require(RSModules.Movement.Objects.Movement)
local MOvementObjType = require(RSModules.Movement.Objects.Movement.Types)
local AcessoryManager = require(SSModules.Other.AccessoriesManager)
local CombatData = require(SSModules.Combat.Data.CombatData)
local helpfullModule = require(SSModules.Other.Helpful)
local CombatHelper = require(SSModules.Combat.CombatHelper)
local ModeModule = require(SSModules.Combat.Mode_Module)
local ParryModule = require(SSModules.Parrying)

local CONFIG = {
	VIT = {
		BASE_HEALTH = 250,
		VIT_HEALTH_MULTIPLIER = 1,
		LOW_HEALTH_THRESHOLD = 0.25,
	},

	END = {
		BASE_HIGH_STAMINA = 25,
		BASE_LOW_STAMINA = 15,
	},

	SPT = {

		BASE_MANA = 250,
		BASE_HIGH_MANA = 50,
		BASE_LOW_MANA = 30,

		BASE_MF = 120,
		BASE_HIGH_MF = 25,
		BASE_LOW_MF = 15,
	},

	EXP = {
		k = 0.08,
		MidPoint = 50,
	},
}

export type PLR = typeof(setmetatable( -- Custom type to make looking for stuff such much easier serves no other purpose
	{} :: {
		IsReady: boolean,
		Highlight: Highlight,
		HasMoved: boolean,
		Player: Player,
		Data: DataManger.SlotData,
		Character: Model,
		CurrentSlot: string,
		FirstName: string,
		LastName: string,
		HairColor: Color3,
		Element: string,
		MovementObj: MOvementObjType.MovementObj,
		Intent: string,
		Stats: {
			VIT: number,
			END: number,
			STR: number,
			SPT: number,
			DEX: number,
			AGL: number,
			WPN: number,
		},
		Talents: {},
		Skills: {},
	},
	plr
))



local CHAR_GROUP = "Characters"
local VFX_GROUP = "VFX_Models"


pcall(function() PS:RegisterCollisionGroup(CHAR_GROUP) end )

PS:CollisionGroupSetCollidable(CHAR_GROUP, VFX_GROUP, false)

local function GroupSeter(char:Model)
	for i, child in ipairs(char:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CollisionGroup = CHAR_GROUP
		end
	end

	char.DescendantAdded:Connect(function(new)
		if new:IsA("BasePart") and new.CanCollide then
			new.CollisionGroup = CHAR_GROUP
		end

	end)
end

local function LoadCharacterAppearance(plr: PLR)
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local AccessoriesFolder = Instance.new("Folder")
	local WeldsFolder = Instance.new("Folder")

	WeldsFolder.Name = "Welds"
	WeldsFolder.Parent = AccessoriesFolder
	AccessoriesFolder.Name = "Accessories"
	AccessoriesFolder.Parent = plr.Character

	for accessoryType, accessoryName in pairs(plr.Data.Accessories) do
		if accessoryName ~= "" then
			AcessoryManager.EquipAccessory(plr.Character, accessoryType)
		end
	end

	local bodyColors = plr.Character:FindFirstChildOfClass("BodyColors")

	if plr.Data.Appearance.Skin_Tone ~= "" then
		for i, colour in pairs(bodyColors) do
			if
				i.Name == "HeadColor"
				or i.Name == "LeftArmColor"
				or i.Name == "RightArmColor"
				or i.Name == "LeftLegColor"
				or i.Name == "RightLegColor"
				or i.Name == "TorsoColor"
			then
				i.Color = Color3.fromHex(plr.Data.Appearance.Skin_Tone)
			end
		end
	end
end

local function SetupStats(plr: PLR)
	local char = plr.Character

	local function setupSPT(char)
		local MaxMana = 0
		local MaxMF = 0

		local function sync(char)
			local SPT = char:GetAttribute("SPT") or 0

			if SPT == 0 then
				MaxMana = CONFIG.SPT.BASE_MANA
				MaxMF = CONFIG.SPT.BASE_MF
				char:SetAttribute("MaxMana", MaxMana)
				char:SetAttribute("Mana", MaxMana)
				char:SetAttribute("MaxMF", MaxMF)
				char:SetAttribute("MF", MaxMF)
			end

			if SPT >= 1 and SPT <= 15 then
				MaxMana = math.ceil(80 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 1) / 14))
				MaxMF = math.ceil(40 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 1) / 28))
				char:SetAttribute("MaxMF", MaxMF)
				char:SetAttribute("MaxMana", MaxMana)
				char:SetAttribute("Mana", MaxMana)
				print("MaxSet")
			elseif SPT >= 16 and SPT <= 35 then
				MaxMana = math.ceil(105 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 15) / 15))
				MaxMF = math.ceil(53 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 15) / 30))
				char:SetAttribute("MaxMF", MaxMF)
				char:SetAttribute("MaxMana", MaxMana)
				char:SetAttribute("Mana", MaxMana)
			elseif SPT >= 36 and SPT <= 60 then
				MaxMana = math.ceil(130 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 30) / 20))
				MaxMF = math.ceil(65 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 30) / 40))
				char:SetAttribute("MaxMF", MaxMF)
				char:SetAttribute("MaxMana", MaxMana)
				char:SetAttribute("Mana", MaxMana)
			elseif SPT >= 61 and SPT <= 99 then
				MaxMana = math.ceil(155 + CONFIG.SPT.BASE_LOW_MANA * ((SPT - 50) / 49))
				MaxMF = math.ceil(78 + CONFIG.SPT.BASE_LOW_MF * ((SPT - 50) / 80))
				char:SetAttribute("MaxMF", MaxMF)
				char:SetAttribute("MaxMana", MaxMana)
				char:SetAttribute("Mana", MaxMana)
			end
		end
		sync(char)

		char:GetAttributeChangedSignal("SPT"):Connect(function()
			local Orginal_Mana = char:GetAttribute("Mana")
			local Orginal_MF = char:GetAttribute("MF")
			sync(char)
			if char:GetAttribute("InCombat") then
				char:SetAttribute("Mana", Orginal_Mana)
				char:SetAttribute("MF", Orginal_MF)
			end

			print("New Target for MANA = {", MaxMana, "}")
			print("New Target for MF = {", MaxMF, "}")
		end)
	end

	local function setupHealth(char)
		local hum = char:WaitForChild("Humanoid")

		local VIT = char:GetAttribute("VIT") or 0
		hum.MaxHealth = CONFIG.VIT.BASE_HEALTH + (VIT * CONFIG.VIT.VIT_HEALTH_MULTIPLIER)
		hum.Health = hum.MaxHealth

		-- Update max health when VIT changes
		char:GetAttributeChangedSignal("VIT"):Connect(function()
			local VIT = char:GetAttribute("VIT") or 0
			hum.MaxHealth = CONFIG.VIT.BASE_HEALTH + (VIT * CONFIG.VIT.VIT_HEALTH_MULTIPLIER)
		end)

		-- Monitor low health state
		hum.HealthChanged:Connect(function()
			if hum.Health <= hum.MaxHealth * CONFIG.VIT.LOW_HEALTH_THRESHOLD then
				char:SetAttribute("IsLow", true)
				helpfullModule.ResetMobility(char)
			else
				char:SetAttribute("IsLow", false)
				helpfullModule.ResetMobility(char)
			end
		end)
	end

	local function setupStamina(char)
		local MaxStamina = 0

		local function sync(char)
			local END = char:GetAttribute("END") or 0

			if END >= 1 and END <= 15 then
				MaxStamina = math.ceil(80 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 1) / 14))
				char:SetAttribute("MaxStamina", MaxStamina)
				char:SetAttribute("Stamina", MaxStamina)
				print("MaxSet")
			elseif END >= 16 and END <= 35 then
				MaxStamina = math.ceil(105 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 15) / 15))
				char:SetAttribute("MaxStamina", MaxStamina)
				char:SetAttribute("Stamina", MaxStamina)
			elseif END >= 36 and END <= 60 then
				MaxStamina = math.ceil(130 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 30) / 20))
				char:SetAttribute("MaxStamina", MaxStamina)
				char:SetAttribute("Stamina", MaxStamina)
			elseif END >= 61 and END <= 99 then
				MaxStamina = math.ceil(155 + CONFIG.END.BASE_LOW_STAMINA * ((END - 50) / 49))
				char:SetAttribute("MaxStamina", MaxStamina)
				char:SetAttribute("Stamina", MaxStamina)
			end
		end
		sync(char)

		char:GetAttributeChangedSignal("END"):Connect(function()
			local Orginal = char:GetAttribute("Stamina")
			sync(char)
			if char:GetAttribute("InCombat") then
				char:SetAttribute("Stamina", Orginal)
			end

			print("New Target for STM = {", MaxStamina, "}")
		end)
	end

	for statName, statValue in pairs(plr.Data.STAT_POINTS) do
		plr.Stats[statName] = statValue
		char:SetAttribute(statName, statValue)
	end

	setupHealth(char)
	setupSPT(char)
	setupStamina(char)
end

local function SetupStates(plr: PLR)
	local char = plr.Character
	char:SetAttribute("CurrentWeapon", "Fists") -- I would replace this with the players's weapon in .Data when i add not movesert restricted weapons
	char:SetAttribute("Element", "Astral")
	char:SetAttribute("InCombat", false)
	char:SetAttribute("Dodges", 0)
	char:SetAttribute("MF", 0)
	char:SetAttribute("Blocking", 0)
	char:SetAttribute("Karma", 0)
end

local playertoPLR = {}

function plr.new(Player: Player, Slot: string): PLR?
	local self = setmetatable({
		IsReady = false,
		HasMoved = false,
		Highlight = nil,
		Player = Player,
		Data = nil,
		FirstName = "",
		LastName = "",
		Character = Player.Character :: any,
		CurrentSlot = Slot,
		Element = "",
		Intent = "None",
		Talents = {},
		Skills = {},
		Stats = {
			VIT = 0,
			END = 0,
			STR = 0,
			SPT = 0,
			DEX = 0,
			AGL = 0,
			WPN = 0,
		},
	}, plr) :: PLR

	local profile
	while true do
		print(DataManger.Profiles)
		profile = DataManger.Profiles[Player]
		print("Player data not found")
		if profile then
			break
		end
		task.wait(0.1)
	end

	self.MovementObj = Movement.new(Player)


	self.Data = profile.Data[Slot]

	if self.Character.Parent ~= Workspace.Characters then
		self.Character.Parent = workspace.Characters
	end

	while self.MovementObj.IsReady == false do
		task.wait(0.1)
	end

	local Cframeparts = self.Data.LastLocation

	if Cframeparts then
		local Cframe = CFrame.new(table.unpack(Cframeparts))
		self.Character:SetPrimaryPartCFrame(Cframe)
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Parent = self.Character
	Highlight.FillColor = Color3.new(0, 1, 0)
	Highlight.Name = "InitializeHighlight"
	self.Highlight = Highlight
	self.Character:SetAttribute("Iframes", true)
	self.Character:SetAttribute("CurrentSlot",Slot)

	self.CurrentSlot = Slot
	self.HairColor = Color3.new(
		self.Data.Appearance.Hair_Colour.Red,
		self.Data.Appearance.Hair_Colour.Green,
		self.Data.Appearance.Hair_Colour.Blue
	)
	self.Element = self.Data.Element

	LoadCharacterAppearance(self)
	SetupStats(self)
	SetupStates(self)
	GroupSeter(self.Character)

	for i, v in pairs(self.Character:GetDescendants()) do
		if v.Parent:IsA("Accessory") and v:IsA("Part") then
			v.CanTouch = false
			v.CanQuery = false
		end
	end

	local Torso = self.Character:FindFirstChild("Torso")
	helpfullModule.ChangeWeapon(self.Player, self.Character, Torso)

	playertoPLR[Player] = self
	self.IsReady = true

	return self
end

function plr:Cleanup()
	if not self.Player or self._cleaned then
		return
	end
	self._cleaned = true

	AcessoryManager.CleanupForPlayer(self.Player)

	if self.MovementObj then
		pcall(function()
			self.MovementObj:Destroy()
		end)
		self.MovementObj = nil
	end

	local Identifier = self.Player
	CombatData.ClearForPlayer(Identifier)
	CombatHelper.CleanupForPlayer(Identifier)
	ModeModule.CleanupForPlayer(Identifier)
	ParryModule.CleanupForPlayer(Identifier)

	playertoPLR[self.Player] = nil
end

function plr:Destroy()
	local Character = self.Character
	if Character then
		local HRP = Character:FindFirstChild("HumanoidRootPart")
		if HRP and self.Data then
			local CframeParts = { HRP.CFrame:GetComponents() }
			self.Data.LastLocation = CframeParts
		end
	end

	self:Cleanup()

	if self.Character then
		pcall(function()
			self.Character:Destroy()
		end)
	end

	table.clear(self)
	table.freeze(self)
end

function plr.GetPLRFromPlayer(Player: Player): PLR?
	if playertoPLR[Player] then
		return playertoPLR[Player]
	else
		warn("[PlayerObject]: This player doesn't have a valid plr object")
		return nil
	end
end

function plr:IncreaseStat(statName: string, amount: number)
	self.Data.STAT_POINTS[statName] = self.Data.STAT_POINTS[statName] + (amount or 1)
end

function plr:EquipAccessory(accessoryType: string, accessoryName: string)
	AcessoryManager.EquipAccessory(self.Character, accessoryType)
	DataManger.UpdateAccessories(self.Player, accessoryType, accessoryName)
end

function plr:UnequipAccessory(accessoryType: string)
	AcessoryManager.UnequipAccessory(self.Character, accessoryType)
	DataManger.UpdateAccessories(self.Player, accessoryType, "")
end

function plr:FirstMovement()
	self.HasMoved = true
	local char = self.Character
	char:SetAttribute("Iframes", false)
	local hl = self.Highlight
	if hl and hl.Parent then
		hl:Destroy()
	end
end

return plr
