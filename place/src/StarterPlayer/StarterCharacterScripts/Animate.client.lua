local RunService = game:GetService("RunService")

local plr = game.Players.LocalPlayer
local char = plr.Character
local HRP = char.HumanoidRootPart
local Hum = char.Humanoid

local AnimationsFolder = script.Animations

local AnimationsTable ={
	["WalkForward"] = Hum:LoadAnimation(AnimationsFolder.WalkFoward),
	["WalkRight"] = Hum:LoadAnimation(AnimationsFolder.WalkRight),
	["WalkLeft"] = Hum:LoadAnimation(AnimationsFolder.WalkLeft),
}

for _, Animation in AnimationsTable do


	Animation:Play(0,0.01,0)


end


RunService.RenderStepped:Connect(function()
	local DirectionOfMovement = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)
	local Forward = math.abs(math.clamp(DirectionOfMovement.Z/Hum.WalkSpeed,-1,-0.001))
	local Backwards = math.abs(math.clamp(DirectionOfMovement.Z/Hum.WalkSpeed,0.001,1))
	local Right = math.abs(math.clamp(DirectionOfMovement.X/Hum.WalkSpeed,0.001,1))
	local Left = math.abs(math.clamp(DirectionOfMovement.X/Hum.WalkSpeed,-1,-0.001))


	local SpeedUnit = (DirectionOfMovement.Magnitude/Hum.WalkSpeed)


	if DirectionOfMovement.Z/Hum.WalkSpeed < 0.1 then

		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkRight:AdjustWeight(Right)
		AnimationsTable.WalkLeft:AdjustWeight(Left)

		AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)

	else
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkRight:AdjustWeight(Left)
		AnimationsTable.WalkLeft:AdjustWeight(Right)

		AnimationsTable.WalkForward:AdjustSpeed((SpeedUnit) * -1)
		AnimationsTable.WalkRight:AdjustSpeed((SpeedUnit) * -1)
		AnimationsTable.WalkLeft:AdjustSpeed((SpeedUnit) * -1)

	end




end)