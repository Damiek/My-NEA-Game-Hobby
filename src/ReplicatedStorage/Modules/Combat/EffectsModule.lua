local module = {}

local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local PLayers = game:GetService("Players")
local RunService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local localplr = PLayers.LocalPlayer
local cam = workspace.CurrentCamera

local AnimationsFolder = RS.Animations
local ElementAnims = AnimationsFolder.Element

local hiddenElements = {}

local function Shiftoff(char)
	local hum = char.Humanoid
	uis.MouseBehavior = Enum.MouseBehavior.Default
	localplr.CameraMode = Enum.CameraMode.Classic
	hum.AutoRotate = false
end

function module.HideUI(char)
	local plr = PLayers:GetPlayerFromCharacter(char)

	if plr and plr == localplr then
		local playerGui = plr:FindFirstChild("PlayerGui")
		if playerGui then
			for _, gui in ipairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "MovementUI" then
					gui.Enabled = false
					table.insert(hiddenElements, gui)
				end
			end
		end
	end

	if char then
		for _, gui in ipairs(char:GetDescendants()) do
			if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and gui.Enabled then
				gui.Enabled = false
				table.insert(hiddenElements, gui)
			end
		end
	end
end

function module.TweenBars(char)
	local plr = PLayers:GetPlayerFromCharacter(char)
	local Top = nil
	local Bottom = nil
	local TOP_Dest = UDim2.new(-0.001, 0, -0.187, 0)
	local BOTTOM_Dest = UDim2.new(-0.034, 0, 0.75, 0)
	local tweenSlide = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	if plr and plr == localplr then
		local PlayerGui = plr:FindFirstChildOfClass("PlayerGui")
		local MovementUI = PlayerGui:FindFirstChild("MovementUI")

		if MovementUI then
			Top = MovementUI:FindFirstChild("Top") :: Frame
			Bottom = MovementUI:FindFirstChild("Bottom") :: Frame

			local tweenTop = TS:Create(Top, tweenSlide, { Position = TOP_Dest })
			local tweenBottom = TS:Create(Bottom, tweenSlide, { Position = BOTTOM_Dest })

			tweenTop:Play()
			tweenBottom:Play()
		end
	end
end

function module.ResetBars(char)
	local plr = PLayers:GetPlayerFromCharacter(char)
	local Top = nil
	local Bottom = nil

	local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
	local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)
	local tweenSlide = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	if plr and plr == localplr then
		local PlayerGui = plr:FindFirstChildOfClass("PlayerGui")
		local MovementUI = PlayerGui:FindFirstChild("MovementUI")

		if MovementUI then
			Top = MovementUI:FindFirstChild("Top")
			Bottom = MovementUI:FindFirstChild("Bottom")

			local tweenTop = TS:Create(Top, tweenSlide, { Position = TOP_HIDDEN })
			local tweenBottom = TS:Create(Bottom, tweenSlide, { Position = BOTTOM_HIDDEN })

			tweenTop:Play()
			tweenBottom:Play()
		end
	end
end

function module.ShowUI()
	for _, gui in ipairs(hiddenElements) do
		if gui and gui.Parent then
			gui.Enabled = true
		end
	end
	table.clear(hiddenElements)
end

function module.EmitEffect(Targeteffect, cframe, destroytime)
	local effect = Targeteffect:Clone()
	effect.Parent = workspace.VFX
	effect.CFrame = cframe

	for i, v in pairs(effect:GetDescendants()) do
		if v:isA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end

	Debris:AddItem(effect, destroytime)
end

local targetObject = nil

function module.Highlight(char, duration, FillColor, OutlineColor)
	local Highlight = Instance.new("Highlight")
	Highlight.Parent = char
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	Highlight.FillTransparency = 0 -- was .2
	Highlight.FillColor = FillColor
	Highlight.OutlineTransparency = 0.2
	Highlight.OutlineColor = OutlineColor
	local TweenGoal = { FillTransparency = 1, OutlineTransparency = 1 }
	TS:Create(Highlight, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), TweenGoal):Play()
	Debris:AddItem(Highlight, duration)
end

