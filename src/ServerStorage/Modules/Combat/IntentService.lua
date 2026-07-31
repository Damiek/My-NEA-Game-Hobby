local IntentService = {}

local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules

local function GetCombatObject(char, npc)
    local plr = Players:GetPlayerFromCharacter(char)
    if plr then
        local success, PlrObjectService = pcall(require, SSModules.Objects.plr)
        if success then
            return PlrObjectService.GetPLRFromPlayer(plr)
        end
        return nil
    end
    return npc
end

function IntentService.SetIntent(char, npc, intent)
    local obj = GetCombatObject(char, npc)
    if obj then
        obj.Intent = intent
    end
end

return IntentService