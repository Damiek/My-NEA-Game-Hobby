




for i,parts in pairs(workspace:GetChildren()) do
	if parts:GetAttribute("ChangeRace") then
		parts.ProximityPrompt.Triggered:Connect(function(plr)
			plr.Character:SetAttribute("Race", parts:GetAttribute("ChangeRace"))
			
		end)
		
	end
end