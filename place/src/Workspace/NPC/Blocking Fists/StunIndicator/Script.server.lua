script.Parent.Parent:GetAttributeChangedSignal("Stunned"):Connect(function()
	if script.Parent.Parent:GetAttribute("Stunned") then
		print("Stunned")
		script.Parent.Color = Color3.fromRGB(225,0,0)
	else
		script.Parent.Color = Color3.fromRGB(0,225,0)
		print("PO")
	end
end)
