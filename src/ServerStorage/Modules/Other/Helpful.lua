local module = {}
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules

local WeaponsModels = RS.Models.Weapons

local BlockingModule = require(script.Parent.Parent.BlockModule)
local Combat_Data = require(SSModules.Combat.Data.CombatData)

local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local EquipDebounce = Combat_Data.EquipDebounce
local WeaponsWeld = RS.Welds.Weapons






function module.ChangeWeapon(plr,char,torso)
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

	local currentWeapon = char:GetAttribute("CurrentWeapon")

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

	if module.CheckForAttributes(char,true,true,true,true,nil,true,true) then return end 


    if EquipAnims[plr] then EquipAnims[plr]:Stop() end
	if IdleAnims[plr] then IdleAnims[plr]:Stop() end
	if UnEquipAnims[plr] then 	UnEquipAnims[plr]:Stop() end
	if BlockingAnims[plr] then 	BlockingAnims[plr]:Stop() end

	EquipDebounce[plr] = false
	
end



function module.CheckInFront(char,enemyChar)
	local enemyHRP = enemyChar.HumanoidRootPart
	local attackDirection = (char.HumanoidRootPart.Position - enemyHRP.Position).Unit
	local frontDirection = enemyHRP.CFrame.LookVector
	local direction = math.acos(attackDirection:Dot(frontDirection)) < math.rad(90)
	
	 if not direction then
		print("Not infront")
			return false
	 else
			print("infront")
			return true
	 end
end

function module.ResetMobility(char)
	local hum = char.Humanoid
	local plr  = Players:GetPlayerFromCharacter(char)
	if char:GetAttribute("IsLow") and char:GetAttribute("InCombat") then 
		hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed) / 2
		hum.JumpHeight = (StarterPlayer.CharacterJumpHeight) / 2
		if plr then 
			print(char.Name, "Was low so speed is halved")
		end
		
	else 
		hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
		hum.JumpHeight = StarterPlayer.CharacterJumpHeight
	end
end

function module.CheckForStatus(eChar,char,blockingDamage,hitPos,CheckForBlocking,CheckForParrying)
	local stop = false
	
	if CheckForParrying and not stop then
		if eChar:GetAttribute("Parrying") and module.CheckInFront(char,eChar) then 
			BlockingModule.Parrying(char,eChar,hitPos)  stop = true end
	end
	
	
	
	if CheckForBlocking and not stop then
		if eChar:GetAttribute("IsBlocking") and module.CheckInFront(char,eChar) then
			 BlockingModule.Blocking(eChar,blockingDamage,hitPos) stop = true end
		
	end
	
	if eChar.Humanoid.Health <= 0 or  eChar:GetAttribute("Iframes") or eChar:GetAttribute("Dodging") then stop  = true end
	
	return stop
		
end

function module.CheckForAttributes(char,attack,swing,stun,ragdoll,equipped,blocking,Dodging)
	local attacking = char:GetAttribute("Attacking")
	local swing   = char:GetAttribute("Swing")
	local stunned  = char:GetAttribute("Stunned")
	local isEquipped = char:GetAttribute("Equipped")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	local isBlocking = char:GetAttribute("isBlocking")
	local isDodging = char:GetAttribute("Dodging")
	
	local stop = false
	
	
	if attacking and attack then stop = true end
	if swing and swing then stop = true end
	if stunned and stun then stop = true end
	if isRagdoll and ragdoll then stop = true end
	if equipped ~= nil and not isEquipped then stop = true end
	if blocking ~= nil and isBlocking then stop = true end
	if Dodging ~= nil and isDodging then stop = true end
	
	return stop
end






function module.Ragdoll(char,ragdollTime)
	task.spawn(function()
		if char:GetAttribute("IsRagdoll") then return end
		
		char:SetAttribute("IsRagdoll", true)
		task.wait(ragdollTime)
		char:SetAttribute("IsRagdoll",false)
		char:SetAttribute("iframes",true)
		Instance.new("Highlight",char)
		task.wait(.6)
		char.Highlight:Destroy()
		char:SetAttribute("iframes",false)
	end)
end
return module
