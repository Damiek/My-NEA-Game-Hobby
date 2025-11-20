local HttpService = game:GetService("HttpService")



local function getUniqueId(Character)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return Character:GetFullName() .. "_" .. math.random(1e6, 1e9)
	end

	-- Use a StringValue to store persistent unique ID
	local uid = Humanoid:FindFirstChild("UniqueId")
	if not uid then
		uid = Instance.new("StringValue")
		uid.Name = "UniqueId"
		uid.Value = HttpService:GenerateGUID(false) -- server-safe GUID
		uid.Parent = Humanoid

	end
	return uid.Value
	
end


for i,v in workspace.NPC:GetChildren() do
	if v:IsA("Model") and  v:FindFirstChild("Humanoid") then
		local uid = getUniqueId(v)
		local ID_Part = Instance.new("Part")
	
		
		ID_Part.Parent = workspace.IDs
		ID_Part.Transparency = 1
		ID_Part.CFrame = v.HumanoidRootPart.CFrame
		ID_Part.CanTouch = false
		ID_Part.CanCollide = false
		ID_Part.Name = "ID_Part"
		ID_Part:SetAttribute("UID",uid)
	end
end