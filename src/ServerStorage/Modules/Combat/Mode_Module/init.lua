local module = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules

-- Module references
local ElementInfo = require(SSModules.Element.ElementInfo)
local HelpfulModule = require(SSModules.Other.Helpful)
local Textmod = require(SSModules.text)
local TransformationModule = require(SSModules.Other.Transformations)
local WeaponsStatsModule = require(SSModules.Weapons.WeaponStats)




-- Assets
local Models = RS.Models
local WeaponsModels = Models.Weapons

-- Store animation marker connections (per player/identifier)
local TransformConnections = {}

-- Utility: Get a unique ID if player reference is unavailable
local function getUniqueId(char)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	return uid.Value or nil
end

---------------------------------------------------------------------
-- MODE 1 TRANSFORMATION
---------------------------------------------------------------------
function module.Mode1(
	char,
	WeaponsAnimations,
	Race,
	EquipDebounce,
	Welds,
	TransformAnims,
	EquipAnims,
	IdleAnims,
	WeaponsWeld,
	ChangeWeapon
)
	if not char or not char:FindFirstChild("Humanoid") then return end

	local hum = char.Humanoid
	local rootPart = char:WaitForChild("HumanoidRootPart")

	local plr = game.Players:GetPlayerFromCharacter(char)
	local Identifier = plr or getUniqueId(char)
	if not Identifier then return end
	if EquipDebounce[Identifier] then return end -- Prevent duplicate calls

	-- Debounce & state
	EquipDebounce[Identifier] = true
	char:SetAttribute("iframes", true)
	char:SetAttribute("IsTransforming", true)
	char:SetAttribute("Mode1", true)

	local element = char:GetAttribute("Element")
	local elementStats = ElementInfo.getStats(element)
	local newWeapon = elementStats.Mode1

	-- Load and play transformation animation
	TransformAnims[Identifier] = hum:LoadAnimation(WeaponsAnimations.Transformations[element].Mode1)
	rootPart.Anchored = true
	TransformAnims[Identifier]:Play()

	-- Disconnect any previous connection for this character
	if TransformConnections[Identifier] then
		TransformConnections[Identifier]:Disconnect()
	end

	-- Connect new transform signal
	TransformConnections[Identifier] = TransformAnims[Identifier]
		:GetMarkerReachedSignal("Transform")
		:Connect(function()
			-- Ensure single execution
			TransformConnections[Identifier]:Disconnect()

			-- Prevent transformation if swings or invalid state
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end

			if HelpfulModule.CheckForAttributes(char, true, true, true, true, nil, true,true) then return end

			char:SetAttribute("CurrentWeapon", newWeapon)

			local torso = char:FindFirstChild("Torso")
			local rightArm = char:FindFirstChild("Right Arm")

			-- Remove existing weapon models
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			-- Change to new weapon
			ChangeWeapon(Identifier, char, torso)

			-- Setup weld
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C0
			end

			-- Load idle/equip animations
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Equip)


			-- Restore states
			rootPart.Anchored = false
			char:SetAttribute("Equipped", true)
			char:SetAttribute("IsTransforming", false)
			char:SetAttribute("iframes", false)
			char:SetAttribute("Mode1", true) -- keep active
			EquipDebounce[Identifier] = false


			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end
		end)
end

---------------------------------------------------------------------
-- MODE 2 TRANSFORMATION
---------------------------------------------------------------------
function module.Mode2(
	char,
	WeaponsAnimations,
	Race,
	EquipDebounce,
	Welds,
	TransformAnims,
	EquipAnims,
	IdleAnims,
	WeaponsWeld,
	ChangeWeapon
)
	if not char or not char:FindFirstChild("Humanoid") then return end

	local hum = char.Humanoid
	local rootPart = char:WaitForChild("HumanoidRootPart")

	local plr = game.Players:GetPlayerFromCharacter(char)
	local Identifier = plr or getUniqueId(char)
	if not Identifier then return end
	if EquipDebounce[Identifier] then return end

	-- Debounce & state
	EquipDebounce[Identifier] = true
	char:SetAttribute("iframes", true)
	char:SetAttribute("IsTransforming", true)
	char:SetAttribute("Mode2", true)

	local element = char:GetAttribute("Element")
	local elementStats = ElementInfo.getStats(element)
	local newWeapon = elementStats.Mode2
	local dialogue = elementStats.Text

	hum.Health = 100
	rootPart.Anchored = true

	-- Load animation (placeholder until Mode2 animation is made)
	TransformAnims[Identifier] = hum:LoadAnimation(WeaponsAnimations.Transformations[element].Mode1)

	if plr then
		Textmod.feed(dialogue, plr)
	end

	TransformAnims[Identifier]:Play()

	-- Disconnect any previous connection
	if TransformConnections[Identifier] then
		TransformConnections[Identifier]:Disconnect()
	end

	-- Connect transform event
	TransformConnections[Identifier] = TransformAnims[Identifier]
		:GetMarkerReachedSignal("Transform")
		:Connect(function()
			TransformConnections[Identifier]:Disconnect()

			-- Prevent transformation if swings or invalid state
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end

			if HelpfulModule.CheckForAttributes(char, true, true, true, true, nil, true,true) then return end

			char:SetAttribute("CurrentWeapon", newWeapon)

			local torso = char:FindFirstChild("Torso")
			local rightArm = char:FindFirstChild("Right Arm")

			-- Remove all existing weapon models
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			-- Change weapon
			ChangeWeapon(Identifier, char, torso)

			-- Setup weld
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C0
				if Welds[Identifier].C1 then
					Welds[Identifier].C1 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C1
				end
			end

			-- Load animations
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Equip)

			rootPart.Anchored = false
			char:SetAttribute("Equipped", true)
			char:SetAttribute("IsTransforming", false)
			char:SetAttribute("iframes", false)
			char:SetAttribute("Mode2", true) -- keep active
			EquipDebounce[Identifier] = false


			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end
		end)
end

return module