function module.triggerEffects(parentObject, char, customOffset)
	local HRP = char:FindFirstChild("HumanoidRootPart")
	if not HRP then
		warn("No HRP found!")
		return
	end

	local EffectPart = parentObject:Clone()
	EffectPart.Parent = workspace.VFX
	EffectPart:SetAttribute("OwnerCharacter", char.Name)

	local offsetCFrame = customOffset or CFrame.new(0, 0, -0.894)
	EffectPart.CFrame = HRP.CFrame * offsetCFrame * (parentObject.CFrame - parentObject.Position)

	local cleanupTime = 0

	for _, instance in ipairs(EffectPart:GetDescendants()) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Sound") then
			task.spawn(function()
				if not instance.Parent then
					return
				end

				local delay = instance:GetAttribute("EmitDelay") or 0
				local duration = instance:GetAttribute("EmitDuration")

				if delay + (duration or 0) > cleanupTime then
					cleanupTime = delay + (duration or 0)
				end

				if delay > 0 then
					task.wait(delay)
				end
				if not instance.Parent then
					return
				end

				if instance:IsA("Sound") then
					instance:Play()
					if instance.TimeLength > cleanupTime then
						cleanupTime = instance.TimeLength
					end
				elseif instance:IsA("ParticleEmitter") then
					local count = instance:GetAttribute("EmitCount")

					if duration and duration > 0 then
						instance.Enabled = true
						task.wait(duration)
						if instance.Parent then
							instance.Enabled = false
						end
					elseif count and count > 0 then
						instance:Emit(count)
					else
						instance:Emit(1)
					end
				elseif instance:IsA("Beam") then
					local beamClone = instance:Clone()
					beamClone.Parent = instance.Parent
					beamClone.Enabled = true

					local beamDuration = duration and duration > 0 and duration or 0.03
					task.wait(beamDuration)

					if beamClone then
						beamClone:Destroy()
					end
				end
			end)
		end
	end

	task.delay(cleanupTime + 1, function()
		if EffectPart then
			EffectPart:Destroy()
		end
	end)
	return EffectPart
end

