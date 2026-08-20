local Players = game:GetService("Players")

local SS = game:GetService("ServerStorage")
local FallDamage = require(SS.Modules.Movement.FallDamage)

local function TrackCharacter(char)
	if char:FindFirstChildOfClass("Humanoid") then
		FallDamage.TrackCharacter(char)
	end
end

local function OnPlayerAdded(plr)
	plr.CharacterAdded:Connect(TrackCharacter)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, plr in Players:GetPlayers() do
	OnPlayerAdded(plr)
end