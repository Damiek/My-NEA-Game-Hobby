-- [Global Varilbles]
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local ServerScripts = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

local WeaponsWeld = RS.Welds.Weapons
local Events = RS.Events
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsSounds = SoundService.SFX.Weapons
local SSModules = SS.Modules

local WeaponsEvent = Events.WeaponsEvent
local BlockingEvent = Events.Blocking
local TransformEvent = Events.Tranform
local DodgeEvent = Events.Dodge
local VFX_Event = Events.VFX
local updateEvent = Events.UpdateMovement

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local HelpfullModule = require(SSModules.Other.Helpful)
local WeaponsStatsModule = require(SSModules.Weapons.WeaponStats)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local Mode_Module = require(SSModules.Combat.Mode_Module)
local ServerCombatModule = require(SSModules.CombatModule)
local DataManager = require(ServerScripts.Data.Modules.DataManager)

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
local DodgeDebounce = Combat_Data.DodgeDebounce
local DodgeCancelCooldown = {}
local DodgeCanCancel = {}
local DodgeIsCancelling = {}

Players.PlayerAdded:Connect(function(plr)
    local char = plr.Character  or plr.CharacterAdded:Wait()

    local profile
    while true do
		profile = DataManager.Profiles[plr]
        if profile then break end
        task.wait(0.1)
    end


	local torso = char.Torso
	char:SetAttribute("CurrentWeapon", "Fists")
	char:SetAttribute("Element", "Bone")
	char:SetAttribute("InCombat", false)
	char:SetAttribute("Dodges", 0)
	char.Parent = workspace.Characters
	HelpfullModule.ChangeWeapon(plr, char, torso)
	
	plr.CharacterAppearanceLoaded:Connect(function(char)
		for i, v in pairs(char:GetDescendants()) do
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

	if action == "Equip/UnEquip" and not char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		if char:GetAttribute("Mode1", true) then
			return
		end
		EquipDebounce[plr] = true

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.Equip, torso)

		IdleAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Idle)
		EquipAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Equip)
		EquipAnims[plr]:Play()

		EquipAnims[plr]:GetMarkerReachedSignal("weld"):Connect(function()
			Welds[plr].Part0 = rightArm
			Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1
		end)

		EquipAnims[plr]:GetMarkerReachedSignal("Equipped"):Connect(function()
			IdleAnims[plr]:Play()
			char:SetAttribute("Equipped", true)
			EquipDebounce[plr] = false
		end)
		EquipAnims[plr].Stopped:Connect(function()
			if char:GetAttribute("Stunned") then
				Welds[plr].Part0 = rightArm
				Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1
				IdleAnims[plr]:Play()
				char:SetAttribute("Equipped", true)
				EquipDebounce[plr] = false
			end
		end)
	elseif action == "Equip/UnEquip" and char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		if char:GetAttribute("Mode1", true) then
			return
		end
		if char:GetAttribute("Mode2", true) then
			return
		end
		EquipDebounce[plr] = true

		char:SetAttribute("Equipped", false)

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.UnEquip, torso)

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
				char:SetAttribute("Equipped", false)
				EquipDebounce[plr] = false
			end
		end)
	end
end)

