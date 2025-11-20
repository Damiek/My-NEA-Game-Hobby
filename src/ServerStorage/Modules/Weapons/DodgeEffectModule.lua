local module = {}
local TweenService = game:GetService("TweenService")

function module.DodgeRandomTP(Target, Attacker)
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

	-- 📍 Get valid random XZ position respecting the no-spawn zone
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

	-- 🚀 Teleport target
	targetRoot.CFrame = CFrame.new(getValidPosition())
end

return module
