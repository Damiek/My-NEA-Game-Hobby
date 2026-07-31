local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local InventoryManager = require(SS.Modules.Other.InventoryManager)
local Helper = require(SS.Modules.Other.Helpful)

local Events = RS.Events
local InventoryEvent = Events.InventoryEvent

  --[[
TODO : add validation here 
]]







local function PickupItem(item)
    if item.Parent ~= workspace.ActiveItems then return end
    
    local touchConn
    touchConn = item.Touched:Connect(function(hit)
        local char = hit.Parent
        if char and char:FindFirstChildOfClass("Humanoid") then
            local plr = game.Players:GetPlayerFromCharacter(char)
            if plr then
                InventoryManager.AddItem(plr, item.Name, item:GetAttribute("Count") or 1)
                print("Item Get!")
                item:Destroy()
                touchConn:Disconnect()
            end
        end
    end)
end

for _, item in ipairs(CS:GetTagged("Item")) do
    PickupItem(item)
end


CS:GetInstanceAddedSignal("Item"):Connect(PickupItem)





InventoryEvent.OnServerEvent:Connect(function(plr, action, tool,Count)
    local char:Model = plr.Character  
    if not char then return end
    if action == "Drop" then
        if Helper.CheckForAttributes(char, true, true, true, nil, false, true, true, true) then return end
        if char:GetAttribute("InCombat") then return end  -- We cant drop stuff in combat
        InventoryManager.DropItem(plr, tool, 1)
    end

    if action == "HotbarUpdate" then
        
    end
end)
   





