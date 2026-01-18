local module = {}
local module = {}
local info ={
	["Bone"]={
		Mode1 = "TwinSpears",
		Mode2 = "TwinSpears",
		Mode1Callout= "Succumb to the Madness, Kaosu no keshin",
		Mode2Callout = "...",
		Text = {
			"<h>Chaos_InCarnate<h><sound:rbxassetid://98570702510642>It seems I need to drop the funny guy act huh<sound:rbxassetid://98570702510642>",
			"<h>Fait<h><sound:rbxassetid://137940291335732> Well no, doofus<sound:rbxassetid://137940291335732>",
			"<h>Chaos_InCarnate<h><sound:rbxassetid://98570702510642><shake>Ow !</shake> my Bad, So we need to pull out all the stops then<sound:rbxassetid://98570702510642>",
			"<h>???<h><shake><colour:#FF0000>Crazy</colour:#FF0000></shake> monkey!",

			
		}
	},
	
	["Astral"]={
		Mode1 = "Fractured_Kunai",
		Mode2 = "Shooting Star",
		Mode1Callout= "Gaze Upon the Stars, Noctis Tempore",
		Mode2Callout = "Segunda Etpa, Astra Parallaxis ",
		Text = {
			"Hello"


		}
	},
	
	["Brute"]={
		Mode1 = "Hakuda",
		Mode2 = "OGA",
		Mode1Callout= "Gaze Upon the Stars, Noctis Tempore",
		Mode2Callout = "This ends now, Yoi Ude Ippon",
		Text = {
			""

		}
	},

	


}
function module.getStats(Element)
	return info[Element]
end
return module

