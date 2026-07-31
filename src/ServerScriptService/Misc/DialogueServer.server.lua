local SS = game:GetService("ServerStorage")
local RS= game:GetService("ReplicatedStorage")

local DialogueEvent:RemoteEvent = RS:FindFirstChild("DialogueRemote",true)
local Inforequest :RemoteFunction = RS:FindFirstChild("InfoRequest",true)

local SSModules = SS.Modules
local Dialogue = require(SSModules.Other.DialogueModule)
local DialogueInfo = require(SSModules.Other.DialogueModule.Dialogueinfo)



DialogueEvent.OnServerEvent:Connect(function(plr,npc)
    if not plr or not npc then return end 
    Dialogue.StartDialogue(npc, plr)
end)


Inforequest.OnServerInvoke = function(plr, npc)
    if not plr or not npc then return nil end 

    local data = DialogueInfo.GetInfo(npc.Name)

    return data
end

