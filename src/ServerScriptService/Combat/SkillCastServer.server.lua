local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local Events = RS.Events

local SkillMasterController = require(SSModules.Combat.SkillMasterController)

local SkillCast = Events:FindFirstChild("SkillCast")
if not SkillCast then
	SkillCast = Instance.new("RemoteEvent")
	SkillCast.Name = "SkillCast"
	SkillCast.Parent = Events
end

SkillCast.OnServerEvent:Connect(function(plr, skillName)
	print("I work")
	if type(skillName) ~= "string" then
		print(skillName)
		return
	end

	SkillMasterController.OnSkillCalled(plr, skillName)
end)
