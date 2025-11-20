local module = {}

local Debris= game:GetService("Debris")


function module.EmitEffect(effect, cframe,destroytime)
	local effect = effect:Clone()
	effect.Parent = workspace.VFX
	effect.CFrame = cframe
	
	for i, v in pairs(effect:GetDescendants()) do
		if v:isA("ParticleEmitter")then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
	
	Debris:AddItem(effect,destroytime)
end


local targetObject = nil


function module.triggerEffects(parentObject, char)
	local HRP = char:FindFirstChild("HumanoidRootPart")
	if not HRP then 
		warn("No HRP found!")
		return
	end

	-- Clone the whole effect object
	local EffectPart = parentObject:Clone()
	EffectPart.Parent = workspace.VFX

	

	
	EffectPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -0.894) * (parentObject.CFrame - parentObject.Position)


	local cleanupTime = 0 -- track longest effect duration

	-- Process all child effects
	for _, instance in ipairs(EffectPart:GetDescendants()) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Sound") then

			task.spawn(function()
				if not instance.Parent then return end

				local delay = instance:GetAttribute("EmitDelay") or 0
				local duration = instance:GetAttribute("EmitDuration")

				-- Track cleanup time
				if delay + (duration or 0) > cleanupTime then
					cleanupTime = delay + (duration or 0)
				end

				if delay > 0 then
					task.wait(delay)
				end
				if not instance.Parent then return end

				-- SOUND
				if instance:IsA("Sound") then
					instance:Play()
					if instance.TimeLength > cleanupTime then
						cleanupTime = instance.TimeLength
					end

					-- PARTICLES
				elseif instance:IsA("ParticleEmitter") then
					local count = instance:GetAttribute("EmitCount")

					if duration and duration > 0 then
						instance.Enabled = true
						task.wait(duration)
						if instance.Parent then instance.Enabled = false end

					elseif count and count > 0 then
						instance:Emit(count)
					else
						instance:Emit(1)
					end

					-- BEAMS
				elseif instance:IsA("Beam") then
					local beamClone = instance:Clone()
					beamClone.Parent = instance.Parent
					beamClone.Enabled = true

					local beamDuration = duration and duration > 0 and duration or 0.03
					task.wait(beamDuration)

					if beamClone then beamClone:Destroy() end
				end
			end)
		end
	end

	-- Destroy effect object after all child effects finish
	task.delay(cleanupTime + 1, function()
		if EffectPart then
			EffectPart:Destroy()
		end
	end)
end


-- Run the function.

return module
