local module = {}
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules
local Events = RS.Events
local StaminaEvent = Events.Stamina

local WeaponsModels = RS.Models.Weapons

local BlockingModule = require(script.Parent.Parent.BlockModule)
local Combat_Data = require(SSModules.Combat.Data.CombatData)

-- Tables
local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local EquipDebounce = Combat_Data.EquipDebounce
local WeaponsWeld = RS.Welds.Weapons

-- Constants
local k = 0.02 -- This is the rate of the drop off for DEX Crit Rate Scaling
local BaseCritRate = 0.15 -- Base Crit Rate %
local MaxCritRate = 0.45 -- Max Crit Rate % given by DEX Points


local MaxdownTime = 22  
local Reduction_Range = 2
local K_Time =  15 -- "the half life constant"

function module.DamageDealer(char :Model, damage)
	local hum = char:FindFirstChildOfClass("Humanoid") ::Humanoid
    if not hum or not char then return end 
	
	if hum.Health > damage then
		hum:TakeDamage(damage) -- Take the damage
	else
		hum.Health = 1
		-- This is where the knockdown logic would go
		local END = char:GetAttribute("END") or 1 
		local downtime = MaxdownTime - (Reduction_Range * (END/ (END + K_Time)))
		module.Ragdoll(char,downtime)
		char:SetAttribute("Downed", true)

		-- TODO: Create a functiuon that creates the prox prompt for downed enemies 
		task.delay(downtime, function()
			char:SetAttribute("Downed", false)
		end)
	end
end

function module.ChangeWeapon(plr, char, torso)
	char:SetAttribute("Equipped", false)
	char:SetAttribute("Combo", 1)
	char:SetAttribute("Stunned", false)
	char:SetAttribute("Swing", false)
	char:SetAttribute("Attacking", false)
	char:SetAttribute("iframes", false)
	char:SetAttribute("IsBlocking", false)
	char:SetAttribute("Mode1", false)
	char:SetAttribute("Mode2", false)
	char:SetAttribute("Parrying", false)
	char:SetAttribute("Sprinting", false)

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	local Weapon = WeaponsModels[currentWeapon]:clone()

	Weapon.Parent = char

	if Weapon:FindFirstChild("SecondWeapon", true) then
		print(Weapon[currentWeapon].SecondWeapon)
		print("LetsWeld")
		Weapon[currentWeapon].SecondWeld.Part0 = char["Left Arm"]
		Weapon[currentWeapon].SecondWeld.Part1 = Weapon[currentWeapon].SecondWeapon
	end

	
	Welds[plr] = WeaponsWeld[currentWeapon].IdleWeaponWeld:Clone()

	Welds[plr].Parent = torso
	Welds[plr].Part0 = torso
	Welds[plr].Part1 = Weapon[currentWeapon]

	if module.CheckForAttributes(char, true, true, true, true, nil, true, true, true) then
		return
	end

	if EquipAnims[plr] then
		EquipAnims[plr]:Stop()
	end
	if IdleAnims[plr] then
		IdleAnims[plr]:Stop()
	end
	if UnEquipAnims[plr] then
		UnEquipAnims[plr]:Stop()
	end
	if BlockingAnims[plr] then
		BlockingAnims[plr]:Stop()
	end

	EquipDebounce[plr] = false
end

function module.CheckInFront(char, enemyChar)
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

function module.CheckBehind(char, enemyChar)
	local enemyHRP = enemyChar.HumanoidRootPart
	local attackDirection = (char.HumanoidRootPart.Position - enemyHRP.Position).Unit
	local backDirection = -enemyHRP.CFrame.LookVector
	local direction = math.acos(attackDirection:Dot(backDirection)) < math.rad(90)

	if not direction then
		print("Not behind")
		return false
	else
		print("behind")
		return true
	end
end

function module.ResetMobility(char)
	local hum = char.Humanoid
	if char:GetAttribute("IsLow") and char:GetAttribute("InCombat") then
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 1.25
		else
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed / 2
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight / 2
		end
	else
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 2
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		else
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		end
	end
end