function module.AfterImage(char, anim, type)
	if type == nil then
		local clone = RS.Effects.AfterImage:Clone()
		clone.Parent = workspace.VFX
		clone.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame

		task.delay(0.09, function()
			local humanoid = clone:FindFirstChildOfClass("Humanoid")
			if not humanoid or not humanoid.Animator then
				return
			end

			local animTrack = clone.Humanoid.Animator:LoadAnimation(anim)
			animTrack:Play()

			-- Fade out all parts
			local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
			local tweensLeft = 0

			for _, part in ipairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					tweensLeft += 1
					local t = TS:Create(part, fadeInfo, { Transparency = 1 })
					t.Completed:Connect(function()
						tweensLeft -= 1
						if tweensLeft <= 0 then
							clone:Destroy()
						end
					end)
					t:Play()
				end
			end

			-- Fade highlight outline too
			local highlight = clone:FindFirstChildOfClass("Highlight")
			if highlight then
				TS:Create(highlight, fadeInfo, {
					FillTransparency = 1,
					OutlineTransparency = 1,
				}):Play()
			end
		end)
	else
		if type == "AstralDodge" then
			char.Archivable = true
			local sourceTrack = RS.Animations.Weapons.ShootingStar.Dodging.W

			local Colors = {
				{ Fill = Color3.fromRGB(119, 0, 255), Outline = Color3.fromRGB(113, 5, 255) },
				{ Fill = Color3.fromRGB(170, 0, 255), Outline = Color3.fromRGB(140, 0, 200) },
				{ Fill = Color3.fromRGB(80, 0, 200), Outline = Color3.fromRGB(60, 0, 180) },
				{ Fill = Color3.fromRGB(200, 50, 255), Outline = Color3.fromRGB(170, 30, 220) },
				{ Fill = Color3.fromRGB(50, 100, 255), Outline = Color3.fromRGB(30, 80, 220) },
			}

			coroutine.wrap(function()
				for i = 1, 8 do
					task.wait(0.04)
					if not char then break end

					local clone = char:Clone()
					clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					clone.Name = "AfterImage"

					local colorIndex = (i - 1) % #Colors + 1
					local startColor = Colors[colorIndex]
					local nextColor = Colors[colorIndex % #Colors + 1]

					local Highlight = Instance.new("Highlight")
					Highlight.Parent = clone
					Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					Highlight.FillTransparency = 0.4
					Highlight.FillColor = startColor.Fill
					Highlight.OutlineTransparency = 0.5
					Highlight.OutlineColor = startColor.Outline

					local PointLight = Instance.new("PointLight", clone.HumanoidRootPart)
					PointLight.Brightness = 2.5
					PointLight.Color = startColor.Fill
					PointLight.Range = 6
					PointLight.Shadows = false

					for _, part in pairs(clone:GetDescendants()) do
						if part.Name == "ShootingStar" then
							part:Destroy()
						end
						if part:IsA("Script") or part:IsA("LocalScript") or part:IsA("ModuleScript") or part:IsA("BillboardGui") then
							part:Destroy()
						end
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
							if part:IsA("MeshPart") then part.TextureID = "" end
							part.Transparency = 0.5
							part.CollisionGroup = "VFX_Models"
							part.Color = Color3.fromRGB(170, 170, 255)
						end
					end

					clone.Parent = workspace.VFX
					clone.HumanoidRootPart.Transparency = 1
					clone.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
					clone.HumanoidRootPart.Anchored = true

					if sourceTrack then
						local animTrack = clone.Humanoid.Animator:LoadAnimation(sourceTrack)
						animTrack:Play(0)
						animTrack:AdjustSpeed(0)
						animTrack.TimePosition = 0.12
					end

					TS:Create(Highlight, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
						FillColor = nextColor.Fill,
						OutlineColor = nextColor.Outline,
					}):Play()

					TS:Create(PointLight, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
						Color = nextColor.Fill,
					}):Play()

					task.delay(1.2, function()
						if not clone then return end

						local tweensLeft = 0

						for _, part in ipairs(clone:GetDescendants()) do
							if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
								tweensLeft += 1

								local randDir = Vector3.new(
									math.random(-100, 100) / 100,
									math.random(20, 60) / 100,
									math.random(-100, 100) / 100
								).Unit
								local targetPos = part.Position + randDir * math.random(3, 8) + Vector3.new(0, math.random(2, 5), 0)
								local targetSize = part.Size * math.random(110, 130) / 100

								TS:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									CFrame = CFrame.new(targetPos) * part.CFrame.Rotation,
									Size = targetSize,
								}):Play()

								task.delay(0.25, function()
									local t = TS:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
										Transparency = 1,
									})
									t.Completed:Connect(function()
										tweensLeft -= 1
										if tweensLeft <= 0 and clone then
											clone:Destroy()
										end
									end)
									t:Play()
								end)
							end
						end

						if Highlight then
							TS:Create(Highlight, TweenInfo.new(0.55, Enum.EasingStyle.Linear), {
								FillTransparency = 1,
								OutlineTransparency = 1,
							}):Play()
						end
						if PointLight then
							TS:Create(PointLight, TweenInfo.new(0.55, Enum.EasingStyle.Linear), {
								Brightness = 0,
							}):Play()
						end

						if tweensLeft <= 0 then
							task.delay(0.6, function()
								if clone then clone:Destroy() end
							end)
						end
					end)
				end
			end)()
		end
	end
end

function module.HighlightBlink(target, fillcolor, duration, blinkSpeed)
	print("Started highlight", target)
	local hl = Instance.new("Highlight")
	hl.FillColor = fillcolor
	hl.OutlineColor = fillcolor
	hl.FillTransparency = 0
	hl.OutlineTransparency = 0
	hl.Parent = target
	hl.DepthMode = Enum.HighlightDepthMode.Occluded

	local elapsed = 0
	local blinkTime = blinkSpeed or 0.5 -- Total time for one full blink cycle (0.25 out + 0.25 back)

	while elapsed < duration do
		-- Fade out
		local blinkTween = TS:Create(
			hl,
			TweenInfo.new(0.25, Enum.EasingStyle.Linear),
			{ FillTransparency = 0.5, OutlineTransparency = 0.5 }
		)
		blinkTween:Play()
		blinkTween.Completed:Wait() -- Wait for fade out to finish

		-- Fade back in
		local resetTween = TS:Create(
			hl,
			TweenInfo.new(0.25, Enum.EasingStyle.Linear),
			{ FillTransparency = 0, OutlineTransparency = 0 }
		)
		resetTween:Play()
		resetTween.Completed:Wait() -- Wait for fade in to finish

		elapsed += blinkTime
	end

	hl:Destroy()
	print("Finished highlight")
