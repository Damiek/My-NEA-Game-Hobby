local EquipModule = {}
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local SSModules = SS.Modules
local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local HelpfullModule = require(SSModules.Other.Helpful)

local WeaponsWeld = RS.Welds.Weapons
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsSounds = SoundService.SFX.Weapons

local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local EquipDebounce = Combat_Data.EquipDebounce

function EquipModule.EquipWeapon(char, npc)
	if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true, nil) then
		return
	end
	local Identifier = Players:GetPlayerFromCharacter(char) or npc
	local hum = char:WaitForChild("Humanoid")
	local torso = char.Torso
	local rightArm = char["Right Arm"]

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	if char:GetAttribute("Mode1", true) or char:GetAttribute("Mode2", true) then
		return
	end
	EquipDebounce[Identifier] = true

	SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.Equip, torso)

	IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Idle)
	EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Equip)
	EquipAnims[Identifier]:Play()

	EquipAnims[Identifier]:GetMarkerReachedSignal("weld"):Connect(function()
		Welds[Identifier].Part0 = rightArm
		Welds[Identifier].C0 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C0
	end)

	EquipAnims[Identifier]:GetMarkerReachedSignal("Equipped"):Connect(function()
		IdleAnims[Identifier]:Play()
		char:SetAttribute("Equipped", true)
		EquipDebounce[Identifier] = false
	end)
	EquipAnims[Identifier].Stopped:Connect(function()
		if char:GetAttribute("Stunned") then
			Welds[Identifier].Part0 = rightArm
			Welds[Identifier].C0 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C0
			IdleAnims[Identifier]:Play()
			char:SetAttribute("Equipped", true)
			EquipDebounce[Identifier] = false
		end
	end)
end

function EquipModule.UnequipWeapon(char, npc)
	if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true, nil) then
		return
	end
	local Identifier = Players:GetPlayerFromCharacter(char) or npc
	local torso = char.Torso
	local hum = char:WaitForChild("Humanoid")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if char:GetAttribute("Mode1", true) or char:GetAttribute("Mode2", true) then
		return
	end

	

	EquipDebounce[Identifier] = true

	char:SetAttribute("Equipped", false)
	print("Unequped for", char)

	SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.UnEquip, torso)

	IdleAnims[Identifier]:Stop()

	UnEquipAnims[Identifier] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Main.UnEquip)
	UnEquipAnims[Identifier]:Play()
	EquipDebounce[Identifier] = false

	UnEquipAnims[Identifier]:GetMarkerReachedSignal("Weld"):Connect(function()
		Welds[Identifier].Part0 = torso
		Welds[Identifier].C0 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C0
	end)

	UnEquipAnims[Identifier]:GetMarkerReachedSignal("UnEquipped"):Connect(function()
		EquipDebounce[Identifier] = false
	end)

	UnEquipAnims[Identifier].Stopped:Connect(function()
		if char:GetAttribute("Stunned") then
			Welds[Identifier].Part0 = torso
			Welds[Identifier].C0 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C0
			char:SetAttribute("Equipped", false)
			print("EQuipdebouce, stop!")
			EquipDebounce[Identifier] = false
		end
	end)
end

return EquipModule
