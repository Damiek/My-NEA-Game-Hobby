local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
 

local Events = RS.Events

local RSModules = RS.Modules
local SSModules = SS.Modules

local CombatEvent = Events.Combat


local CombatHelperModule =require(SSModules.Combat.CombatHelper)






CombatEvent.OnServerEvent:Connect(function(plr)
	CombatHelperModule.Attack(plr.Character)
end)
