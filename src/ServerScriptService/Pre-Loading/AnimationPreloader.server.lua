local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

-- Gather all animations from ReplicatedStorage
local allAnims = {}

for _, anim in ipairs(RS:WaitForChild("Animations"):GetDescendants()) do
	if anim:IsA("Animation") then
		table.insert(allAnims, anim)
	end
end

-- Preload assets to ensure they're available on the server
ContentProvider:PreloadAsync(allAnims)

-- Function to warm up a humanoid’s animator
local function WarmUpAnimations(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Preload each animation as an AnimationTrack
	for _, anim in ipairs(allAnims) do
		local success, track = pcall(function()
			return animator:LoadAnimation(anim)
		end)

		if success and track then
			-- Immediately stop the track so it doesn’t play
			track:Stop(0)
			-- Optional: destroy after compiling to save memory
			track:Destroy()
		end
	end
end

-- Listen for players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			-- Wait a tiny bit to ensure Animator exists
			task.wait(0.2)
			WarmUpAnimations(humanoid)
		end
	end)
end)