function module.CheckForStatus(
    eChar,
    char,
    npc,
    blockingDamage,
    hitPos,
    CheckForBlocking,
    CheckForParrying,
    checkForDodging,
    checkForHyprParry
)
    if eChar.Humanoid.Health <= 0 or eChar:GetAttribute("Iframes") then
        return true, "HitLanded"
    end

    local stop = false
    local Result = "HitLanded"

    if checkForHyprParry and not stop then
        if eChar:GetAttribute("HyprParry") and module.CheckInFront(char, eChar) then
            Result = BlockingModule.HyprParrying(char, eChar, hitPos, npc)
            stop = true
        end
    end

    if CheckForParrying and not stop then
        if eChar:GetAttribute("Parrying") and module.CheckInFront(char, eChar) then
            Result = BlockingModule.Parrying(char, eChar, hitPos, npc)
            stop = true
        end
    end

    if CheckForBlocking and not stop then
        if eChar:GetAttribute("IsBlocking") and module.CheckInFront(char, eChar) then
            Result = BlockingModule.Blocking(char, eChar, blockingDamage, hitPos)
            stop = true
        end
    end

    if checkForDodging and not stop then
        if eChar:GetAttribute("Dodging") then
            BlockingModule.Dodging(char, eChar, hitPos)
            stop = true
        end
    end

    return stop, Result
end




function module.CheckForAttributes(char, attack, swing, stun, ragdoll, equipped, blocking, Dodging, Sprinting)
	local attacking = char:GetAttribute("Attacking")
	local swinging = char:GetAttribute("Swing")
	local stunned = char:GetAttribute("Stunned")
	local isEquipped = char:GetAttribute("Equipped")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	local isBlocking = char:GetAttribute("IsBlocking")
	local isDodging = char:GetAttribute("Dodging")
	local isSprinting = char:GetAttribute("Sprinting")

	local stop = false

	if attacking and attack then
		stop = true
	end
	if swinging and swing then
		stop = true
	end
	if stunned and stun then
		stop = true
	end
	if isRagdoll and ragdoll then
		stop = true
	end
	if equipped and not isEquipped then
		stop = true
	end
	if blocking and isBlocking then
		stop = true
	end
	if Dodging and isDodging then
		stop = true
	end
	if Sprinting and isSprinting then
		stop = true
	end
	return stop
end

function module.CalculateCrit(DEX_Points)
	local roll = math.random(1, 100)

	local CritChance = BaseCritRate + (MaxCritRate - BaseCritRate) * (1 - math.exp(-k * DEX_Points))
	CritChance = CritChance * 100

	if roll <= CritChance then
		return true
	else
		return false
	end
end

function module.Ragdoll(char, ragdollTime)
	task.spawn(function()
		print("Ragdoll")
		if char:GetAttribute("IsRagdoll") then
			return
		end

		char:SetAttribute("IsRagdoll", true)
		task.wait(ragdollTime)
		char:SetAttribute("IsRagdoll", false)
		char:SetAttribute("Iframes", true)
		task.wait(0.6)
		char:SetAttribute("Iframes", false)
	end)
end
function module.ManageStamina(char, action)
    local Stamina = char:GetAttribute("Stamina")
    local Fail = false
    local plr = Players:GetPlayerFromCharacter(char)

    if action == "Dodge" then
        if Stamina >= 20 then
            Fail = false
            char:SetAttribute("Stamina", (Stamina - 20))
			print(char:GetAttribute("Stamina"))
            return Fail
        else
            Fail = true
            print(char, "Did not have enough stamina to perform a dodge")
            return Fail
        end
    end

    if action == "Swing" then
        if Stamina >= 2 then
            Fail = false
            char:SetAttribute("Stamina", (Stamina - 2))
            return Fail
        else
            Fail = true
            if plr then
                StaminaEvent:FireClient(plr, 10)
            end
            return Fail
        end
    end

    if action == "Climb" then
        if Stamina >= 10 then
            Fail = false
            char:SetAttribute("Stamina", (Stamina - 10))
            return Fail
        else
            print(char, "Did not have enough stamina to climb")
            Fail = true
            return Fail
        end
    end

    -- Add ExSprint Tick Cost
    if action == "ExSprint" then
        if Stamina >= 5 then -- Change 5 to your preferred drain amount per tick
            Fail = false
            char:SetAttribute("Stamina", (Stamina - 5))
            return Fail
        else
            Fail = true
            return Fail
        end
    end

    return Fail
end

function module.RefundStamina(char, action)
	local Stamina = char:GetAttribute("Stamina")


	if action == "DodgeCancel" then
		char:SetAttribute("Stamina", (Stamina + 20))
	end

	if action == "Swing" then
		char:SetAttribute("Stamina", (Stamina + 2))
	end

	if action == "ExSprint" then
		local drain = 5
		while Stamina >=  drain do
			char:SetAttribute("Stamina",(Stamina - 5))
		end
	end

end

function module.ManageMana(char, Skill)
	-- This is for when I start the spell and skill system fully
end

return module
