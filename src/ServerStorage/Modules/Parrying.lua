local ParryModule = {}
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Events = RS.Events
local SSModule = SS.Modules
local WeaponAnimsFolder = RS.Animations.Weapons
local VFX_Event = Events.VFX

local HelpfullModule = require(SSModule.Other.Helpful)
local Combat_Data = require(SSModule.Combat.Data.CombatData)
local IntentService = require(SSModule.Combat.IntentService)

-- Tables
local ParryAnims = Combat_Data.ParryAnims
local Success = Combat_Data.SuccessfulParry
local HyprSucess = Combat_Data.SuccessfulHyprParry

local ParryCD = {
	Hypr = {},
	Reg = {},
}

function ParryModule.CleanupForPlayer(identifier)
	ParryCD.Hypr[identifier] = nil
	ParryCD.Reg[identifier] = nil
end

function ParryModule.ParryAttempt(char, npc)
	local Identifer = Players:GetPlayerFromCharacter(char) or npc
	local hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local WeaponModel = char:FindFirstChild(currentWeapon)
	if ParryCD.Reg[Identifer] and tick() - ParryCD.Reg[Identifer] < 1.2 then
		return
	end

	if char:GetAttribute("Parrying") or char:GetAttribute("HyprParry") then
		return
	end

	if HelpfullModule.CheckForAttributes(char, true, true, false, true, true, true, true) then
		return
	end

	

	char:SetAttribute("Parrying", true)
	char:SetAttribute("Stunned", true)
	IntentService.SetIntent(char, npc, "Parry")
	
	ParryAnims[Identifer] = hum:LoadAnimation(WeaponAnimsFolder[currentWeapon].Blocking.TryParry)
	ParryAnims[Identifer]:Play()
	
	if not ParryCD.Hypr[Identifer] or tick() - ParryCD.Hypr[Identifer] >  2 then  -- Reversing the if statment to see if that works 
		char:SetAttribute("HyprParry", true)
		VFX_Event:FireAllClients("HighlightBlink", WeaponModel, Color3.new(0.980392, 0.380392, 0.003922), 0.30, 2, 0.1)		
		print(char:GetAttribute("HyprParry"))
	end
	
	
	hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed / 2.5)
	hum.JumpHeight = 0



	ParryAnims[Identifer]:GetMarkerReachedSignal("HyprParryOver"):Connect(function()
		char:SetAttribute("HyprParry", false)
		print("HYPROVER")
		print("HELLPPPPPPPP meememememememe")
		ParryCD.Hypr[Identifer] = tick()
	end)

	ParryAnims[Identifer]:GetMarkerReachedSignal("ParryOver"):Connect(function()
		char:SetAttribute("Parrying", false)
		ParryCD.Reg[Identifer] = tick()
	end)

	ParryAnims[Identifer].Ended:Connect(function()
		IntentService.SetIntent(char, npc, "None")

		if HyprSucess[Identifer] then
			HelpfullModule.ResetMobility(char)
			char:SetAttribute("Parrying", false)
			char:SetAttribute("HyprParry", false)
			char:SetAttribute("Stunned", false)
			ParryCD.Reg[Identifer] = nil
			ParryCD.Hypr[Identifer] = nil
			HyprSucess[Identifer] = nil
			return
		end
    

		if Success[Identifer] then
			HelpfullModule.ResetMobility(char)
			char:SetAttribute("Parrying", false)
			char:SetAttribute("Stunned", false)
			ParryCD.Reg[Identifer] = nil
			Success[Identifer] = nil
			return
		end

	

		HelpfullModule.ResetMobility(char)
		char:SetAttribute("Stunned", false)
	end)
end

return ParryModule
