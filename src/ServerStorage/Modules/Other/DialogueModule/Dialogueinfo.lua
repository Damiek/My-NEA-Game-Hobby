local info = {}
local RS = game:GetService("ReplicatedStorage")
local TreeFolder = RS.Dialogues.Dialogue_Configs
local SoundService = game:GetService("SoundService")

export type DialogueInfo = {
    IsAPerson: boolean,
	Sound: Sound,
	Tree: Configuration,
	Font: string,
	Title: string,
}

local data = {
	["Æon"] = {
        IsAPerson = true,
		Sound = SoundService.SFX.NPCs.bleep018,
		Tree = TreeFolder.Tutorial,
		Font = "MinecraftFont",
		Title = "<corrupt:1> The Start of the End </corrupt>",
	},

	["Shadow_master0989"] = {
        IsAPerson = true,
		Sound = SoundService.SFX.NPCs.bleep018,
		Tree = TreeFolder.Tutorial,
		Font = "MinecraftFont",
		Title = "<shake>The Niall Gazer</shake>",
	},

    ["Box"] = {
        IsAPerson = false,
		Sound = SoundService.SFX.NPCs.bleep018,
		Title = "Its just a box...",
	},

    ["Campfire"] = {
        IsAPerson = false,
		Sound = SoundService.SFX.NPCs.bleep018,
		Title = "Campfire",
	},
}

function info.GetInfo(NPCName: string): DialogueInfo?
	local name = tostring(NPCName)
	print(name)
	return data[name]
end

return info
