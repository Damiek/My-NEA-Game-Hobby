
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")




local BehaviourTreeCreator = require(RS.BehaviorTreeCreator)
local AI_TREE = BehaviourTreeCreator:_createTree(RS.AI_Trees.BasicEnemy)

local char = script.Parent
local Humanoid = char.Humanoid

char:SetAttribute("Equipped", true)
char:SetAttribute("Combo", 1)
char:SetAttribute("Stunned", false)
char:SetAttribute("Swing", false)
char:SetAttribute("Attacking", false)
char:SetAttribute("iframes",false)
char:SetAttribute("IsBlocking",false)
char:SetAttribute("Blocking",0)
char:SetAttribute("Karma",0)


char:SetAttribute("Mode1", false)
char:SetAttribute("Mode2", false)
char:SetAttribute("Parrying",false)

char:SetAttribute("Dodges",0)
char:SetAttribute("Sprinting",false)
char:SetAttribute("IsCrouching",false)




local Object = {
	Name = char.Name,
	model = char,
	human = Humanoid,
	Range = 30,
	isPathRunning = false,
	AttackRange = 10,
	Target = nil,
	
}


local function Update()
	if char and Humanoid.Health > 0 then
		task.wait()
		AI_TREE:Run(Object)
	end
end

RunService.Stepped:Connect(Update)