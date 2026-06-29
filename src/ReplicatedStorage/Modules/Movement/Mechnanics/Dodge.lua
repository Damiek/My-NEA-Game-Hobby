local Dodge = {}
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)
local ClientHelpful = require(RSModules.ClientHelpfull)
local cam = workspace.CurrentCamera

local WeaponAnims = RS.Animations.Weapons

local CONFIG = {
	DEFAULT_DASH_SPEED = 85,
	DASH_DURATION = 0.2,
}

local DodgeCoolDowns = {}
local CancelCoolDown = {}

local function CalculateDodgeSpeed(MovementObj: MovementTypes.MovementObj, isAir: boolean): number
	return CONFIG.DEFAULT_DASH_SPEED 
	-- here i  need to confiogure that the dodges can actually go slighty further in the air also 
	--while i am still on the tppiv of air doodgues i also need to remember to make the the dodger linger on thje aior for a bit
	-- .. this gives the the ablity to properly aim where they in tend to go - though this might only to apply to dodgeing after a movement option
end

local function Get3DMovement(MovementObj: MovementTypes.MovementObj)
	local char = MovementObj.char
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return Vector3.zero
	end

	local MoveInput = hum.MoveDirection
	local HeldKey = char:GetAttribute("CurrentMoveKey") or "None"

	-- If the player has a MoveDirection input, use it directly (Roblox already maps this to Camera Space!)
	if MoveInput.Magnitude > 0 then
		return MoveInput.Unit
	end

	-- FALLBACK: If MoveInput is 0 but they are holding a specific key, calculate direction manually using Cam CFrames
	if HeldKey ~= "None" then
		local camCF = cam.CFrame
		local forward = camCF.LookVector
		local right = camCF.RightVector

		-- Keep it flat on the XZ plane if they are on the ground, or keep full 3D if preferred
		if HeldKey == "W" then
			return forward.Unit
		end
		if HeldKey == "S" then
			return -forward.Unit
		end
		if HeldKey == "A" then
			return -right.Unit
		end
		if HeldKey == "D" then
			return right.Unit
		end
	end

	-- FINAL FALLBACK: If absolutely no keys are held, default directly forward where the camera is looking
	return cam.CFrame.LookVector.Unit
end

function Dodge.Dodge(MovementObj: MovementTypes.MovementObj)
	if not MovementObj or not MovementObj.char or MovementObj.IsActing.Dodging then
		return
	end
	local char = MovementObj.char
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")

	if DodgeCoolDowns[MovementObj] and tick() - DodgeCoolDowns[MovementObj] < 0.7 then
		return
	end

	if not HRP or not hum then
		return
	end

	if ClientHelpful.CheckForAttributes(char, true, true, true, true, false, true, true, false) then
		return
	end
	if ClientHelpful.CheckStamina(char, "Dodge") then
		return
	end

	local dashdir = Get3DMovement(MovementObj)
	local isAir = MovementObj.States.IsInAir

	if dashdir == Vector3.zero and isAir then
		return
	end

	local HeldKey = char:GetAttribute("CurrentMoveKey")
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local DodgeAnim = nil

	MovementObj.IsActing.Dodging = true

	if isAir then
		if HeldKey == nil or HeldKey == "None" then
			HeldKey = "W"
		end
		DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging.InAir[HeldKey])
		MovementObj.InfoTable.Dodge.Type = "AirDodge"
	else
		if dashdir == Vector3.zero or HeldKey == "None" then
			HeldKey = "None"
			MovementObj.InfoTable.Dodge.Type = "SpotDodge"
		else
			if HeldKey == nil then
				HeldKey = "W"
			end
			MovementObj.InfoTable.Dodge.Type = "Normal"
		end
		DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging[HeldKey])
	end

	if DodgeAnim then
		DodgeAnim:Play()
	end

	MovementObj.InfoTable.Dodge.Dir = dashdir
	MovementObj:ServerRequest("Dodge")

	local lv, algin
	if MovementObj.InfoTable.Dodge.Type ~= "SpotDodge" then
		local DodgeSpeed = CalculateDodgeSpeed(MovementObj, isAir)
		local att = HRP:FindFirstChild("DodgeAtt") or Instance.new("Attachment", HRP)
		att.Name = "DodgeAtt"

		lv = Instance.new("LinearVelocity")
		lv.Name = "DashForce"
		lv.Attachment0 = att
		lv.MaxForce = math.huge
		lv.VectorVelocity = dashdir * DodgeSpeed
		lv.Parent = HRP

		algin = Instance.new("AlignOrientation")
		algin.Name = "DashRotation"
		algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
		algin.Attachment0 = att
		algin.MaxTorque = math.huge
		algin.Responsiveness = 50
		algin.CFrame = CFrame.lookAlong(Vector3.zero, dashdir)
		algin.Parent = HRP
	end

	local infoTable = { Action = "Dodge" }
	MovementObj:BarTween(infoTable)

	local function Stop()
		if not MovementObj.IsActing.Dodging then
			return
		end

		if DodgeAnim then
			DodgeAnim:Stop()
			DodgeAnim:Destroy()
		end
		if lv then
			lv:Destroy()
		end
		if algin then
			algin:Destroy()
		end

		MovementObj.IsActing.Dodging = false
		MovementObj.InfoTable.Dodge.Type = "None"

		local Info = { Action = "Dodge" }
		MovementObj:BarTweenStop(Info)
		DodgeCoolDowns[MovementObj] = tick()
	end

	MovementObj.InfoTable.Dodge.Stop = Stop

	task.delay(CONFIG.DASH_DURATION, function()
		Stop()
	end)
end

function Dodge.DodgeCancel(MovementObj: MovementTypes.MovementObj)
	if not MovementObj or not MovementObj.IsActing.Dodging then
		return
	end
	if CancelCoolDown[MovementObj] and tick() - CancelCoolDown[MovementObj] < 0.5 then
		return
	end
	local char = MovementObj.char
	local hum = char:FindFirstChildOfClass("Humanoid")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local DodgeCancelAnim = hum.Animator:LoadAnimation(WeaponAnims[currentWeapon].Dodging.DodgeCancel)
	if typeof(MovementObj.InfoTable.Dodge.Stop) == "function" then
		MovementObj.InfoTable.Dodge.Stop()
	end
	DodgeCancelAnim:Play()
	CancelCoolDown[MovementObj] = tick()
	DodgeCoolDowns[MovementObj] = 0
	MovementObj:ServerRequest("DodgeCancel")
end

return Dodge
