local Campfire = {}
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules
local MovementObj = require(RSModules.Movement.Objects.Movement)
local RestModule =require(RSModules.Movement.Mechnanics.Resting)





function Campfire.OnInteract(self: Model, plr: Player)
	print("Campfire interact", self.Name, plr.Name)
	if not self and not plr then return end 
	local obj = MovementObj.GetMovementObj(plr)
	if not obj then return end 
	RestModule.Start(obj)
end

return Campfire
