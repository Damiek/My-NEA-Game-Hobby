local module = {}

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService") 
local Debris = game:GetService("Debris")

local Events = RS.Events
local WeaponSounds = SoundService.SFX.Weapons
local SSModules = SS.Modules
local WeaponsAnimations = RS.Animations.Weapons

local CombatEvent = Events.Combat
local UI_Update = Events.UI_Update
local VFX_Event = Events.VFX

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local ServerCombatModule=require(SSModules.CombatModule)
local WeaponsStatsModule = require(SSModules.Weapons.WeaponStats)
local HelpfulModule = require(SSModules.Other.Helpful)
local StunHandler = require(SSModules.Other.StunHandlerV2)
local BoneModule = require(SSModules.Element.Bone)
local Hitboxes_Module = require(SSModules.Hitboxes.VolumeHitboxes)



--- Math Constants  DO NOT TOUCH THIS WILL EFFECT ALL WEAPON SCALING
local Point_Cap = 80 -- This where the Plateau  for dmg drop off starts
local k = 0.2 -- This is the rate of the drop off for Wepaon Scaling
local BaseCritDmg = 1.5 -- Base Crit Dmg Multiplier
local MaxBonus = 1.7 -- Max Crit Dmg Multiplier
local p = 2.0 -- Soft Cap Exponent for Crit Dmg





function module.BodyVelocity(parent,hrp,Knockback,stayTime)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge,0,math.huge)
	bv.P = 50000
	bv.Velocity = hrp.CFrame.LookVector*Knockback
	bv.Parent = parent
	Debris:AddItem(bv,stayTime)
end


function module.Normal_Hitbox(char,weapon,eHum,Hit,...)
	
	
	local hitAnim = ...
	local Truehit = hitAnim
	
	if eHum and eHum.Parent ~= char then
		
		local eChar = eHum.Parent
		local CurrentSlot = char:GetAttribute("CurrentSlot")
		local Eplr = game.Players:GetPlayerFromCharacter(eChar)
		local plr = game.Players:GetPlayerFromCharacter(char)
		local eHRP = eChar.HumanoidRootPart


		local Karma = eChar:GetAttribute("Karma")

		local WeaponStats = WeaponsStatsModule.getStats(weapon)
		-- Dmg Varibles
		local BaseDmg = WeaponStats.Damage
		local Scaling = WeaponStats.Scaling
		local WPN_Points  = char:GetAttribute("WPN")
		local DEX_Points  = char:GetAttribute("DEX")




		local DamageModifiers = 0  -- example: 0%
		local TotalRes = 0.25       -- defender takes 25% less damage 
		local isCrit

		if char:GetAttribute("CritTest") then  
			isCrit = true
		else 
			isCrit = HelpfulModule.CalculateCrit(DEX_Points)
			print(isCrit)
		end
		local CritDmgMult = BaseCritDmg + (MaxBonus - BaseCritDmg) * (DEX_Points / 99)^p
		
		

		local P_eff = Point_Cap + (WPN_Points - Point_Cap) / (1 + math.exp(k * (WPN_Points - Point_Cap))) -- Soft Cap Formula

		local Truedamage = BaseDmg + P_eff * ((BaseDmg / 1000) * Scaling) -- True Damage Formula

		-- Apply  Modifiers
		local MultipliedDamage = Truedamage * (1 + DamageModifiers/100)
		-- Apply Crit
		if isCrit then 
			MultipliedDamage = MultipliedDamage * CritDmgMult
		end
		


	
		


        --Misc Varibles
		local Knockback = WeaponStats.Knockback
		local RagdollTime= WeaponStats.RagdollTime
		local stunTime =WeaponStats.StunTime
		local Karma = eChar:GetAttribute("Karma")
	

		local function handleKarmaDamage(eChar, eHum, damage, Karma)
			if not eHum then return end

			-- Apply the Karma Damage Over Time
			
			local KarmaDamage = BoneModule.applyKarmaDot(eHum, Karma, damage)
			eChar:SetAttribute("Karma",math.min(Karma + 5, 50))-- Karma max is 50
			
			if Eplr then
				UI_Update:FireClient(Eplr, KarmaDamage, eHum.Health, eHum.MaxHealth, damage)
			end
		end


		local Dodges = eChar:GetAttribute("Dodges")

		if HelpfulModule.CheckForStatus(eChar,char,MultipliedDamage,Hit.CFrame,true,true) then  return end


		if Dodges > 1 then
			eChar:SetAttribute("Dodges",Dodges -1)
			print("Dmg not done as " .. char.Name .. " had a dodge")
			eChar:SetAttribute("InCombat",true)

		elseif char:GetAttribute("Element") == "Bone" and char:GetAttribute("Mode2",true) then
			MultipliedDamage = MultipliedDamage * (1 - TotalRes)
			handleKarmaDamage(eChar,eHum,MultipliedDamage,Karma)
			eChar:SetAttribute("InCombat",true)
			return handleKarmaDamage	
			
		else
			MultipliedDamage = MultipliedDamage * (1 - TotalRes)
			eHum:TakeDamage(MultipliedDamage)
			eChar:SetAttribute("InCombat",true)
			local KarmaDamage = 0
			if Eplr then 
				UI_Update:FireClient(Eplr, KarmaDamage, eHum.Health, eHum.MaxHealth, MultipliedDamage)
			end
			
		end



		if char:GetAttribute("Mode1",true) then
			char:SetAttribute("ModeEnergy",100)
		end



		ServerCombatModule.stopAnims(eHum)
		if Dodges > 1 then
		 print("Dodged hitbox VFX")
			
		else
			VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Blood, Hit.CFrame,3)
		end


        if isCrit then 
			VFX_Event:FireAllClients("Highlight",eChar,.5,Color3.fromRGB(255, 0, 0),Color3.fromRGB(255, 0, 0))
          
		else	
			VFX_Event:FireAllClients("Highlight",eChar,.5,Color3.fromRGB(255, 255, 255),Color3.fromRGB(255, 255, 255))
        end
		

		SoundsModule.PlaySound(WeaponSounds[weapon].Combat.Hit, eChar.Torso)

		if eChar:GetAttribute("Dodges") > 1 then
			local hitAnim = WeaponsAnimations.TwinSpears.Dodge["Dodge"..char:GetAttribute("Combo")] -- Replace with actual dodge animations from the twinspears
			eHum.Animator:LoadAnimation(hitAnim):Play()


		else
			eHum.Animator:LoadAnimation(Truehit):Play()

		end


		module.BodyVelocity(char.HumanoidRootPart,char.HumanoidRootPart,Knockback,.2)

		if eChar:GetAttribute("Dodges") > 1 and char:GetAttribute("Combo")>=4 then
			BoneModule.DodgeRandomTP(eChar,char)

		elseif char:GetAttribute("Combo")>=4 then
			Knockback= Knockback*5
			HelpfulModule.Ragdoll(eChar,RagdollTime)
		end


		module.BodyVelocity(eHRP,char.HumanoidRootPart,Knockback,.2)


		StunHandler.Stun(eHum,stunTime)
		

	end


end
		
		


return module
