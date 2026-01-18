local Bone = {}
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local SSModules = SS.Modules


local Combat_Data = require(SSModules.Combat.Data.CombatData)
local HelpfullModule = require(SSModules.Other.Helpful)


local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsModels = RS.Models.Weapons
local WeaponsWeld = RS.Welds






local function getUniqueId(char)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	return uid.Value or nil
end

function Bone.DodgeRandomTP(Target, Attacker)
	if not Target or not Target:IsA("Model") then return end
	if not Attacker or not Attacker:IsA("Model") then return end

	local targetRoot = Target:FindFirstChild("HumanoidRootPart")
	local attackerRoot = Attacker:FindFirstChild("HumanoidRootPart")
	if not targetRoot or not attackerRoot then return end

	-- Settings
	local MIN_RADIUS = 20 -- Minimum distance from attacker (no-spawn zone)
	local MAX_RADIUS = 50 -- Maximum teleport distance


	local humanoid = Target:FindFirstChildOfClass("Humanoid")
	if humanoid then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end


	local originalParts = {}
	for _, part in ipairs(Target:GetDescendants()) do
		if part:IsA("BasePart") and part:IsDescendantOf(Target) then
			table.insert(originalParts, {
				Name = part.Name,
				CFrame = part.CFrame,
				Size = part.Size,
			})
		end
	end


	for _, data in ipairs(originalParts) do
		local clone = Instance.new("Part")
		clone.Name = "AfterImagePart"
		clone.Anchored = true
		clone.CanCollide = false
		clone.Color = Color3.new(1, 1, 1)
		clone.Material = Enum.Material.SmoothPlastic
		clone.Transparency = 0
		clone.Size = data.Size
		clone.CFrame = data.CFrame
		clone.Parent = workspace

		local yOffset = math.random(2, 5)
		local rotX = math.rad(math.random(-90, 90))
		local rotY = math.rad(math.random(-180, 180))
		local rotZ = math.rad(math.random(-90, 90))
		local tweenTime = math.random(15, 35) / 100

		local goal = {
			CFrame = data.CFrame * CFrame.new(0, yOffset, 0) * CFrame.Angles(rotX, rotY, rotZ),
			Transparency = 1
		}

		local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tween = TweenService:Create(clone, tweenInfo, goal)
		tween:Play()
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
	end

	
	local function getValidPosition()
		for _ = 1, 10 do
			local angle = math.random() * 2 * math.pi
			local distance = math.random(MIN_RADIUS, MAX_RADIUS)
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance
			local newPos = attackerRoot.Position + offset
			return Vector3.new(newPos.X, targetRoot.Position.Y, newPos.Z)
		end
		return targetRoot.Position -- fallback
	end

	targetRoot.CFrame = CFrame.new(getValidPosition())
end


local Connections = {}
local Weapon_SwapAnimation = {}
local WeaponCounter = {}
local DidSwap = {}
local WeaponArsenal = {
	"Tooth_And_Nail",
	"Judgement",
	"Fang",
	"DrakeFang",
	"Glock,"
}




local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local IdleAnims = Combat_Data.IdleAnims
local EquipDebounce = Combat_Data.EquipDebounce



-- Optimized function to apply DoT
function Bone.applyKarmaDot(targetHumanoid, initialKarma, baseDamage)
	if not targetHumanoid or not targetHumanoid.Parent then return end

	local karma = initialKarma
	local totalDamage = 0
	local tickRate = 3  -- Default tick rate (Stage 1)

	if karma > 33 then
		tickRate = 1  -- Stage 3
	elseif karma > 16 then
		tickRate = 2  -- Stage 2
	end

	local dotDamage = 3  -- Damage per tick
	local maxKarma = 50
	local karmaDecayRate = 2  -- Karma decreases over time

	
	task.spawn(function()
		while totalDamage < baseDamage and karma > 0 and targetHumanoid and targetHumanoid.Health > 0 do
			-- Apply damage
			targetHumanoid:TakeDamage(dotDamage)
			totalDamage += dotDamage

			-- Reduce karma over time
			karma = math.max(0, karma - (karmaDecayRate * tickRate))

			task.wait(tickRate)

			-- Stop early if needed
			if totalDamage >= baseDamage or targetHumanoid.Health <= 0 then
				break
			end
		end
	end)

	-- Return final values
	return totalDamage
