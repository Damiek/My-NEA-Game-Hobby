task.wait(1)

local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules

local NPC_Class = require(SSModules.Objects.npc)
local SlashStorm = require(SSModules.Combat.SkillMasterController.WPN.SlashStorm)

local char = script.Parent
local Humanoid = char:FindFirstChildOfClass("Humanoid")
if not Humanoid then
	return
end

char:SetAttribute("Equipped", true)
char:SetAttribute("CurrentWeapon", "ShootingStar")
char:SetAttribute("Stamina", 255)
char:SetAttribute("MaxStamina", 255)
char:SetAttribute("Blocking", 0)
char:SetAttribute("Attacking", false)
char:SetAttribute("Swing", false)
char:SetAttribute("Stunned", false)

local npc = NPC_Class.GetNpcFromCharacter(char)

while char.Parent and Humanoid.Health > 0 do
	SlashStorm.start(char, npc)
	task.wait(1)
end
