local module = {}
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules

local MovementData = require(RSModules.Movement.Data)

-- Client-side prediction of stamina the server hasn't confirmed yet.
-- The replicated Stamina attribute lags the server's real deductions by a
-- round-trip, so a rapid jump chain can outrun it and false-trip the server's
-- cost gate. Gate on (lastSeen - inFlight), which is always <= the server's
-- true stamina, so we can never request a paid action the server can't afford.
local lastSeenStamina = setmetatable({}, { __mode = "k" })
local inFlightStamina = setmetatable({}, { __mode = "k" })








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



function module.CheckForAttributes(char, attack, swing, stun, ragdoll, equipped, blocking, Dodging, Sprinting, EXSprint)
	local attacking = char:GetAttribute("Attacking")
	local swinging = char:GetAttribute("Swing")
	local stunned = char:GetAttribute("Stunned")
	local isEquipped = char:GetAttribute("Equipped")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	local isBlocking = char:GetAttribute("IsBlocking")
	local isDodging = char:GetAttribute("Dodging")
	local isSprinting = char:GetAttribute("Sprinting")
	local isEXSprinting = char:GetAttribute("IsEXSprinting")

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
	if EXSprint and isEXSprinting then
		stop = true
	end
	return stop
end

function module.CheckStamina(char, action)
	local Stamina = char:GetAttribute("Stamina")
	local Fail = false

	if lastSeenStamina[char] ~= Stamina then
		lastSeenStamina[char] = Stamina
		inFlightStamina[char] = 0
	end

	if action == "ExSprint" then
        local drain = 5
        if Stamina >= drain then
            return false -- Did not fail, they can sprint!
        else
            return true -- Failed, stop the sprint
        end
    end




	if action == "Dodge" then
		if Stamina >= 20 then
			Fail = false
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
			return Fail
		else
			Fail = true
			return Fail
		end
	end
	
	if action == "DoubleJump" then
		local cost = MovementData.Data.DoubleJumpStaminaCost
		local available = lastSeenStamina[char] - (inFlightStamina[char] or 0)
		if available >= cost then
			inFlightStamina[char] = (inFlightStamina[char] or 0) + cost
			Fail = false
			return Fail
		else
			Fail = true
			return Fail
		end
	end

	if action == "Climb" then
		local cost = MovementData.Data.ClimbStaminaCost
		local available = lastSeenStamina[char] - (inFlightStamina[char] or 0)
		if available >= cost then
			inFlightStamina[char] = (inFlightStamina[char] or 0) + cost
			Fail = false
			return Fail
		else
			print(char, "Did not have enough stamina to climb")
			Fail = true
			return Fail
		end
	end

	return Fail
end










return module
