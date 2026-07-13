local module = {}
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Events = RS.Events
local WeaponEffects = RS.Effects.Weapons
local WeaponSounds = SoundService.SFX.Weapons
local SSModules = SS.Modules
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local ServerCombatModule = require(SSModules.CombatModule)
local HitServiceModule = require(SSModules.HitService)
local MuchachoHitbox = require(SSModules.Hitboxes.MuchachoHitbox)
local WeaponsStatsModule = require(SSModules.Dictionaries.WeaponStats)
local HelpfullModule = require(SSModules.Other.Helpful)
local Combat_Data = require(ServerStorage.Modules.Combat.Data.CombatData)

local VFX_Event: RemoteEvent = Events.VFX
local MovementEvent: RemoteEvent = Events.Movement

local Connections = {}

local MaxCombo = 4

local FeintFlags = {}
local BlinkCooldowns = {}
local HitBoxes = {}

function module.Attack(char, npc)
	if not char or not char:FindFirstChild("Humanoid") then
		return
	end
	local hum = char.Humanoid
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso")
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc

	if not HRP or not torso then
		return
	end

	local RevengeFlag = char:GetAttribute("CanRevenge")

	if RevengeFlag then
		print("I crave revenge")
		module.RevengeCounter(char, npc)
		return
	end

	if HelpfullModule.CheckForAttributes(char, true, true, true, true, true, true, true, nil) then
		return
	end
	if HelpfullModule.ManageStamina(char, "Swing") then
		return
	end

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	-- Begin swing
	char:SetAttribute("Attacking", true)
	char:SetAttribute("Swing", true)

	ServerCombatModule.ChangeCombo(char)
	ServerCombatModule.stopAnims(hum)

	hum.WalkSpeed = 16
	hum.JumpHeight = 0

	local WeaponStats = WeaponsStatsModule.getStats(currentWeapon)
	local HitAnim = WeaponsAnimations[currentWeapon].Hit["Hit" .. char:GetAttribute("Combo")]
	local SwingEffect = WeaponEffects[currentWeapon].Swing["Swing" .. char:GetAttribute("Combo")]
	local SwingAnim = ServerCombatModule.getSwingAnims(char, currentWeapon)
	local playSwingAnimation = hum.Animator:LoadAnimation(SwingAnim)
	local swingReset = WeaponStats.SwingReset

	-- Disconnect any lingering connections from a previous swing
	if Connections[Identifier] then
		for _, conn in pairs(Connections[Identifier]) do
			if conn then
				conn:Disconnect()
			end
		end
	end

	Connections[Identifier] = {}

	-- Capture connections in locals so each handler always disconnects itself,
	-- not whatever the shared table holds at the time of firing (stale closure fix)
	local hitStartConn, hitEndConn

	local function cleanupSwing()
		if hitStartConn then
			hitStartConn:Disconnect()
			hitStartConn = nil
			Connections[Identifier].HitStart = nil
		end
		if hitEndConn then
			hitEndConn:Disconnect()
			hitEndConn = nil
			Connections[Identifier].HitEnd = nil
		end
		HelpfullModule.ResetMobility(char)
		if HitBoxes[Identifier] then
		pcall(function()
			HitBoxes[Identifier]:Stop()
		end)
		HitBoxes[Identifier] = nil -- Clear reference so it can't be stopped again
	end
		char:SetAttribute("Attacking", false)
		char:SetAttribute("Swing", false)
		FeintFlags[Identifier] = false
	end

	hitStartConn = playSwingAnimation:GetMarkerReachedSignal("HitStart"):Connect(function()
		HitBoxes[Identifier] = MuchachoHitbox.CreateHitbox()
		HitBoxes[Identifier].Size = WeaponStats.HitboxSize
		HitBoxes[Identifier].CFrame = HRP
		HitBoxes[Identifier].AutoDestroy = false
		HitBoxes[Identifier].VelocityPrediction = true
		HitBoxes[Identifier].Visualizer = true
		HitBoxes[Identifier].Offset = WeaponStats.HitboxOffset
		HitBoxes[Identifier].DetectionMode = "HitOnce"

		local params = OverlapParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        HitBoxes[Identifier].OverlapParams = params

        HitBoxes[Identifier]:Start()


		HitBoxes[Identifier].Touched:Connect(function(hit, humanoid)
			local Result = HitServiceModule.Normal_Hitbox(char, currentWeapon, humanoid, npc, hit, HitAnim)
			print(Result)
		end)

		hitStartConn:Disconnect()
		hitStartConn = nil
		Connections[Identifier].HitStart = nil
		FeintFlags[Identifier] = true
	end)

	hitEndConn = playSwingAnimation:GetMarkerReachedSignal("HitEnd"):Connect(function()
		if HitBoxes[Identifier] then
			pcall(function()
				HitBoxes[Identifier]:Stop()
			end)
			HitBoxes[Identifier] = nil -- Clear reference so it can't be stopped again
		end
		char:SetAttribute("Swing", false)
	

		if char:GetAttribute("Combo") == MaxCombo then
			task.wait(swingReset + 0.5)
		else
			task.wait(swingReset)
		end

		char:SetAttribute("Attacking", false)
		if hitEndConn then
			hitEndConn:Disconnect()
		hitEndConn = nil
		end

		
		Connections[Identifier].HitEnd = nil
		FeintFlags[Identifier] = false
	end)

	Connections[Identifier].HitStart = hitStartConn
	Connections[Identifier].HitEnd = hitEndConn

	-- Stopped fires whenever the animation ends for ANY reason (natural finish, stopAnims,
	-- or a transformation interrupting mid-swing). cleanupSwing safely no-ops the parts
	-- that HitEnd already handled.
	playSwingAnimation.Stopped:Connect(function()
		cleanupSwing()
	end)

	playSwingAnimation:Play()
	VFX_Event:FireAllClients("SwingEffect", SwingEffect, char)
	SoundsModule.PlaySound(WeaponSounds[currentWeapon].Combat.Swing, torso)

	if plr then
		VFX_Event:FireClient(plr, "CustomShake", 1, 2, 0, 0.7)
	end
