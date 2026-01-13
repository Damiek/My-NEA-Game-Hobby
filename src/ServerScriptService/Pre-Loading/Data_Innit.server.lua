local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.Data.Modules.ProfileStore)

local function GetStoreName()
    return  RunService:IsStudio() and "Test" or "Live"
end

local Template = require(ServerScriptService.Data.Template)
local DataManager = require(ServerScriptService.Data.Modules.DataManager)

-- Acessing profile Store
local PlayerStore = ProfileStore.New(GetStoreName(), Template)

local function PlayerAdded(plr : Player)
    -- Start a new player session
    local profile = PlayerStore:StartSessionAsync("Player_".. plr.UserId, {
        Cancel = function()
            return plr.Parent ~= Players
        end,
    })

    -- Sanity check to ensure profile exists

    if profile ~= nil then
        profile:AddUserId(plr.UserId)  -- GDPR compliance
        profile:Reconcile()  -- Fill in any missing data from template


        -- Session Locking
        profile.OnSessionEnd:Connect(function()
            DataManager.Profiles[plr] = nil
            plr:Kick("Your session has ended. Please rejoin.")
        end)
       -- Saves the profile to the DataManager
        if plr.Parent == Players then 
            DataManager.Profiles[plr] = profile
        else
            profile:EndSession()
        end





    else
        -- Could not load profile.
        plr:Kick("Could not load your data. Please try again later.")
    end


end

-- Early Joiners Check
for i,plr in Players:GetPlayers() do
    task.spawn(PlayerAdded, plr)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(plr)
 local profile = DataManager.Profiles[plr]
 if not profile then return end
 profile:EndSession()
 DataManager.Profiles[plr] = nil
end)
