local RS= game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local text = require(RS.Modules.text)



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


-- ignore
text.UI_Set(nil)

-- Adjust to your actual bone chain path/naming
local root = workspace.TailTest.Tail.Root
local minGravity = -200   -- root value
local maxGravity = -1000  -- tip value, start here and re-run to taste

local function applyGravityTaper(rootBone, minG, maxG)
    local chain = { rootBone }
    local current = rootBone
    while true do
        local nextBone
        for _, child in current:GetChildren() do
            if child:IsA("Bone") then
                nextBone = child
                break
            end
        end
        if not nextBone then break end
        table.insert(chain, nextBone)
        current = nextBone
    end

    local total = #chain
    for i, bone in chain do
        local t = (i - 1) / (total - 1) -- 0 at root, 1 at tip
        bone:SetAttribute("Gravity", Vector3.new(0, minG + (maxG - minG) * t, 0))
    end
end

applyGravityTaper(root, minGravity, maxGravity)

--[[
This is the gist of everything
Mkae dialogue Node tree in studio 
Make Dialogue Params as seen above 




-- Later Stuff
Turn this into a module that can automatic go through dictionaries with all the dialogue params
The Module should also be able to so all the remote firing
Yeah thats about it for now

]]