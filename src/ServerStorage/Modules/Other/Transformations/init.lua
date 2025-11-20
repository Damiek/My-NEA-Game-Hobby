local module = {}
function module.Mode2Transform(char, rootPart, torso)
	local element = char:GetAttribute("Element")
	local Dummy = script[element] -- Change location if needed

	if Dummy then
		-- Remove old accessories, clothing, body colors, character meshes, and highlights
		for _, item in pairs(char:GetChildren()) do
			if item:IsA("Accessory") or 
				item:IsA("Shirt") or 
				item:IsA("Pants") or 
				item:IsA("BodyColors") or 
				item:IsA("CharacterMesh") or 
				item:IsA("Highlight") then
				item:Destroy()
			end
		end

		-- Clone new ones from Dummy
		for _, part in pairs(Dummy:GetChildren()) do
			if part:IsA("Shirt") or 
				part:IsA("Pants") or 
				part:IsA("Accessory") or 
				part:IsA("BodyColors") or 
				part:IsA("CharacterMesh") or 
				part:IsA("Highlight") then
				local clone = part:Clone()
				clone.Parent = char
			end
		end

		-- Handle element-specific behavior

		if element == "Astral" then
			module.JoinMode2Faitwing(char, torso)
		end
	end
end









function module.Modedecrease (char)
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")

	-- Ensure the character has the ModeEnergy attribute
	if not char:GetAttribute("ModeEnergy") then
		return
	end

	-- Loop to decrease ModeEnergy over time
	while char and char:GetAttribute("ModeEnergy") > 0 do
		local currentEnergy = char:GetAttribute("ModeEnergy")
		local newEnergy = math.max(0, currentEnergy - 0.8333333333) -- Prevent negative values

		char:SetAttribute("ModeEnergy", newEnergy)
		if newEnergy == 0 then
			task.wait(1) -- Small delay to ensure all instances exist
			print("Energy depleted! Removing extra instances...")
		end


		task.wait(1) -- Wait 1 second before next decrease
	end
	
	for i,v in pairs(char:GetChildren()) do   
		if char:FindFirstChild("Shadow Fait") then
			char:FindFirstChild("Shadow Fait"):Destroy()
		end
	end


end
return module
