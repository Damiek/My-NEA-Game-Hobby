local info = {}
local RS = game:GetService("ReplicatedStorage")
local TreeFolder = RS.Dialogues.Dialogue_Configs
local  SoundService = game:GetService("SoundService")



export type DialogueInfo = {
    Sound:Sound,
    Tree:Configuration,
    Font: string,
    Title: string
}

local data = {
    ["Æon"] = {
        Sound = SoundService.SFX.NPCs.bleep018,
        Tree =  TreeFolder.Tutorial,
        Font = "MinecraftFont",
        Title = "<shake>The Start of the End<shake>"
    },

     ["Shadow_master0989"] = {
        Sound = SoundService.SFX.NPCs.bleep018,
        Tree =  TreeFolder.Tutorial,
        Font = "MinecraftFont",
        Title = "<shake>The Niall Gazer<shake>"
    }

   

    

}





function info.GetInfo(NPCName:string) :DialogueInfo?
    local name = tostring(NPCName)
    print(name)
    return data[name]
end

return info 