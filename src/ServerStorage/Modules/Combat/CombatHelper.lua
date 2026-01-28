local module = {}
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer") 
local SoundService = game:GetService("SoundService") 

local Events = RS.Events
local Effects = RS.Effects
local WeaponEffects = RS.Effects.Weapons
local WeaponSounds = SoundService.SFX.Weapons
local RSModules = RS.Modules
local SSModules = SS.Modules
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local Models = RS.Models


local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local ServerCombatModule=require(SSModules.CombatModule)
local HitServiceModule = require(SSModules.HitService)
local VFX_Event = Events.VFX
local RaycastHitbox = require (SSModules.Hitboxes.RaycastHitboxV4)
local VolumeHitbox = require(SSModules.Hitboxes.VolumeHitboxes)
local WeaponsStatsModule = require(SSModules.Dictionaries.WeaponStats)
local HelpfullModule = require(SSModules.Other.Helpful)

local Connections = {
	hitStart = nil,
	HitEnd = nil,
}


local MaxCombo = 4

local function getUniqueId(char)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	return uid.Value or nil
end




function module.Attack(char)
	if not char or not char:FindFirstChild("Humanoid") then return end
	local hum = char.Humanoid
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso")
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or getUniqueId(char)
	
	
	if not HRP or not torso then return end

	if HelpfullModule.CheckForAttributes(char,true,true,true,true,true,true,true,nil) then return end

	local currentWeapon = char:GetAttribute("CurrentWeapon")


	-- Begin swing
	char:SetAttribute("Attacking", true)
	char:SetAttribute("Swing", true)

	ServerCombatModule.ChangeCombo(char)
	ServerCombatModule.stopAnims(hum)

	hum.WalkSpeed = 7
	hum.JumpHeight = 0

	local WeaponStats = WeaponsStatsModule.getStats(currentWeapon)
	local HitAnim = WeaponsAnimations[currentWeapon].Hit["Hit" .. char:GetAttribute("Combo")]
	local SwingEffect = WeaponEffects[currentWeapon].Swing["Swing" .. char:GetAttribute("Combo")]
	local SwingAnim = ServerCombatModule.getSwingAnims(char, currentWeapon)
	local playSwingAnimation = hum.Animator:LoadAnimation(SwingAnim)
	local swingReset = WeaponStats.SwingReset
	
	if Connections[Identifier] then
		for _, conn in pairs(Connections[Identifier]) do
			if conn then conn:Disconnect() end
		end
	end
	
	Connections[Identifier] = {}
	
	
	Connections[Identifier].HitStart = playSwingAnimation
		:GetMarkerReachedSignal("HitStart")
		:Connect(function()
		local HitBoxSize = WeaponStats.HitBox_Data["Combo" .. char:GetAttribute("Combo")].HitboxSize
		local HitBoxOffset = WeaponStats.HitBox_Data["Combo" .. char:GetAttribute("Combo")].HitboxOffset
		local Attachment = Instance.new("Attachment")
		Attachment.Parent = HRP
		Attachment.Name = "LightAttackHitbox"
		Attachment.WorldCFrame = HRP.CFrame * HitBoxOffset
		VolumeHitbox.NormalHitBox(HitBoxSize, Attachment, char, function(Ehum, Hit)
			HitServiceModule.Normal_Hitbox(char, currentWeapon, Ehum, Hit, HitAnim)
		end)
		
		Attachment:Destroy()
		Connections[Identifier].HitStart:Disconnect()
		Connections[Identifier].HitStart = nil
	end)


	Connections[Identifier].HitEnd=playSwingAnimation
		:GetMarkerReachedSignal("HitEnd")
		:Connect(function()
		VolumeHitbox.DestroyHitboxes(char)

		char:SetAttribute("Swing", false)

        if char:GetAttribute("Combo") == MaxCombo then 
			task.wait(1.1)
        else 
			task.wait(swingReset)
        end

		
		char:SetAttribute("Attacking", false)
		
		Connections[Identifier].HitEnd:Disconnect()
		Connections[Identifier].HitEnd = nil
	end)


	playSwingAnimation.Stopped:Connect(function()
		VolumeHitbox.DestroyHitboxes(char)

		if not char:GetAttribute("Swing") and not char:GetAttribute("IsBlocking") then 
			HelpfullModule.ResetMobility(char)
		end
	end)



	playSwingAnimation:Play()
	VFX_Event:FireAllClients("SwingEffect", SwingEffect, char)
	SoundsModule.PlaySound(WeaponSounds[currentWeapon].Combat.Swing, torso)


	if plr then VFX_Event:FireClient(plr,"CustomShake",1,2,0,.7) end
end

function module.CancelAttack(char)
	if not char then return end
	char:SetAttribute("Attacking", false)
	char:SetAttribute("Swing", false)
	ServerCombatModule.stopAnims(char.Humanoid)
	VolumeHitbox.DestroyHitboxes(char)
	HelpfullModule.ResetMobility(char)
end



return module
