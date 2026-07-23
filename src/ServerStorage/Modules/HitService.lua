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
local ServerCombatModule = require(SSModules.CombatModule)
local WeaponsStatsModule = require(SSModules.Dictionaries.WeaponStats)
local HelpfulModule = require(SSModules.Other.Helpful)
local StunHandler = require(SSModules.Other.StunHandlerV2)
local PassiveManger = require(SSModules.Combat.PassiveManger)

--- Math Constants  DO NOT TOUCH THIS WILL EFFECT ALL WEAPON SCALING
local Point_Cap = 80 -- This where the Plateau  for dmg drop off starts
local k = 0.2 -- This is the rate of the drop off for Wepaon Scaling

local function GetNPCFromCharacter(char)
	local plr = game.Players:GetPlayerFromCharacter(char)
	if plr then return nil end
	local npcModule = require(SSModules.Objects.npc)
	return npcModule.GetNpcFromCharacter(char)
end

function module.BodyVelocity(parent, hrp, Knockback, stayTime)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bv.P = 50000
	bv.Velocity = hrp.CFrame.LookVector * Knockback
	bv.Parent = parent
	Debris:AddItem(bv, stayTime)
end

function module.Normal_Hitbox(char, weapon, eHum, npc, Hit, ...)
	local hitAnim = ...
	local Truehit = hitAnim

	if eHum and eHum.Parent ~= char then
		local eChar = eHum.Parent
		local Eplr = game.Players:GetPlayerFromCharacter(eChar)
		local Enpc = GetNPCFromCharacter(eChar)

		local eHRP = eChar.HumanoidRootPart

		local WeaponStats = WeaponsStatsModule.getStats(weapon)
		-- Dmg Varibles
		local BaseDmg = WeaponStats.Damage
		local Scaling = WeaponStats.Scaling
		local WPN_Points = char:GetAttribute("WPN") or npc.WPN
		local DEX_Points = char:GetAttribute("DEX") or npc.DEX
		local SPT_Points = char:GetAttribute("SPT") or npc.SPT

		local STAT_POINTS = {
			DEX = DEX_Points,
			WPN = WPN_Points,
			SPT = SPT_Points,
		}

		local Dodges = char:GetAttribute("Dodges")

		local P_eff = Point_Cap + (WPN_Points - Point_Cap) / (1 + math.exp(k * (WPN_Points - Point_Cap))) -- Soft Cap Formula

		local Truedamage = BaseDmg + P_eff * ((BaseDmg / 1000) * Scaling) -- True Damage Formula

		--Misc Varibles
		local Knockback = WeaponStats.Knockback
		local RagdollTime = WeaponStats.RagdollTime
		local stunTime = WeaponStats.StunTime

		local stop, result =
			HelpfulModule.CheckForStatus(eChar, char, Enpc, BaseDmg, Hit.CFrame, true, true, true, true)
		print(result, "helpful result")
		if stop then
			return result
		end

		local PassiveCheckDmg, isCrit, damageAlreadydealt =
			PassiveManger.M1LandedPassive(char, eChar, Truedamage, STAT_POINTS)

		print(PassiveCheckDmg)

		if damageAlreadydealt == false then
			eHum:TakeDamage(PassiveCheckDmg)
		end

		eChar:SetAttribute("InCombat", true)
		local KarmaDamage = 0
		if Eplr then
			UI_Update:FireClient(Eplr, KarmaDamage, eHum.Health, eHum.MaxHealth, PassiveCheckDmg)
		end

		if char:GetAttribute("Mode1", true) then
			char:SetAttribute("ModeEnergy", 100)
		end

		ServerCombatModule.stopAnims(eHum)
		if Dodges > 1 then
			print("Dodged hitbox VFX")
		else
			VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Blood, Hit.CFrame, 3)
		end

		if isCrit then
			if char:GetAttribute("Element") == "Astral" then
				VFX_Event:FireAllClients(
					"Highlight",
					eChar,
					0.5,
					Color3.fromRGB(255, 0, 0),
					Color3.fromRGB(138, 0, 229)
				)
			else
				VFX_Event:FireAllClients("Highlight", eChar, 0.5, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0))
			end
		else
			if char:GetAttribute("Element") == "Astral" then
				VFX_Event:FireAllClients(
					"Highlight",
					eChar,
					0.5,
					Color3.fromRGB(138, 0, 229),
					Color3.fromRGB(138, 0, 229)
				)
			else
				VFX_Event:FireAllClients(
					"Highlight",
					eChar,
					0.5,
					Color3.fromRGB(255, 255, 255),
					Color3.fromRGB(246, 211, 211)
				)
			end
		end

		SoundsModule.PlaySound(WeaponSounds[weapon].Combat.Hit, eChar.Torso)

		if eChar:GetAttribute("Dodges") > 1 then
			local hitAnim = WeaponsAnimations.TwinSpears.Dodge["Dodge" .. char:GetAttribute("Combo")]
			eHum.Animator:LoadAnimation(hitAnim):Play()
			VFX_Event:FireAllClients("AfterImage", eChar, hitAnim, nil)
		else
			eHum.Animator:LoadAnimation(Truehit):Play()
		end

		module.BodyVelocity(char.HumanoidRootPart, char.HumanoidRootPart, Knockback, 0.2)

		if eChar:GetAttribute("Dodges") > 1 and char:GetAttribute("Combo") >= 4 then
			-- BoneModule.DodgeRandomTP(eChar, char)
			-- TODO: Replace the aboove with the element object rather than a pure modue
		elseif char:GetAttribute("Combo") >= 4 then
			Knockback = Knockback * 9
			--HelpfulModule.Ragdoll(eChar,RagdollTime)
		end

		module.BodyVelocity(eHRP, char.HumanoidRootPart, Knockback, 0.3)

		StunHandler.Stun(eHum, stunTime)
		print(result)
		return result
	end

	return "Missed"
end

function module.Blink_Hitbox(char, weapon, eHum: Humanoid, npc, Hit, ...)
	local hitAnim = ...
	local Truehit = hitAnim

	if eHum and eHum.Parent ~= char then
		local eChar = eHum.Parent
		local Eplr = game.Players:GetPlayerFromCharacter(eChar)
		local Enpc = GetNPCFromCharacter(eChar)

		local BaseDmg = 20 -- would replace with actual WPN scaling when we have it

		local stop, result =
			HelpfulModule.CheckForStatus(eChar, char, Enpc, BaseDmg, Hit.CFrame, true, true, true, true)
		print(result, "helpful result")
		if stop and result ~= "HitLanded" then
			return result
		end

		-- local PassiveCheckDmg, isCrit, damageAlreadydealt =	PassiveManger.BlinkHitPassive(char,eChar,BaseDmg)  doesnt exist yet but will be added in the future

		print(eHum)

		if eChar:GetAttribute("Dodges") and eChar:GetAttribute("Dodges") > 1 then
			local hitAnim = WeaponsAnimations.TwinSpears.Dodge["Dodge" .. char:GetAttribute("Combo")]
			eHum.Animator:LoadAnimation(hitAnim):Play()
			VFX_Event:FireAllClients("AfterImage", eChar, hitAnim, nil)
		else
			eHum.Animator:LoadAnimation(Truehit):Play()
		end

		SoundsModule.PlaySound(WeaponSounds[weapon].Combat.Hit, eChar.Torso)
		VFX_Event:FireAllClients("Highlight", eChar, 0.5, Color3.fromRGB(255, 255, 255), Color3.fromRGB(37, 33, 33))
		eHum:TakeDamage(20)
	end

	return "Missed"
end

return module
