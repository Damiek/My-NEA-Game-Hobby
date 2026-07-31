local RS= game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local text = require(RS.Modules.text)
local Prox:ProximityPrompt = workspace.Tester.STart


local DialogueParams = {
    Speaker = "Tutorial, The Start of The End",
    Font = "MinecraftFont",
    Sound = SoundService.SFX.NPCs.bleep018,
  
}
local DialogueParams2 ={
	Speaker ="Tutorial",
	Font = "ComicSans",
    Sound = SoundService.SFX.NPCs.bleep018,
}

task.wait(10)
print("Yo Bro Dialouge InComing")
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.Tutorial,DialogueParams)


Prox.Triggered:Connect(function()
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.TestDialogue,DialogueParams2)
end)

-- ignore
text.UI_Set(nil)

--[[
This is the gist of everything
Mkae dialogue Node tree in studio 
Make Dialogue Params as seen above 




-- Later Stuff
Turn this into a module that can automatic go through dictionaries with all the dialogue params
The Module should also be able to so all the remote firing
Yeah thats about it for now

]]