end

local function Mode1_R(char)
	local plr = game.Players:GetPlayerFromCharacter(char)
	local hum = char.humanoid
	local torso = char:FindFirstChild("Torso")
	local rightArm = char:FindFirstChild("Right Arm")
	
	local Identifier = plr or getUniqueId(char)
	if not Identifier then return end
	if EquipDebounce[Identifier] then return end
	
	
	if WeaponCounter[Identifier] == nil then
		WeaponCounter[Identifier] = 1
	end
	
	if Connections[Identifier] then
		Connections[Identifier]:Disconnect()
	end
	
	local CharWeaponCounter = WeaponCounter[Identifier]
	local TargetWeapon = WeaponArsenal[CharWeaponCounter]
	
	print(CharWeaponCounter)
	print(TargetWeapon)
	
	EquipDebounce[Identifier] = true
	char:SetAttribute("IsTransforming", true)
	
	Weapon_SwapAnimation[Identifier] = hum:LoadAnimation(WeaponsAnimations.Transformations.Bone.WeaponSwap)
	
	Connections[Identifier]= Weapon_SwapAnimation[Identifier]
		:GetMarkerReachedSignal("Swap")
		:Connect(function()
			DidSwap[Identifier] = true
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end
			
			if HelpfullModule.CheckForAttributes(char,true,true,false,true,true,true,true) then return end
			
			char:SetAttribute("CurrentWeapon",TargetWeapon)
			
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			HelpfullModule.ChangeWeapon(Identifier,char,torso)
			
			
			
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[TargetWeapon].HoldingWeaponWeld.C0
			end
			
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Equip)
			
			
		
			char:SetAttribute("IsTransforming", false)
			EquipDebounce[Identifier] = false
			

			
			

			
			
			
			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end
			
			WeaponCounter[Identifier] = WeaponCounter[Identifier] + 1
			if WeaponCounter[Identifier] > 4 then
				WeaponCounter[Identifier] = 1
			end
			
			
			Connections[Identifier]:Disconnect()
			Connections[Identifier] = nil
			
			
		end)
	
	Weapon_SwapAnimation[Identifier].Stopped:Connect(function()
		if DidSwap[Identifier] then return end
		
		for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
			if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
				return
			end
		end

		if HelpfullModule.CheckForAttributes(char,true,true,false,true,true,true) then return end

		char:SetAttribute("CurrentWeapon",TargetWeapon)

		for _, weapon in ipairs(WeaponsModels:GetChildren()) do
			local existing = char:FindFirstChild(weapon.Name)
			if existing then
				existing:Destroy()
			end
		end

		HelpfullModule.ChangeWeapon(Identifier,char,torso)

		if Welds[Identifier] then
			Welds[Identifier].Part0 = rightArm
			Welds[Identifier].C0 = WeaponsWeld[TargetWeapon].HoldingWeaponWeld.C0
		end

		IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Idle)
		EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[TargetWeapon].Main.Equip)


		
		char:SetAttribute("IsTransforming", false)
		EquipDebounce[Identifier] = false
		DidSwap[Identifier] = false





		if IdleAnims[Identifier] then
			IdleAnims[Identifier]:Play()
		end

		WeaponCounter[Identifier] = WeaponCounter[Identifier] + 1
		if WeaponCounter[Identifier] > 4 then
			WeaponCounter[Identifier] = 1
		end
		
		
	end)
	
	
end

local function Mode1_Z()
	
end

local function Mode1_X()
	
end

local function Mode1_C()
	
end

local function Mode2_R()

end

local function Mode2_Z()

end

local function Mode2_X()

end

local function Mode2_C()

end




function Bone.LoadBonePassives (char,rootPart)
	char:SetAttribute("Dodges",24)
end

function Bone.R(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_R()
	elseif char:GetAttribute("Mode1") then
		Mode1_R()
	
	else
		return
	end
end

function Bone.Z(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_Z()
	elseif char:GetAttribute("Mode1") then
		Mode1_Z()

	else
		return
	end
	
end

function Bone.X(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_X()
	elseif char:GetAttribute("Mode1") then
		Mode1_X()

	else
		return
	end
end

function Bone.C(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_C()
	elseif char:GetAttribute("Mode1") then
		Mode1_C()
		
		print("log")

	else
		return
	end
end





return Bone
