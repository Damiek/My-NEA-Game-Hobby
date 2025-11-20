local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")


local Events = RS.Events

local RSModules = RS.Modules
local SSModules = SS.Modules

local CombatEvent = Events.Combat
local WeaponsModels = RS.Models.Weapons
local WeaponsWeld = RS.Welds.Weapons
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons



local CombatHelperModule =require(SSModules.Combat.CombatHelper)
local HelpfullModule = require(SSModules.Other.Helpful)
local Mode_Module =require(SSModules.Combat.Mode_Module)

local char = script.Parent

char:SetAttribute("Equipped", true)
char:SetAttribute("Combo", 1)
char:SetAttribute("Stunned", false)
char:SetAttribute("Swing", false)
char:SetAttribute("Attacking", false)
char:SetAttribute("iframes",false)
char:SetAttribute("IsBlocking",false)
char:SetAttribute("Blocking",0)
char:SetAttribute("Karma",0)


char:SetAttribute("Mode1", false)
char:SetAttribute("Mode2", false)
char:SetAttribute("Parrying",false)

char:SetAttribute("Dodges",0)
local plr

local Welds = {}
local EquipAnims = {}
local UnEquipAnims = {}
local IdleAnims = {}
local BlockingAnims = {}
local TransformAnims = {}
local ParryAnims = {}
local DodgeAnims = {}
local EquipDebounce = {}

local Race = "SoulReaper"

local function ChangeWeapon(plr,char,torso)
	char:SetAttribute("Equipped", false)
	char:SetAttribute("Combo", 1)
	char:SetAttribute("Stunned", false)
	char:SetAttribute("Swing", false)
	char:SetAttribute("Attacking", false)
	char:SetAttribute("iframes",false)
	char:SetAttribute("IsBlocking",false)
	char:SetAttribute("Blocking",0)
	char:SetAttribute("Karma",0)
	char:SetAttribute("Mode1", false)
	char:SetAttribute("Mode2", false)
	char:SetAttribute("Parrying",false)
	char:SetAttribute("ModeEnergy",100)

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	print(char:GetAttribute("CurrentWeapon"))





	local Weapon = WeaponsModels[currentWeapon]:clone()

	Weapon.Parent = char

	if Weapon:FindFirstChild("SecondWeapon")then
		Weapon.SecondWeld.Part0 = char["Left Arm"]
		Weapon.SecondWeld.Part1 = Weapon.SecondWeapon
	end


	if Weapon:FindFirstChild("Hilt")then
		Weapon.HiltWeld.Part0 = char["Left Arm"]
		Weapon.HiltWeld.Part1 = Weapon.Hilt
	end



	Welds[plr] = WeaponsWeld[currentWeapon].IdleWeaponWeld:Clone()
	Welds[plr].Parent = torso
	Welds[plr].Part0 = torso
	Welds[plr].Part1 = Weapon





	if HelpfullModule.CheckForAttributes(char,true,true,true,true,nil,true) then return end

	if EquipAnims[plr] then EquipAnims[plr]:Stop() end
	if IdleAnims[plr] then IdleAnims[plr]:Stop() end
	if UnEquipAnims[plr] then 	UnEquipAnims[plr]:Stop() end
	if BlockingAnims[plr] then 	BlockingAnims[plr]:Stop() end

	EquipDebounce[plr] = false
end




while task.wait(0.7) do
	CombatHelperModule.Attack(char)
	if char.Humanoid.Health < 20 then
		break
	end
end


char.Humanoid.Health = 100
Mode_Module.Mode1(char,WeaponsAnimations,Race,EquipDebounce,Welds,TransformAnims,EquipAnims,IdleAnims,WeaponsWeld,ChangeWeapon)





char.Humanoid.HealthChanged:Connect(function(newHealth)
	if newHealth < 50 then
		if char:GetAttribute("ModeEnergy") and char:GetAttribute("Mode1") then
			Mode_Module.Mode2(char, WeaponsAnimations, Race, EquipDebounce, Welds, TransformAnims, EquipAnims, IdleAnims, WeaponsWeld, ChangeWeapon)
		end
	end
end)

