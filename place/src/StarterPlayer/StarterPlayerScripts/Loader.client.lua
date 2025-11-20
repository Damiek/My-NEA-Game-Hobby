local ContentProvider = game:GetService("ContentProvider")
local RS = game:GetService("ReplicatedStorage")

local allAnims = {}

task.wait()

for i,anim in pairs(RS:WaitForChild("Animations"):GetDescendants()) do
	if anim:IsA("Animation") then
		table.insert(allAnims,anim)
	end
end

ContentProvider:PreloadAsync(allAnims)