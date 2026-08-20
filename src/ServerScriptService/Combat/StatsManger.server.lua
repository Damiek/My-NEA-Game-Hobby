local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PLRModule = require(ServerStorage.Modules.Objects.plr)
local StatFormulas = require(ServerStorage.Modules.Other.StatFormulas)

local Events = RS.Events
local StatsEvent = Events.StatsEvent
local VFXEvent = Events.VFX


--- Player stats initialization has been moved to the my custom PLR object .new function

StatsEvent.OnServerEvent:Connect(function(plr, action, Stat)
	local char = plr.Character
	local PLR = PLRModule.GetPLRFromPlayer(plr)
	local EXP = PLR.Data.GeneralExp
	local FreePoints = PLR.Data.FreePoints
	local Stat_EXP = PLR.Data.AttributeExp[Stat]
	local StatPoints = PLR.Data.STAT_POINTS[Stat]
	local Totalpoints = 0

	for i, stats in pairs(PLR.Stats) do
		if stats then
			Totalpoints += stats
		end
	end

	if StatPoints >= 99 or Totalpoints >= 350 then
		return
	end

	if action == "Train_Item" then
		local EXP_Cost = EXP * 0.15 -- We take 15% of the players general EXP to be converted into Attribute EXP per training item use
		Stat_EXP = Stat_EXP + EXP_Cost
		EXP = EXP - EXP_Cost

		local Required_EXP = StatFormulas.RequiredEXP(StatPoints)

		if Stat_EXP >= Required_EXP then
			Stat_EXP = Stat_EXP - Required_EXP
			PLR:IncreaseStat(Stat, 1)
			--VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
		end
	end

	if action == "Train_Free" and FreePoints > 0 then
		PLR:IncreaseStat(Stat, 1)
		PLR.Data.FreePoints = FreePoints - 1
		--VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
	end
end)
