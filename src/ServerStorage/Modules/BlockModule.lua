 local module = {}

local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local Events = RS.Events
local RSModules = RS.Modules
local SSModule = SS.Modules
local WeaponSounds = SoundService.SFX.Weapons
local WeaponAnimsFolder = RS.Animations.Weapons


local VFX_Event = Events.VFX


local SoundsModule = require(RSModules.Combat.SoundsModule)
local ServerCombatModule = require(SSModule.CombatModule)
local WeaponStatsModule =require(SSModule.Weapons.WeaponStats)
local StunHandler = require(SSModule.Other.StunHandlerV2)




function module.Parrying(char,eChar,hitPos)
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg
	char:SetAttribute("Blocking",char:GetAttribute("Blocking")+ BlockDmg)
	eChar:SetAttribute("Blocking",eChar:GetAttribute("Blocking")- BlockDmg)
	eChar:SetAttribute("InCombat",true)
	
	if eChar:GetAttribute("Blocking") < 0 then eChar:SetAttribute("Blocking",0) end

	if	char:GetAttribute("Blocking")>= 100 then
		module.GuardBreak(char)
		return
	end

	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Parry, hitPos,3)
	SoundsModule.PlaySound(WeaponSounds[eChar:GetAttribute("CurrentWeapon")].Blocking.Parry,eChar.Torso)
	
	ServerCombatModule.stopAnims(char.Humanoid)
	
	char.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GotParried):Play()
	eChar:SetAttribute("ParryCD",false)
	local plr = players:GetPlayerFromCharacter(char)
	if plr then VFX_Event:FireClient(plr, "CustomShake", 4,8,0,1.2) end
	
	StunHandler.Stun(char.Humanoid,1.2,5,0)
	

end






function module.GuardBreak(char)
	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.GuardBreak, char.HumanoidRootPart.CFrame,3)
	
	VFX_Event:FireAllClients("Highlight",char,2,Color3.fromRGB(255, 255, 0),Color3.fromRGB(170, 170, 0))
	
	ServerCombatModule.stopAnims(char.Humanoid)
	
	char.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak):Play()
	
	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak,char.Torso)
	
	char:SetAttribute("Blocking",0)
	char:SetAttribute("IsBlocking",false)
	
	
	local plr = players:GetPlayerFromCharacter(char)
	if plr then VFX_Event:FireClient(plr, "CustomShake", 6,12,0,2) end
	
	StunHandler.Stun(char.Humanoid,2)
end


function module.Blocking(enemyChar,damage,hitPos)
	if enemyChar:GetAttribute("Blocking") <= 100 then
		local currentWeapon = enemyChar:GetAttribute("CurrentWeapon")
		local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg
		
		enemyChar:SetAttribute("Blocking", enemyChar:GetAttribute("Blocking") + BlockDmg)
		enemyChar:SetAttribute("InCombat",true)
		
		if enemyChar:GetAttribute("Blocking") >= 100 then
			module.GuardBreak(enemyChar)
			return
		end
		
		VFX_Event:FireAllClients("Highlight",enemyChar,.5,Color3.fromRGB(255, 255, 0),Color3.fromRGB(255, 255, 0))
		
		VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Block, hitPos,3)
		
		SoundsModule.PlaySound(WeaponSounds[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked,enemyChar.Torso)
		
		enemyChar.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked):Play()
		
		
		
	end
end



return module
