local SkillMasterController = {}

local STAT_FOLDERS = { "WPN", "DEX", "STR", "AGL", "SPT" }

local ActiveSkills = {}

local SkillLookup = {}

for _, folderName in ipairs(STAT_FOLDERS) do
	local folder = script:FindFirstChild(folderName)
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") then
				SkillLookup[child.Name] = require(child)
			end
		end
	end
end

function SkillMasterController.OnSkillCalled(plr, skillName)
	if not plr or type(skillName) ~= "string" then
		return
	end

	local char = plr.Character
	if not char or not char:FindFirstChildOfClass("Humanoid") then
		return
	end

	local skillModule = SkillLookup[skillName]
	if not skillModule then
		warn("[SkillMasterController] Unknown skill:", skillName)
		return
	end

	local stopFn = skillModule.start(char, nil)
	if not stopFn and skillModule.stop then
		stopFn = function()
			skillModule.stop(char, nil)
		end
	end

	if stopFn then
		ActiveSkills[plr] = stopFn
	end
end

function SkillMasterController.CleanupForPlayer(identifier)
	if ActiveSkills[identifier] then
		pcall(ActiveSkills[identifier])
		ActiveSkills[identifier] = nil
	end
end

return SkillMasterController
