local AccessoriesManager = {}
local RS = game:GetService("ReplicatedStorage")
local Models = RS.Models
local Welds = RS.Welds
local Events = RS.Events
local Tool_Folder = RS.Tools



local AccessoriesFolder = Models.Accessories
local AccessoriesTools = Tool_Folder.Items.Accessories
local WeldsFolder = Welds.Accessories

local AcessoryWelds = {}

local AccessoryEvent = Events.AccessoryEvent

--[local Functions]--
local function GetAccessory(accessoryName)
    local accessory = AccessoriesFolder:FindFirstChild(accessoryName) --- This gets the accessory from ReplicatedStorage
    if accessory then
        return accessory:Clone() -- Clone the accessory to give each player their own copy
    else
        warn("Accessory not found:", accessoryName) -- Just incase I forgot to add it to the folder
        return nil
    end
end


local function ReturnAccessory(char, plr : Player, OldAccessory)
    local backpack  = plr.Backpack

    local accssoryType = OldAccessory:GetAttribute("AccessoryType") -- This checks what type of accessory it is (Hat, face, torso , Legs, Rings Artefacts etc)

    if OldAccessory then
        local accessoryTool = AccessoriesTools:FindFirstChild(OldAccessory.Name):Clone()
        accessoryTool.Parent = backpack
        OldAccessory:Destroy()
    end

    if AcessoryWelds[plr] and AcessoryWelds[plr][accssoryType] then
        AcessoryWelds[plr][accssoryType].Part1 = nil
    end
    
end


local function Part0Finder(char, accessoryType) -- This function finds the base part to weld the accessory to based on the accessory type
    if accessoryType == "Hat" then
        return char:FindFirstChild("Head")
    elseif accessoryType == "Face" then
        return char:FindFirstChild("Head")
    elseif accessoryType == "Torso" then
        return char:FindFirstChild("Torso")
    elseif accessoryType == "Legs" then
        return char:FindFirstChild("Right Leg")
    elseif accessoryType == "Rings" then
        return char:FindFirstChild("Left Arm")  
    elseif accessoryType == "Artefacts" then
        return char:FindFirstChild("Torso") 
    elseif accessoryType == "Collar" then
        return char:FindFirstChild("Torso") 
    else
        return nil
    end
end






--[Actual Module functions]--

function AccessoriesManager.EquipAccessory(char, accessoryName) -- This is the equiping function
    local plr = game.Players:GetPlayerFromCharacter(char)
    local LeftLeg = char:FindFirstChild("Left Leg")
  

    local accessory = GetAccessory(accessoryName)
    local accssoryType = accessory:GetAttribute("AccessoryType") -- This checks what type of accessory it is (Hat, face, torso , Legs, Rings Artefacts etc)
    accessory.Parent = char.Accessories
    

    if not AcessoryWelds[plr] then
        AcessoryWelds[plr] = {}
    end

    if not AcessoryWelds[plr][accssoryType]  then 
        AcessoryWelds[plr][accssoryType] = WeldsFolder:FindFirstChild(accessoryName):Clone() 
    end
    -- This gets the corresponding weld from ReplicatedStorage
    AcessoryWelds[plr][accssoryType].Parent = char.Accessories.Welds
    

    if AcessoryWelds[plr][accssoryType].Part1 then
        -- If there is already an accessory of this type equipped, return it to the player's backpack
    
        local existingAccessory = AcessoryWelds[plr][accssoryType].Part1
        if existingAccessory then
            ReturnAccessory(char, plr, existingAccessory)
        end
    end
    
    

    AcessoryWelds[plr][accssoryType].Part0 = Part0Finder(char, accssoryType) -- This sets Part0 of the weld to the correct body part
    if accessoryName == "Legs" then  -- This is a special case for the legs and torso accessory as it needs to weld to both legs and Arms
        local AcessoryPair = accessory:FindFirstChild("AcessoryPair")
        local AcessoryPairWeld = AcessoryPair.Weld
        AcessoryPairWeld.Part0 = LeftLeg
        AcessoryPairWeld.Part1 = AcessoryPair

    elseif accessoryName == "Torso" then
       local sides = {["LeftSeleve"] = "Left Arm", ["RightSeleve"] = "Right Arm"} 
        for modelName, bodyPart in pairs(sides) do
            local part = accessory:FindFirstChild(modelName)
            if part and part:FindFirstChild("ExtraWeld") then
                part.Weld.Part0 = char:FindFirstChild(bodyPart)
                part.Weld.Part1 = part
            end
        end

    end
   

    AcessoryWelds[plr][accssoryType].Part1 = accessory -- This sets Part1 of the weld to the correct Accessory
    AcessoryWelds[plr][accssoryType].C0 = Welds.Accessories[accessoryName].C0 -- Enables the weld to attach the accessory to the character
    AccessoryEvent:FireClient(plr,"RefreshAnimations") --- This fires to the client script handling walk cycles to refresh their animations

    
    
end

function AccessoriesManager.UnequipAccessory(char, accessoryName) -- This is the unequiping function
    local plr = game.Players:GetPlayerFromCharacter(char)
    local accessory = char.Accessories:FindFirstChild(accessoryName)
    if accessory then
        ReturnAccessory(char, plr, accessory)
    end
    AccessoryEvent:FireClient(plr,"RefreshAnimations") -- Same thing as before

end

function AccessoriesManager.cleanup(plr) -- Cleans up the welds when the player leaves
    if AcessoryWelds[plr] then
        AcessoryWelds[plr] = nil 
    end
end


--[[
    AccessoriesManager Module Yap
    Reminders: 
    When adding new accessories,remember to create corresponding welds in ReplicatedStorage.Welds.Accessories
    Also rememeber to as an Atrribute "AccessoryType" to the accessory in ReplicatedStorage.Models.Accessories

    Make sure the welds have the correct C0 values to position the accessories properly.
    Also make sure special accessories like "Legs" and "Torso" that may require additional handling that within the base accessory model that the AcessoryPair or Left/Right Seleve parts have welds set up to attach to the correct body parts.

    I may or not add to a check that checks that for the legs accessory and makes a secondary weld to the right leg.


    Functions:
    - EquipAccessory(char, accessoryName): Equips the specified accessory to the character.
    
    Usage:
    AccessoriesManager.EquipAccessory(character, "CoolHat")


    Welds Structure Idea:
    AccessoriesWelds{
        [player] = {
            ["Hat"] = WeldObject,
            ["Face"] = WeldObject,
            ["Torso"] = WeldObject,
            ["Legs"] = WeldObject,
            ["Artefacts"] = WeldObject,
            ["Rings"] = WeldObject
            ["Collar"] = WeldObject
        }
    }
]]


return AccessoriesManager