local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris") 

local Events = RS.Events
local Modules = RS.Modules

local CombatEffectsModule = require(Modules.Combat.EffectsModule)



Events.VFX.OnClientEvent:Connect(function(action,...)
	if action == "CombatEffects" then
		local effect, cframe,destroytime =...
		
		CombatEffectsModule.EmitEffect(effect, cframe,destroytime)
	end
	
	if action == "SwingEffect" then
		local effect, char =...
		print(char, "In the server")

		CombatEffectsModule.triggerEffects(effect,char)
	end
	
	if	action == "Highlight" then
		local char, duration, FillColor, OutlineColor = ...
		
		local Highlight = Instance.new("Highlight")
		Highlight.Parent = char
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		Highlight.FillTransparency = .2
		Highlight.FillColor = FillColor
		Highlight.OutlineTransparency = 0
		Highlight.OutlineColor = OutlineColor
		local TweenGoal = {FillTransparency= 1, OutlineTransparency = 1}
		TS:Create(Highlight,TweenInfo.new(duration,Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), TweenGoal):Play()
		Debris:AddItem(Highlight,duration)
	end
	
	
end)