end

function module.CancelAttack(char, npc)
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	local hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local SwingEffect = WeaponEffects[currentWeapon].Swing["Swing" .. char:GetAttribute("Combo")]

	if FeintFlags[Identifier] or char:GetAttribute("Swing") == false then
		return
	end

	char:SetAttribute("Attacking", false)
	char:SetAttribute("Swing", false)
	ServerCombatModule.stopAnims(hum)
	if HitBoxes[Identifier] then
		pcall(function()
			HitBoxes[Identifier]:Stop()
		end)
		HitBoxes[Identifier] = nil 
	end
	HelpfullModule.ResetMobility(char)
	VFX_Event:FireAllClients("DestroyVFX", char, SwingEffect)
	
	local sound = char:FindFirstChild("Swing",true)
	if sound then
		sound:Destroy()
	end
end

function module.RevengeCounter(char: Model, npc)
	local tag = char:FindFirstChild("RevengeTarget")
	if not tag then
		return
	end

	char:SetAttribute("CanRevenge", false)
	char:SetAttribute("Iframes", true)

	local echar = tag.Value
	if not echar then
		return
	end

	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	if Combat_Data.ActiveRecoveryTracks[Identifier] then
		Combat_Data.ActiveRecoveryTracks[Identifier]:Stop(0.1)
		Combat_Data.ActiveRecoveryTracks[Identifier] = nil
	end

	local EHRP = echar:FindFirstChild("HumanoidRootPart")
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if not EHRP or not HRP or not hum then
		return
	end

	for i, item in pairs(char:GetDescendants()) do
		if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
			item.CanCollide = false
		end
	end

	HRP.AssemblyLinearVelocity = Vector3.zero
	HRP.AssemblyAngularVelocity = Vector3.zero

	for _, oldForce in ipairs(HRP:GetChildren()) do
		if oldForce:IsA("LinearVelocity") or oldForce:IsA("VectorForce") then
			oldForce:Destroy()
		end
	end

	local RevengeAnim = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Combat.RevengeCounter)
	RevengeAnim:Play()

	VFX_Event:FireAllClients("HyprIndicator", HRP.CFrame)

	-- SERVER-SIDE HITBOX CREATION HELPER
	local function TriggerRevengeHitbox()
		if not HRP.Parent or not EHRP.Parent then
			return
		end

		HRP.AssemblyLinearVelocity = Vector3.zero
		HRP.AssemblyAngularVelocity = Vector3.zero

		local distanceVector = EHRP.Position - HRP.Position
		local flatEnemyPos = Vector3.new(EHRP.Position.X, HRP.Position.Y, EHRP.Position.Z)
		local targetPosition = flatEnemyPos - (distanceVector.Unit * 3)
		HRP.CFrame = CFrame.lookAt(targetPosition, flatEnemyPos)

		for i, item in pairs(char:GetDescendants()) do
			if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
				item.CanCollide = true
			end
		end

		print("We got there safely")

		local size = Vector3.new(5, 5, 5)
		local comboValue = char:GetAttribute("Combo") :: number
		local HitAnim = WeaponsAnimations[currentWeapon].Hit["Hit" .. comboValue]

		local RevengeHitbox = MuchachoHitbox.CreateHitbox()
		RevengeHitbox.Size = size
		RevengeHitbox.CFrame = HRP.CFrame
		RevengeHitbox.Offset = CFrame.new(0,-3,0)
		local params = OverlapParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
		RevengeHitbox.OverlapParams = params

		RevengeHitbox:Start()

		RevengeHitbox.Touched:Connect(function(hit, humanoid)
			return HitServiceModule.Normal_Hitbox(char, currentWeapon, humanoid, npc, hit, HitAnim)
		end)

		task.wait(0.2) -- would replace with a anim event 
		if RevengeHitbox then
		pcall(function()
			RevengeHitbox:Stop()
		end)
		RevengeHitbox= nil 
	end


	end

	if not plr then
		-- NPC PATH: Run server physics movers
		local att = HRP:FindFirstChild("RevengeAtt") or Instance.new("Attachment", HRP)
		att.Name = "RevengeAtt"

		local lv = Instance.new("LinearVelocity", HRP)
		lv.Name = "RevengeVelocity"
		lv.Attachment0 = att
		lv.MaxForce = math.huge

		local conn
		local startTime = os.clock()

		conn = RunService.Heartbeat:Connect(function()
			if not echar.Parent or not EHRP.Parent or not char.Parent or not HRP.Parent then
				conn:Disconnect()
				lv:Destroy()
				return
			end

			local distanceVector = EHRP.Position - HRP.Position
			local dist = distanceVector.Magnitude

			if dist <= 3.5 or (os.clock() - startTime) >= 0.2 then
				conn:Disconnect()
				lv:Destroy()
				TriggerRevengeHitbox()
				return
			end

			lv.VectorVelocity = distanceVector.Unit * 180
		end)
	else
		-- PLAYER PATH: Tell client to execute movement physics, server waits to pop hitbox
		MovementEvent:FireClient(plr, "RevengeCounter", char, echar)

		task.delay(0.2, function()
			TriggerRevengeHitbox()
			char:SetAttribute("Iframes", false)
		end)

		
	end
