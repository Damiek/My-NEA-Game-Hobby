local Bone = {}
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules

local Combat_Data = require(SSModules.Combat.Data.CombatData)
local HelpfullModule = require(SSModules.Other.Helpful)


local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsModels = RS.Models.Weapons


local ServerEvents = SS.Server_Events
local DataTransferEvent = ServerEvents.DataTransferEvent


local function getUniqueId(char: Model)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	return uid.Value or nil
end


local Connections = {}
local Weapon_SwapAnimation = {}
local WeaponCounter = {}
local DidSwap = {}
local WeaponArsenal = {
	"Tooth_And_Nail",
	"Judgement",
	"Fang",
	"DrakeFang",
}


DataTransferEvent.Event:Connect(function(ChangeWeapon)
	print("ChangeWeapon Function Recvied from Server!")
	Bone.ChangeWeapon = ChangeWeapon
end)

local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local TransformAnims = Combat_Data.TransformAnims
local ParryAnims = Combat_Data.ParryAnims
local DodgeAnims = Combat_Data.DodgeAnims
local EquipDebounce = Combat_Data.EquipDebounce



-- Optimized function to apply DoT
function Bone.applyKarmaDot(targetHumanoid, initialKarma, baseDamage)
	if not targetHumanoid or not targetHumanoid.Parent then return end

	local karma = initialKarma
	local totalDamage = 0
	local tickRate = 3  -- Default tick rate (Stage 1)

	if karma > 33 then
		tickRate = 1  -- Stage 3
	elseif karma > 16 then
		tickRate = 2  -- Stage 2
	end

	local dotDamage = 3  -- Damage per tick
	local maxKarma = 50
	local karmaDecayRate = 2  -- Karma decreases over time

	-- Run a controlled loop using task.spawn() to avoid performance drops
	task.spawn(function()
		while totalDamage < baseDamage and karma > 0 and targetHumanoid and targetHumanoid.Health > 0 do
			-- Apply damage
			targetHumanoid:TakeDamage(dotDamage)
			totalDamage += dotDamage

			-- Reduce karma over time
			karma = math.max(0, karma - (karmaDecayRate * tickRate))

			task.wait(tickRate)

			-- Stop early if needed
			if totalDamage >= baseDamage or targetHumanoid.Health <= 0 then
				break
			end
		end
	end)

	-- Return final values
	return totalDamage
end

local function Mode1_R(char:Model)
	local plr = game.Players:GetPlayerFromCharacter(char)
	local hum = char.humanoid
	local torso = char:FindFirstChild("Torso")
	local rightArm = char:FindFirstChild("Right Arm")
	
	local Identifier = plr or getUniqueId(char)
	if not Identifier then return end
	local EquipDebounce = Bone.EquipDebounce 
	if EquipDebounce[Identifier] then return end
	local Welds = Bone.Welds 
	local EquipAnims= Bone.EquipAnims 
	local IdleAnims= Bone.IdleAnims
	local WeaponsWeld=	Bone.WeaponsWeld 
	local ChangeWeapon = Bone.ChangeWeapon 
	
	
	if WeaponCounter[Identifier] == nil then
		WeaponCounter[Identifier] = 1
	end
	
	if Connections[Identifier] then
		Connections[Identifier]:Disconnect()
	end
	
	local CharWeaponCounter = WeaponCounter[Identifier]
	local TargetWeapon = WeaponArsenal[CharWeaponCounter]
	
	print(CharWeaponCounter)
	print(TargetWeapon)
	
	EquipDebounce[Identifier] = true
	char:SetAttribute("IsTransforming", true)
	
	Weapon_SwapAnimation[Identifier] = hum:LoadAnimation(WeaponsAnimations.Transformations.Bone.WeaponSwap)
	
	Connections[Identifier]= Weapon_SwapAnimation[Identifier]
		:GetMarkerReachedSignal("Swap")
		:Connect(function()
			DidSwap[Identifier] = true
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end
			
			if HelpfullModule.CheckForAttributes(char,true,true,false,true,true,true) then return end
			
			char:SetAttribute("CurrentWeapon",TargetWeapon)
			
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end
			
			Bone.ChangeWeapon(Identifier,char,torso)
			
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[TargetWeapon].HoldingWeaponWeld.C0
			end
			
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Equip)
			
			
		
			char:SetAttribute("IsTransforming", false)
			EquipDebounce[Identifier] = false
			

			
			

			
			
			
			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end
			
			WeaponCounter[Identifier] = WeaponCounter[Identifier] + 1
			if WeaponCounter[Identifier] > 4 then
				WeaponCounter[Identifier] = 1
			end
			
			
			Connections[Identifier]:Disconnect()
			Connections[Identifier] = nil
			
			
		end)
	
	Weapon_SwapAnimation[Identifier].Stopped:Connect(function()
		if DidSwap[Identifier] then return end
		
		for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
			if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
				return
			end
		end

		if HelpfullModule.CheckForAttributes(char,true,true,false,true,true,true) then return end

		char:SetAttribute("CurrentWeapon",TargetWeapon)

		for _, weapon in ipairs(WeaponsModels:GetChildren()) do
			local existing = char:FindFirstChild(weapon.Name)
			if existing then
				existing:Destroy()
			end
		end

		Bone.ChangeWeapon(Identifier,char,torso)

		if Welds[Identifier] then
			Welds[Identifier].Part0 = rightArm
			Welds[Identifier].C0 = WeaponsWeld[TargetWeapon].HoldingWeaponWeld.C0
		end

		IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Idle)
		EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Equip)


		
		char:SetAttribute("IsTransforming", false)
		EquipDebounce[Identifier] = false
		DidSwap[Identifier] = false





		if IdleAnims[Identifier] then
			IdleAnims[Identifier]:Play()
		end

		WeaponCounter[Identifier] = WeaponCounter[Identifier] + 1
		if WeaponCounter[Identifier] > 4 then
			WeaponCounter[Identifier] = 1
		end
		
		
	end)
	
	
end

local function Mode1_Z()
	
end

local function Mode1_X()
	
end

local function Mode1_C()
	
end

local function Mode2_R()

end

local function Mode2_Z()

end

local function Mode2_X()

end

local function Mode2_C()

end




function Bone.LoadBonePassives (char,rootPart)
	char:SetAttribute("Dodges",24)
end

function Bone.R(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_R()
	elseif char:GetAttribute("Mode1") then
		Mode1_R()
	
	else
		return
	end
end

function Bone.Z(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_Z()
	elseif char:GetAttribute("Mode1") then
		Mode1_Z()

	else
		return
	end
	
end

function Bone.X(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_X()
	elseif char:GetAttribute("Mode1") then
		Mode1_X()

	else
		return
	end
end

function Bone.C(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_C()
	elseif char:GetAttribute("Mode1") then
		Mode1_C()

	else
		return
	end
end






return Bone
