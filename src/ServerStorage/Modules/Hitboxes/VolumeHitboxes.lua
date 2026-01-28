local Players = game:GetService("Players")


local Hitboxes = {}
Hitboxes.ActiveHitboxes = {}
local CONFIG ={
    Transparency = 0.75,
	Color = Color3.new(1, 0, 0)

}


local function getUniqueId(char)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	local UID_Value = uid.Value
	return UID_Value
end





-- Create a normal hitbox
function Hitboxes.NormalHitBox(Size: Vector3, Attachment: Attachment, Character: Model, OnHit)
	if not Character or not Attachment then
		warn("[Hitboxes] Invalid Character or Attachment passed.")
		return
	end

	local Player = Players:GetPlayerFromCharacter(Character)
	local Identifier = Player or getUniqueId(Character)

	-- Create the hitbox part
	local Hitbox = Instance.new("Part")
	Hitbox.Name = (Player and Player.Name or Character.Name) .. "_Hitbox"
	Hitbox.Size = Size
	Hitbox.CFrame = Attachment.WorldCFrame 
	Hitbox.Anchored = false
	Hitbox.CanCollide = false
	Hitbox.Transparency = CONFIG.Transparency
	Hitbox.Color = CONFIG.Color
	Hitbox.Parent = workspace.Hitboxes
	

	-- Weld it to the attachment so it moves/rotates with the character
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = Hitbox
	weld.Part1 = Attachment.Parent
	weld.Parent = Hitbox

	-- Track active hitboxes
	Hitboxes.ActiveHitboxes[Identifier] = Hitboxes.ActiveHitboxes[Identifier] or {}
	table.insert(Hitboxes.ActiveHitboxes[Identifier], Hitbox)

	-- Prevent multiple hits on the same humanoid
	local alreadyHit = {}

	Hitbox.Touched:Connect(function(part)
		local char = part.Parent
		if char:GetAttribute("iframes") then return end	
		local Ehum = char and char:FindFirstChildOfClass("Humanoid")
		if Ehum and OnHit and not alreadyHit[Ehum] then
			alreadyHit[Ehum] = true
			OnHit(Ehum, part)
		end
	end)

	return Hitbox
end

-- Destroy all hitboxes for a character (player or NPC)
function Hitboxes.DestroyHitboxes(Character)
	if not Character then
		warn("[Hitboxes] DestroyHitboxes called with nil Character.")
		return
	end

	local Player = Players:GetPlayerFromCharacter(Character)
	local Identifier = Player or getUniqueId(Character)

	local hitboxes = Hitboxes.ActiveHitboxes[Identifier]
	if hitboxes then
		for _, hitbox in ipairs(hitboxes) do
			if hitbox and hitbox.Parent then
				hitbox:Destroy()
			end
		end
		
		
		Hitboxes.ActiveHitboxes[Identifier] = nil
	end

	if not hitboxes then
		print("[Hitboxes] No active hitboxes found for character:", Character.Name)
	end
	
end

return Hitboxes
