local StatusEffectsModule = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local Dictionaries = SSModules.Dictionaries
local Effect_Dictionary = require(Dictionaries.Effect_Info)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local Signal = require(RS.Modules.Packages.Signal)



local Events = RS.Events
local VFXFolder = RS.Effects
local UI_Update_Event = Events.UI_Update
local VFX_Event = Events.VFX


-- Tables and functions
local ActiveStatusEffects = Combat_Data.ActiveStatusEffects




StatusEffectsModule.Signal = Signal.new()





function StatusEffectsModule.ApplyStatusEffect(char,npc,effectName, stacks, Duration)
    local plr = game.Players:GetPlayerFromCharacter(char)
    local identifier = plr or npc

    local effectInfo = Effect_Dictionary.getEffectInfo(effectName)

    if not effectInfo then
        warn("Status effect '" .. effectName .. "' does not exist in the Effect Dictionary.")
        return
    end

    if not ActiveStatusEffects[identifier] then
        ActiveStatusEffects[identifier] = {}
    end

    -- Check for combinations BEFORE inserting
    local comboTriggered = false
    local matchedEffect = nil

    for _, activeEffect in ipairs(ActiveStatusEffects[identifier]) do
        local comboName = Effect_Dictionary.checkCombination(effectName, activeEffect.Name)
        if comboName then
            matchedEffect = activeEffect.Name
            comboTriggered = true

            print("Combination triggered:", comboName)

            local comboInfo = Effect_Dictionary.getEffectInfo(comboName)
            table.insert(ActiveStatusEffects[identifier], {
                Name = comboName,
                Stacks = 1,
                Duration = comboInfo and comboInfo.BaseDuration or 5,
                TimeApplied = tick(),
            })

            if plr then
                UI_Update_Event:FireClient(plr, "StatusEffectAdded", comboName, 1)
            end
            break -- Stop checking after first combo match
        end
    end

    if comboTriggered then
        -- Remove the matched ingredient AFTER the loop
        StatusEffectsModule.RemoveStatusEffect(char, matchedEffect)
        -- Don't insert the incoming effect — it was consumed by the combo
        return
    end

    if ActiveStatusEffects[identifier][effectName] then
        ActiveStatusEffects[identifier][effectName].Stacks += stacks or 1
        ActiveStatusEffects[identifier][effectName].Duration = Duration or effectInfo.BaseDuration
        ActiveStatusEffects[identifier][effectName].TimeApplied = tick()
    else
        local newEffect = {
            Name = effectName,
            Stacks = stacks or 1,
            Duration = Duration or effectInfo.BaseDuration,
            TimeApplied = tick(),
        }
        ActiveStatusEffects[identifier][effectName] = newEffect
    end

    if plr then UI_Update_Event:FireClient(plr, "StatusEffectAdded", effectName, stacks)  end
    --VFX_Event:FireAllClients("CombatEffects", effectInfo.VFX, char.HumanoidRootPart.Position)
    VFX_Event:FireAllClients("HighlightBlink", char, effectInfo.HighlightColor, ActiveStatusEffects[identifier][effectName].Duration, 0.5)
    StatusEffectsModule.Signal:Fire(char,npc,"StatusEffectAdded", effectName)
    print("Signal sent for",char)
end





function StatusEffectsModule.RemoveStatusEffect(char,npc, effectName)
    local plr = game.Players:GetPlayerFromCharacter(char)
    local identifier = plr or npc

    
    if not ActiveStatusEffects[identifier] then return end

    for i, effect in pairs(ActiveStatusEffects[identifier]) do
        print(effectName)
        if effect.Name == effectName then
            ActiveStatusEffects[identifier][i] = nil
            if plr then UI_Update_Event:FireClient(plr, "StatusEffectRemoved", effectName) end
            break
        end
    end
end





return StatusEffectsModule