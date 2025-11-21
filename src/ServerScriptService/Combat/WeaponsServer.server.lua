-- [Global Varilbles]
local uis = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local StarterPlayer = game:GetService("StarterPlayer")
local ChatService = game:GetService("Chat")
local ServerScriptService = game:GetService("ServerScriptService")
local Runservice = game:GetService("RunService")

local Models = RS.Models
local WeaponsModels = Models.Weapons
local WeaponsWeld = script.Welds.Weapons
local Events = RS.Events
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsSounds = SoundService.SFX.Weapons
local RSModules = RS.Modules
local SSModules = SS.Modules

local WeaponsEvent = Events.WeaponsEvent
local BlockingEvent = Events.Blocking
local TransformEvent = Events.Tranform
local CombatEvent = Events.Combat
local DataTransferEvent= SS.Server_Events.DataTransferEvent

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local HelpfullModule = require(SSModules.Other.Helpful)
local WeaponsStatsModule = require(SSModules.Weapons.WeaponStats)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local Mode_Module = require(SSModules.Combat.Mode_Module)
local ElementInfo = require(SSModules.Element.ElementInfo)
local TransformationModule = require(SSModules.Other.Transformations)
local Textmod = require(SSModules.text)


-- Local Tables
local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local TransformAnims = Combat_Data.TransformAnims
local ParryAnims = Combat_Data.ParryAnims
local DodgeAnims = Combat_Data.DodgeAnims
local EquipDebounce = Combat_Data.EquipDebounce

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


	if HelpfullModule.CheckForAttributes(char,true,true,true,true,nil,true) then return end

	if EquipAnims[plr] then EquipAnims[plr]:Stop() end
	if IdleAnims[plr] then IdleAnims[plr]:Stop() end
	if UnEquipAnims[plr] then 	UnEquipAnims[plr]:Stop() end
	if BlockingAnims[plr] then 	BlockingAnims[plr]:Stop() end

	EquipDebounce[plr] = false
end

DataTransferEvent:Fire(ChangeWeapon)
 



Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function(char)
		local torso = char.Torso
		char:SetAttribute("CurrentWeapon", "Fists")
		char:SetAttribute("Element","Astral")
		char:SetAttribute("Dodges",0)
		char.Parent = workspace.Characters
		ChangeWeapon(plr,char,torso)
	end)

	plr.CharacterAppearanceLoaded:Connect(function(char)
		for i,v in pairs(char:GetDescendants())do
			if v.Parent:IsA("Accessory") and v:IsA("Part") then
				v.CanTouch = false
				v.CanQuery = false
			end
		end
	end)

end)

Players.PlayerRemoving:Connect(function(plr)
	if Welds[plr] then
		table.remove(Welds, table.find(Welds, Welds[plr]))
	end
end)



WeaponsEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local hum = char:WaitForChild("Humanoid")
	local torso = char.Torso
	local rightArm = char["Right Arm"]

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	local attacking = char:GetAttribute("Attacking")
	local stunned = char:GetAttribute("Stunned")



	if action == "Equip/UnEquip" and not char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		if char:GetAttribute("Mode1", true) then return end
		EquipDebounce[plr] = true



		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.Equip,torso)


		IdleAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Idle)
		EquipAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Equip)
		EquipAnims[plr]:Play()

		EquipAnims[plr]:GetMarkerReachedSignal("weld"):Connect(function()
			Welds[plr].Part0 = rightArm
			Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1 

		end)

		EquipAnims[plr]:GetMarkerReachedSignal("Equipped"):Connect(function()
			IdleAnims[plr]:Play()
			char:SetAttribute("Equipped",true)
			EquipDebounce[plr] = false
		end)
		EquipAnims[plr].Stopped:Connect(function()
			local isRagdoll = char:GetAttribute("IsRagdoll")
			if char:GetAttribute("Stunned") then
				Welds[plr].Part0 = rightArm
				Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1 
				IdleAnims[plr]:Play()
				char:SetAttribute("Equipped",true)
				EquipDebounce[plr] = false
				
				
			end
		end)


	elseif action == "Equip/UnEquip" and char:GetAttribute("Equipped")and not EquipDebounce[plr] then

		if char:GetAttribute("Mode1", true) then return end
		if char:GetAttribute("Mode2", true) then return end
		EquipDebounce[plr] = true

		char:SetAttribute("Equipped",false)

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.UnEquip,torso)

		IdleAnims[plr]:Stop()

		UnEquipAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Main.UnEquip)
		UnEquipAnims[plr]:Play()

		UnEquipAnims[plr]:GetMarkerReachedSignal("Weld"):Connect(function()
			Welds[plr].Part0 = torso
			Welds[plr].C1 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C1
			
		end)

		UnEquipAnims[plr]:GetMarkerReachedSignal("UnEquipped"):Connect(function()
			EquipDebounce[plr] = false
		end)

		UnEquipAnims[plr].Stopped:Connect(function()
			if char:GetAttribute("Stunned") then
				Welds[plr].Part0 = torso
				Welds[plr].C1 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C1
				char:SetAttribute("Equipped",false)
				EquipDebounce[plr] = false
			end
		end)
	end