DodgeEvent.OnServerEvent:Connect(function(plr, action, direction)
	local char = plr.Character
	if not char then
		return
	end

	local hum = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then
		return
	end

	local function setCollisions(state)
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= char:GetAttribute("CurrentWeapon") then
				part.CanCollide = state
			end
		end
	end

	----------------------------------------------------------------
	-- DODGE / ROLL
	----------------------------------------------------------------
	if action == "Dodge" then
		
		if HelpfullModule.CheckForAttributes(char, true, true, true, nil, nil, true, false) then
			return
		end
		if DodgeIsCancelling[plr] then
			return
		end
		if DodgeDebounce[plr] and DodgeCancelCooldown[plr] then
			return
		end

		DodgeDebounce[plr] = true
		DodgeCanCancel[plr] = false
		char:SetAttribute("Dodging", true)
		setCollisions(false)

		local weapon = char:GetAttribute("CurrentWeapon")
		ServerCombatModule.stopAnims(hum)

		-- Determine which animation to play
		local animName = direction
		if direction == "None" or direction == "S" then
			animName = "S" -- Default back dodge
		end

		local dodgeFolder = WeaponsAnimations[weapon].Dodging
		local animToPlay = dodgeFolder[animName] or dodgeFolder.S -- Fallback to Back dodge

		local anim = hum:LoadAnimation(animToPlay)
		DodgeAnims[plr] = anim
		anim:Play()

		anim:GetMarkerReachedSignal("CancelStart"):Connect(function()
			DodgeCanCancel[plr] = true
		end)

		anim:GetMarkerReachedSignal("CancelEnd"):Connect(function()
			DodgeCanCancel[plr] = false
		end)

		task.delay(anim.Length + 0.25, function()
			if DodgeAnims[plr] == anim then
				char:SetAttribute("Dodging", false)
				setCollisions(true)
				DodgeCanCancel[plr] = false
			end
		end)

		task.delay(3, function()

			DodgeDebounce[plr] = false
		end)

	----------------------------------------------------------------
	-- DODGE CANCEL
	----------------------------------------------------------------
	elseif action == "DodgeCancel" then
		if not char:GetAttribute("Dodging") then
			return
		end
		if DodgeCancelCooldown[plr] then
			return
		end
		if not DodgeCanCancel[plr] then
			return
		end
		if DodgeIsCancelling[plr] then
			return
		end

		DodgeCancelCooldown[plr] = true
		DodgeCanCancel[plr] = false
		DodgeIsCancelling[plr] = true

		-- STOP DODGE ANIM
		if DodgeAnims[plr] then
			DodgeAnims[plr]:Stop(0.1)
		end

		local weapon = char:GetAttribute("CurrentWeapon")
		local cancelAnim = hum:LoadAnimation(WeaponsAnimations[weapon].Dodging.DodgeCancel)
		cancelAnim:Play()

		setCollisions(true)

		-- CONFIRM CANCEL (CLIENT VELOCITY RESET)
		DodgeEvent:FireClient(plr, "DodgeCancelConfirmed")

		-- RELEASE LOCK AFTER CANCEL ANIM
		task.delay(cancelAnim.Length, function()
			DodgeIsCancelling[plr] = false
			DodgeDebounce[plr] = false -- allow re-roll
		end)

		-- CANCEL COOLDOWN
		task.delay(0.3, function()
			DodgeCancelCooldown[plr] = nil
		end)
	end
end)

BlockingEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local hum = char:WaitForChild("Humanoid")
	local torso = char.Torso

	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true) then
		return
	end

	if action == "Blocking" then
		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Blocking.BlockingStart, torso)

		BlockingAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Blocking.Blocking)
		BlockingAnims[plr]:Play()

		char:SetAttribute("IsBlocking", true)

		local walkSpeed = WeaponsStatsModule.getStats(currentWeapon).BlockingWalkSpeed

		hum.WalkSpeed = walkSpeed
		hum.JumpHeight = 0
	elseif action == "UnBlocking" and char:GetAttribute("IsBlocking") then
		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Blocking.BlockingStop, torso)

		BlockingAnims[plr]:Stop()
		char:SetAttribute("Parrying", false)
		char:SetAttribute("IsBlocking", false)
		char:SetAttribute("LastStopTime", tick())

		HelpfullModule.ResetMobility(char)
	elseif
		action == "Parry"
		and not char:GetAttribute("IsBlocking")
		and not char:GetAttribute("Parrying")
		and not char:GetAttribute("ParryCD")
	then
		if HelpfullModule.CheckForAttributes(char, true, true, true, true, true, true, true) then
			return
		end
		char:SetAttribute("Parrying", true)
		hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed / 3)
		hum.JumpHeight = 0
		ParryAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Blocking.TryParry)
		ParryAnims[plr]:Play()

		VFX_Event:FireAllClients("Highlight", char, 1, Color3.new(1, 1, 0), Color3.new(0.894118, 0.607843, 0.0588235))

		ParryAnims[plr]:GetMarkerReachedSignal("ParryOver"):Connect(function()
			char:SetAttribute("Parrying", false)
			char:SetAttribute("ParryCD", true)
			task.wait(1)
			char:SetAttribute("ParryCD", false)
		end)

		ParryAnims[plr]:GetMarkerReachedSignal("StunOver"):Connect(function()
			HelpfullModule.ResetMobility(char)
		end)
	end
end)

TransformEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local Race = char:GetAttribute("Race")
	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true) then
		return
	end

	if action == "Mode 1" then
		Mode_Module.Mode1(
			char,
			WeaponsAnimations,
			Race,
			EquipDebounce,
			Welds,
			TransformAnims,
			EquipAnims,
			IdleAnims,
			WeaponsWeld
		)
	elseif action == "Mode 2" and char:GetAttribute("Mode1") and char:GetAttribute("ModeEnergy", 100) then
		Mode_Module.Mode2(
			char,
			WeaponsAnimations,
			Race,
			EquipDebounce,
			Welds,
			TransformAnims,
			EquipAnims,
			IdleAnims,
			WeaponsWeld
		)
	end
end)



updateEvent.OnServerEvent:Connect(function(player, keyName)
    
    print(player.Name .. " pressed the " .. keyName .. " key")
    
    local character = player.Character
    if character then
        character:SetAttribute("CurrentMoveKey", keyName)
    end
end)
