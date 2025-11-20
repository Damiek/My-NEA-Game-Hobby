local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local ElementModule_Folder = SSModules.Element
local HelpfullModule = require(SSModules.Other.Helpful)


local Events = RS.Events
local MoveEvent = Events.SkillEvent





MoveEvent.OnServerEvent:Connect(function(plr, action)

	local char = plr.Character
	if not char then return end


	local element = char:GetAttribute("Element")
	if not element then warn("No Element attribute for", plr.Name) return end




	local elementModule = ElementModule_Folder:FindFirstChild(element)
	if not elementModule then return end



	local module = require(elementModule)


	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true) then
		warn("CheckForAttributes blocked the move")
		return
	end



	if action == "Z Move" then
		module.Z(char)
	elseif action == "X Move" then
		module.X(char)
	elseif action == "C Move" then
		module.C(char)
	elseif action == "R Move" then
		module.R(char)
	end
end)