end) 



CombatEvent.OnServerEvent:Connect(function(plr, action)
    local char = plr.Character
    local hum = char:WaitForChild("Humanoid")
    local torso = char.Torso -- Note: Torso is often nil, use HumanoidRootPart (HRP)
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local currentWeapon = char:GetAttribute("CurrentWeapon")
    
    -- Ensure HRP exists and player isn't busy
    if not HRP or HelpfullModule.CheckForAttributes(char, true, true, true, nil, true) then 
        return 
    end

    if action == "Dodge" then
        SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Combat.Dodging, torso or HRP)

        DodgeAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Dodging.Dodge)
        DodgeAnims[plr]:Play()

        local direction = HRP.CFrame.LookVector 
        local dodgeForce = 20000 
        local duration = 0.2 

        
        HRP:SetNetworkOwner(nil) 

        HRP:ApplyImpulse(direction * dodgeForce)
        
        task.delay(duration, function()
            HRP:SetNetworkOwner(plr) 
        end)

        hum.PlatformStand = true
        task.delay(DodgeAnims[plr].Length, function()
             if hum.PlatformStand then
                 hum.PlatformStand = false
             end
        end)
    end
end)


BlockingEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local hum = char:WaitForChild("Humanoid")
	local torso = char.Torso
	local rightArm = char["Right Arm"]

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	local attacking = char:GetAttribute("Attacking")
	local stunned = char:GetAttribute("Stunned")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	if HelpfullModule.CheckForAttributes(char,true,true,true,nil,true) then return end



	if action == "Blocking" then

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Blocking.BlockingStart,torso)



		BlockingAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Blocking.Blocking)
		BlockingAnims[plr]:Play()

		char:SetAttribute("IsBlocking",true)

		local walkSpeed = WeaponsStatsModule.getStats(currentWeapon).BlockingWalkSpeed



		hum.WalkSpeed =walkSpeed
		hum.JumpHeight = 0






	elseif action == "UnBlocking" and char:GetAttribute("IsBlocking") then


		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Blocking.BlockingStop,torso)

		BlockingAnims[plr]:Stop()
		char:SetAttribute("Parrying",false)
		char:SetAttribute("IsBlocking",false)
		char:SetAttribute("LastStopTime",tick())

		hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
		hum.JumpHeight = StarterPlayer.CharacterJumpHeight

	elseif action == "Parry" and not char:GetAttribute("IsBlocking") and not char:GetAttribute("Parrying") and not char:GetAttribute("ParryCD") then
		if HelpfullModule.CheckForAttributes(char,true,true,true,true,true,true) then return end
		char:SetAttribute("Parrying",true)
		hum.WalkSpeed =  ((StarterPlayer.CharacterWalkSpeed)/2)
		hum.JumpHeight = 0
		ParryAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Blocking.TryParry)
		ParryAnims[plr]:Play()
		local ParryHighlight= Instance.new("Highlight")
		ParryHighlight.FillColor = Color3.new(1, 1, 0)
		ParryHighlight.FillTransparency = 0.5
		ParryHighlight.OutlineColor = Color3.new(0.894118, 0.607843, 0.0588235)
		ParryHighlight.OutlineTransparency = 0.6
		ParryHighlight.Parent = char

		ParryAnims[plr]:GetMarkerReachedSignal("ParryOver"):Connect(function()
			char:SetAttribute("Parrying",false)
			ParryHighlight:Destroy()
			char:SetAttribute("ParryCD",true)
			task.wait(3)
			char:SetAttribute("ParryCD",false)

		end)

		ParryAnims[plr]:GetMarkerReachedSignal("StunOver"):Connect(function()
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		end)







	end


end)

TransformEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local Race= char:GetAttribute("Race")
	if HelpfullModule.CheckForAttributes(char,true,true,true,nil,true) then return end

	if action == "Mode 1" then
		Mode_Module.Mode1(char,WeaponsAnimations,Race,EquipDebounce,Welds,TransformAnims,EquipAnims,IdleAnims,WeaponsWeld,ChangeWeapon)
	elseif action == "Mode 2" and char:GetAttribute("Mode1") and char:GetAttribute("ModeEnergy",100) then 
		Mode_Module.Mode2(char,WeaponsAnimations,Race,EquipDebounce,Welds,TransformAnims,EquipAnims,IdleAnims,WeaponsWeld,ChangeWeapon)
	end 
end)