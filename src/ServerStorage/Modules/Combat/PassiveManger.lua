local PassiveManger = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local Events = RS.Events
local UI_Update = Events.UI_Update
local VFX_Event = Events.VFX
local Movement_Event = Events.Movement

-- Maths Contants
local p = 2.0 -- Soft Cap Exponent for Crit Dmg
local BaseCritDmg = 1.5 -- Base Crit Dmg Multiplier
local MaxBonus = 1.7 -- Max Crit Dmg Multiplier

local CritDropoffRate = 0.02
local BaseCritRate = 0.15 -- In %
local MaxCritRate = 0.45 -- Max Crit from DEX

local MaxdownTime = 22
local Reduction_Range = 2
local K_Time = 15 -- "the half life constant"

local function CalcCrit(DEX: number)
	local roll = math.random(1, 100)

	local CritChance = BaseCritRate + (MaxCritRate - BaseCritRate) * (1 - math.exp(-CritDropoffRate * DEX))
	CritChance = CritChance * 100

	if roll <= CritChance then
		return true
	else
		return false
	end
end

local function Ragdoll(char, ragtime)
	task.spawn(function()
		if char:GetAttribute("IsRagdoll") then
			return
		end

		char:SetAttribute("IsRagdoll", true)
		task.wait(ragtime)
		char:SetAttribute("IsRagdoll", false)
		char:SetAttribute("iframes", true)
		task.wait(0.6)
		char:SetAttribute("iframes", false)
	end)
end

local function DamageDealer(char, damage)
	local hum = char:FindFirstChildOfClass("Humanoid") :: Humanoid
	if not hum or not char then
		return
	end

	if hum.Health > damage then
		hum:TakeDamage(damage) -- Take the damage
	else
		hum.Health = 1
		-- This is where the knockdown logic would go
		local END = char:GetAttribute("END") or 1
		local downtime = MaxdownTime - (Reduction_Range * (END / (END + K_Time)))
		Ragdoll(char, downtime)
		char:SetAttribute("Downed", true)
		task.delay(downtime, function()
			char:SetAttribute("Downed", false)
		end)
	end
end

function PassiveManger.M1LandedPassive(Attacker, Defender, damage, STAT_POINTS) -- This refers to when a light attack lands on char
	--[[
    Attacker - the enemy character that landed the attack
    Defender - the character that got hit
    damage - the damage that was dealt from base sclaing
    Stats - the stats of the character that landed the attack
    --]]

	local DEX_Points = STAT_POINTS.DEX
	local AttackerElement = Attacker:GetAttribute("Element")
	local DefenderElement = Defender:GetAttribute("Element")
	local Attacker_Second_ModeCheck = Attacker:GetAttribute("Mode2")
	local Defender_Second_ModeCheck = Defender:GetAttribute("Mode2")
	local Attacker_plr = game.Players:GetPlayerFromCharacter(Attacker)
	local Defender_plr = game.Players:GetPlayerFromCharacter(Defender)
	local DamageModifiers = 10
	local TotalRes = 0.25
	local isCrit
	local CritDmgMult = BaseCritDmg + (MaxBonus - BaseCritDmg) * (DEX_Points / 99) ^ p
	local Attack_Dodged = false
	local damageAlreadydealt = false
	local Profile

	local MultipliedDamage = damage * (1 + DamageModifiers / 100)
	MultipliedDamage = MultipliedDamage * (1 - TotalRes)

	if Attacker:GetAttribute("CritTest") then
		isCrit = true
	else
		isCrit = CalcCrit(DEX_Points)
		print(isCrit)
	end

	if isCrit then
		MultipliedDamage = MultipliedDamage * CritDmgMult
	end

	if DefenderElement == "Bone" then
		print("If there was a passive for mode 1 it would be here")
		if Defender_Second_ModeCheck then
			local TargetHum = Defender.Humanoid
			local DodgeCounter = Defender:GetAttribute("Dodges")

			if DodgeCounter > 0 then
				MultipliedDamage = 0
				Defender:SetAttribute("Dodges", math.max(0, DodgeCounter - 1))
				Defender:SetAttribute("InCombat", true)
				DamageDealer(Defender, MultipliedDamage)
				Attack_Dodged = true
				damageAlreadydealt = true
			else
				DamageDealer(Defender, MultipliedDamage)
				damageAlreadydealt = true
			end
		end
	end

	if AttackerElement == "Bone" then
		print("If there was a passive for mode 1 it would be here")
		if Attacker_Second_ModeCheck and not Attack_Dodged then
			local TargetHum = Defender.Humanoid
			local Karma = Defender:GetAttribute("Karma")
			Defender:SetAttribute("Karma", math.min(Karma + 5, 50))
			local totalDamage = 0
			local tickRate = 3 -- Stage 1

			if Karma > 33 then
				tickRate = 1 -- Stage 3
			elseif Karma > 16 then
				tickRate = 2 -- Stage 2
			end

			local dotDamage = 3 -- Damage per tick
			local karmaDecayRate = 2 -- Karma decreases over time

			task.spawn(function()
				while totalDamage < MultipliedDamage and Karma > 0 and TargetHum and TargetHum.Health > 0 do
					Karma = Defender:GetAttribute("Karma")
					if Karma <= 0 then
						break
					end
					DamageDealer(Defender, dotDamage)
					totalDamage += dotDamage

					Karma = math.max(0, Karma - (karmaDecayRate * tickRate))
					Defender:SetAttribute("Karma", Karma)

					task.wait(tickRate)

					if totalDamage >= MultipliedDamage or TargetHum.Health <= 0 then
						break
					end
				end
				damageAlreadydealt = true
				if Defender_plr then
					UI_Update:FireClient(
						Defender_plr,
						totalDamage,
						TargetHum.Health,
						TargetHum.MaxHealth,
						MultipliedDamage
					)
				end
			end)
		end
	end

	if AttackerElement == "Astral" then
		print("If there was a passive for mode 1 it would be here")
		if Attacker_Second_ModeCheck then
			local SPT = STAT_POINTS.SPT
			local SPT_Bonus = 1
			local SPTScalingFactor = 0.01
			SPT_Bonus = 1 + (SPT * SPTScalingFactor)

			damage = damage * SPT_Bonus

			MultipliedDamage = damage * (1 + DamageModifiers / 100)
			MultipliedDamage = MultipliedDamage * (1 - TotalRes)

			if Attacker:GetAttribute("CritTest") then
				isCrit = true
			else
				isCrit = CalcCrit(DEX_Points)
				print(isCrit)
			end

			if isCrit then
				MultipliedDamage = MultipliedDamage * CritDmgMult
			end
		end
	end

	return MultipliedDamage, isCrit, damageAlreadydealt
end

function PassiveManger.DefensivePassive(char, damage) -- This refers to when char blocks an attack
end

function PassiveManger.DodgeLanded(char) -- As the name impled this is when a char succesfully dodged something
end

function PassiveManger.BackStabPassive(char, damage) -- This refers to when char lands a backstab attack
end

function PassiveManger.OnSkillLanded(attacker, defender, damage, skill) -- this
end

return PassiveManger
