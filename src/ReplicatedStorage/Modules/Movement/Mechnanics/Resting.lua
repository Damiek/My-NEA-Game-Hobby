local RestingModule = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RSModules = RS.Modules
local SSModules = SS.Modules
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)
local HelpfulModule = require(RSModules.ClientHelpfull)
local WeaponAnimations = RS.Animations.Weapons

local Restcooldowns = {}


local function StartResting(MovementObj:MovementTypes.MovementObj)
    local char = MovementObj.char
    local currentWeapon = char:GetAttribute("CurrentWeapon")
    local hum = char.Humanoid
    if not char or not hum or currentWeapon or MovementObj.States.IsResting then return end 
    local restingAnim = hum.Animator:LoadAnimation(WeaponAnimations[currentWeapon].Movement.Resting)
    restingAnim:Play()
    MovementObj.States.IsResting = true
    MovementObj:ClearWalkAnims()
    



    local function RestStop()
        if not MovementObj.States.IsResting then return end 
        restingAnim:Stop()
        Restcooldowns[MovementObj] = tick()
        MovementObj:UpdateWalkTracks()
    end
end

function RestingModule.Start(MovementObj:MovementTypes.MovementObj)
    if Restcooldowns[MovementObj] and tick() - Restcooldowns[MovementObj] < 0.05 then return end  -- just a debounce not an actual cooldown
    if MovementObj.States.IsResting then return end 
    StartResting(MovementObj)
    
end

return RestingModule