end

function module.HyprVfx(char, echar, isMainSource)
	if not char then
		return
	end
	local HRP: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local Middlepart
	if isMainSource then
		local VFXpart = RS.Effects.Combat.HyprParryVFX
		Middlepart = module.triggerEffects(VFXpart, char, CFrame.new(-0.861, -0.1, -1.948))
	end

	local hl = Instance.new("Highlight")
	hl.FillTransparency = 0.9
	hl.OutlineTransparency = 0.2
	hl.OutlineColor = Color3.fromRGB(216, 181, 55)
	hl.OutlineColor = Color3.fromRGB(171, 141, 33)
	hl.Parent = char

	Debris:AddItem(hl, 0.5)

	Shiftoff(char)

	local middlePosition: Vector3 = HRP.Position

	if Middlepart then
		local middleAttachment = Middlepart:FindFirstChild("Middle", true)
		if middleAttachment then
			middlePosition = middleAttachment.WorldPosition
		else
			middlePosition = Middlepart.Position
		end
	elseif echar and echar:FindFirstChild("HumanoidRootPart") then
		middlePosition = HRP.Position:Lerp(echar.HumanoidRootPart.Position, 0.5)
	end

	local plrflag = PLayers:GetPlayerFromCharacter(char)

	if plrflag == localplr then
		localplr.CameraMode = Enum.CameraMode.Classic

		local PlayerScripts = localplr:FindFirstChild("PlayerScripts")
		local PlayerModule = PlayerScripts and PlayerScripts:FindFirstChild("PlayerModule")
		if PlayerModule then
			local CameraModule = require(PlayerModule):GetCameras()
			if CameraModule and CameraModule.activeMouseLockController then
				CameraModule.activeMouseLockController:EnableMouseLock(false)
			end
		end

		local baseOrientation = HRP.CFrame - HRP.CFrame.Position
		local camoffset = Vector3.new(6, -1.5, 15)
		local camworldpos = HRP.Position + baseOrientation:VectorToWorldSpace(camoffset)
		local TargetCframe = CFrame.lookAt(camworldpos, middlePosition)
		module.TweenBars(char)

		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = TargetCframe
		cam.FieldOfView = 55
		module.HideUI(char)

		task.wait(0.2)

		local trackingConnection
		local fovInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fovTween = TS:Create(cam, fovInfo, { FieldOfView = 70 })

		trackingConnection = RunService.RenderStepped:Connect(function()
			if char and char.Parent and echar and echar.Parent then
				local currentHRP = char.HumanoidRootPart
				local currentEHRP = echar.HumanoidRootPart

				local liveMiddle = currentHRP.Position:Lerp(currentEHRP.Position, 0.5)
				local liveCamWorldPos = currentHRP.Position + baseOrientation:VectorToWorldSpace(camoffset)

				cam.CFrame = CFrame.lookAt(liveCamWorldPos, liveMiddle)
			else
				trackingConnection:Disconnect()
			end
		end)

		fovTween:Play()
		

		fovTween.Completed:Connect(function()
			if trackingConnection then
				trackingConnection:Disconnect()
			end
			cam.CameraType = Enum.CameraType.Custom

			localplr.CameraMode = Enum.CameraMode.Classic

			local PlayerScripts = localplr:FindFirstChild("PlayerScripts")
			local PlayerModule = PlayerScripts and PlayerScripts:FindFirstChild("PlayerModule")
			if PlayerModule then
				local CameraModule = require(PlayerModule):GetCameras()
				if CameraModule and CameraModule.activeMouseLockController then
					CameraModule.activeMouseLockController:EnableMouseLock(true)
				end
			end

			char.Humanoid.AutoRotate = true
			module.ShowUI()
			module.ResetBars(char)
		end)
	end
end

module.DestroyEffects = function(char, effect)
	for i, v in pairs(workspace.VFX:GetChildren()) do
		if v.Name == effect.Name and v:GetAttribute("OwnerCharacter") == char.Name then
			v:Destroy()
		end
	end
end

-- Run the function.

return module
