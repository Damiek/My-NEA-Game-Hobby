local module = {}
local RS = game:GetService("ReplicatedStorage")
local Events = RS.Dialogues.DialogueEvents
local DialogueRemote: RemoteEvent = Events.DialogueRemote

local InfoTable = require(script.Dialogueinfo)

export type DialogueInfo = {
	Speaker: string,
	ViewportModel: Model,
	Font: string,
	Sound: Sound,
}

--[[
 My plan for this is basically every dialouge npc is going to have a hard coded dialogue tree that spilts into smaller dialogue trees 

 The idea is that  the NPC itself is passed as a parramter

 then its Name is going ro be stored as a key next 

 the table for all the  dialogue npc info would then bee quired for stuff such as soundbyte font ,and the the dialogue tree itself 

 the table will will look something like this 

 ["Lunaris"] = {
    Sound =  SS.SFX.NPCS.Bleep2
    Tree = RS.Dialogues.Dialogues_configs.Lunaris
    Font = "Some random font"
 }

 now the function itself i obviously need to add the plr as a parramter this would just be taken for the proity prompt same thing with the NPC itself

local NPCDialogueinfo = NPCDialogueModle.GetInfo(NPC.Name)



local DialogueInfo = {
ViewportModel = NPC
Speaker = NPC.Name
Font = NPCDialogueinfo.font
Sound = NPCDialogueinfo.Sound
Title = "The Extintion Event of Reality"
}

local tree = NPCDialogueinfo.Tree

DialogueRemote:FireClient(plr,tree,DialogueParams)

-- Only problem is that right now some npcs which are not main cast members nor side cast memebers and won't speical dialogue trees 
right now a possible solotion is a bool Value called "Important"

if that set to true then we can index the npcinfo with their name as usual  and if that set to false we can prob we will need to find what type of NPC they are :
("Civllain","[Whateverfacton]Guard","[NPCNAME]_RandomEncouter")

Also now that i am actually thinking of this i need to research of the condition node works because i certain reponses and Dialogues are going to locked under certain restrictions 
right now i am thinking of using script nodes to handle all that by connecting multiple trees (Using a another function i wll write called Followup)
however if I want a certain reponse be locked uder the same prompt node it means i would have a make a whole new tree which is just a waste of my time.....

oh well i firgure out this later lets just the basics first

--Aeon


]]
--

function module.StartDialogue(NPC: Model, plr: Player)
	if not NPC or not plr then
		return
	end

	local info = nil
	local ImportantFlag = NPC:FindFirstChild("ImportantFlag")

	if ImportantFlag and ImportantFlag.Value == true then
		info = InfoTable.GetInfo(NPC.Name)
	end

	if not info then
		print("Info missing for", NPC.Name)
	end


	local speakerDisplay = NPC.Name

	if info.Title and info.Title ~= "" then
		speakerDisplay = NPC.Name .. ", " .. info.Title
	end

	local Parrams: DialogueInfo = {
		Font = nil,
		Speaker = nil,
		Sound = nil,
		ViewportModel = nil,
	}

	Parrams.Font = info.Font
    Parrams.Speaker = speakerDisplay
    Parrams.Sound = info.Sound

	if info.IsAPerson then
		Parrams.ViewportModel = NPC
	end
    

	print(plr,info.Tree,Parrams)


	print(DialogueRemote)



	DialogueRemote:FireClient(plr,info.Tree,Parrams)	
end




return module