end
function module.Blink(char, npc, target)
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	if BlinkCooldowns[Identifier] and tick() - BlinkCooldowns[Identifier] < 0.5 then
		return
	end
	BlinkCooldowns[Identifier] = tick()

	local HRP = char:FindFirstChild("HumanoidRootPart")
	local Hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if not HRP or not Hum then
		return
	end
	local Hit2nim = WeaponsAnimations[currentWeapon].Hit["Hit" .. char:GetAttribute("Combo")]

	HRP.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)

	--local BlinkAnim = Hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Blink):Play()
	--SoundsModule.PlaySound(WeaponSounds[currentWeapon].Combat.Blink, HRP) will uncomment when blink sound is added
	local Size = Vector3.new(5, 5, 5)
	local BlinkHitbox = MuchachoHitbox.CreateHitbox()
	BlinkHitbox.CFrame = HRP
	BlinkHitbox.Size = Size
	BlinkHitbox.Offset =  CFrame.new(0, -2, 0)
	local params = OverlapParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
	BlinkHitbox.DetectionMode = "HitOnce"
	BlinkHitbox:Start()

	BlinkHitbox.Touched:Connect(function(hit, humanoid)
		HitServiceModule.Blink_Hitbox(char, currentWeapon, humanoid, npc, hit, Hit2nim)
	end)

	task.delay(0.5, function() -- would replace with anim event when added so its actually possbile to parry it
		if BlinkHitbox then
		pcall(function()
			BlinkHitbox:Stop()
		end)
		BlinkHitbox= nil 
		end
	end)
end

return module
