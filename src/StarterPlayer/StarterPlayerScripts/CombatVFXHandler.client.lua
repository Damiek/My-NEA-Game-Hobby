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

	if action == "AfterImage" then
		local char,anim,type = ...
		CombatEffectsModule.AfterImage(char, anim, type)
	end
	
	if action == "SwingEffect" then
		local effect, char =...

		CombatEffectsModule.triggerEffects(effect,char)
	end

	if action == "DestroyVFX" then
		local char, effect = ...
		CombatEffectsModule.DestroyEffects(char, effect)
	end

	if action == "Trail" then
		local target = ... 
		
	end

	if action == "HyprParry" then 
		local char,echar = ...
		CombatEffectsModule.HyprVfx(char,echar,true)
		CombatEffectsModule.HyprVfx(echar,char,false)
	end
	
	if	action == "Highlight" then
		local char, duration, FillColor, OutlineColor = ...
		
		CombatEffectsModule.Highlight(char, duration, FillColor, OutlineColor)
	end

	if action  ==  "HighlightBlink" then
		local target, fillcolor, duration, blinkSpeed = ...
		CombatEffectsModule.HighlightBlink(target, fillcolor, duration, blinkSpeed)
	end

	if action == "HyprIndicator" then
		local cframe = ...
		local effect = RS.Effects.Combat.HyprIndicator
		CombatEffectsModule.EmitEffect(effect, cframe)
	end

	
	
end)