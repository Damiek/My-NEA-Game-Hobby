local module = {}

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer") 
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService") 
local Debris = game:GetService("Debris")

local Events = RS.Events
local WeaponSounds = SoundService.SFX.Weapons
local RSModules = RS.Modules
local SSModules = SS.Modules
local Models = RS.Models
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
local DataManager = require(ServerScriptService.Data.Modules.DataManager)

--- Math varibles  DO NOT TOUCH THIS WILL EFFECT ALL WEAPON SCALING
local P_Cap = 80 -- This where the Plateau  for dmg drop off starts
local k = 0.2 -- This is the rate of the drop off




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
		local player = game.Players:GetPlayerFromCharacter(eChar)
		local eHRP = eChar.HumanoidRootPart
		local Karma = eChar:GetAttribute("Karma")

		local WeaponStats = WeaponsStatsModule.getStats(weapon)
		local damage = WeaponStats.Damage
		local Knockback = WeaponStats.Knockback
		local RagdollTime= WeaponStats.RagdollTime
		local stunTime =WeaponStats.StunTime
		local Karma = eChar:GetAttribute("Karma")

		local function handleKarmaDamage(eChar, eHum, damage, Karma)
			if not eHum then return end

			-- Apply the Karma Damage Over Time
			
			local KarmaDamage = BoneModule.applyKarmaDot(eHum, Karma, damage)
			eChar:SetAttribute("Karma",math.min(Karma + 5, 50))-- Karma max is 50
			
			if player then
				UI_Update:FireClient(player, KarmaDamage, eHum.Health, eHum.MaxHealth, damage)
			end
		end


		local Dodges = eChar:GetAttribute("Dodges")

		if HelpfulModule.CheckForStatus(eChar,char,damage,Hit.CFrame,true,true) then  return end


		if Dodges > 1 then
			eChar:SetAttribute("Dodges",Dodges -1)
			print("Dmg not done as " .. char.Name .. " had a dodge")
			eChar:SetAttribute("InCombat",true)

		elseif char:GetAttribute("Element") == "Bone" and char:GetAttribute("Mode2",true) then
			handleKarmaDamage(eChar,eHum,damage,Karma)
			eChar:SetAttribute("InCombat",true)
			return handleKarmaDamage	
			
		else
			eHum:TakeDamage(damage)
			eChar:SetAttribute("InCombat",true)
			local KarmaDamage = 0
			if player then 
				UI_Update:FireClient(player, KarmaDamage, eHum.Health, eHum.MaxHealth, damage)
			end
			
		end



		if char:GetAttribute("Mode1",true) then
			char:SetAttribute("ModeEnergy",100)
		end



		ServerCombatModule.stopAnims(eHum)
		Hitboxes_Module.DestroyHitboxes(eChar)
		if Dodges > 1 then
		 print("Dodged hitbox VFX")
			
		else
			VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Blood, Hit.CFrame,3)
		end



		VFX_Event:FireAllClients("Highlight",eChar,.5,Color3.fromRGB(255, 255, 255),Color3.fromRGB(255, 255, 255))

		SoundsModule.PlaySound(WeaponSounds[weapon].Combat.Hit, eChar.Torso)

		if eChar:GetAttribute("Dodges") > 1 then
			local hitAnim = WeaponsAnimations.Scythe.Dodge["Dodge"..char:GetAttribute("Combo")]
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
