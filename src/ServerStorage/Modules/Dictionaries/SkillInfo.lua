local SkillInfo = {}

SkillInfo.Elements = {
	Astral = {
		R = {
			Mode1 = { Name = "", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
		Z = {
			Mode1 = { Name = "", Type = "Light", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Light", ParryInterupt = true },
		},
		X = {
			Mode1 = { Name = "", Type = "Light", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Light", ParryInterupt = true },
		},
		C = {
			Mode1 = { Name = "", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
		V = {
			Mode1 = { Name = "", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
	},
	Bone = {
		R = {
			Mode1 = { Name = "WeaponSwap", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
		Z = {
			Mode1 = { Name = "", Type = "Light", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Light", ParryInterupt = true },
		},
		X = {
			Mode1 = { Name = "", Type = "Light", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Light", ParryInterupt = true },
		},
		C = {
			Mode1 = { Name = "", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
		V = {
			Mode1 = { Name = "", Type = "Heavy", ParryInterupt = true },
			Mode2 = { Name = "", Type = "Heavy", ParryInterupt = true },
		},
	},
}

SkillInfo.Stats = {
	WPN = {
		SlashStorm = {
			Name = "SlashStorm",
			Type = "Heavy",
			ParryInterupt = false,
			Costs = {
				Stamina = 15,
			},
		},
	},
	DEX = {},
	STR = {},
	AGL = {},
	SPT = {},
}

function SkillInfo.getSkill(skillName)
	for _, statFolder in pairs(SkillInfo.Stats) do
		if statFolder[skillName] then
			return statFolder[skillName]
		end
	end

	for _, element in pairs(SkillInfo.Elements) do
		for _, slot in pairs(element) do
			for _, mode in pairs(slot) do
				if mode.Name == skillName then
					return mode
				end
			end
		end
	end

	return nil
end

-- NPC skills keyed by mob name (populate when mobs are added)
-- SkillInfo.NPCs = {
-- 	["MobName"] = {
-- 		SkillName = "Heavy"
-- 		Z = { Name = "", Type = "Light" },
-- 		X = { Name = "", Type = "Light" },
-- 		C = { Name = "", Type = "Heavy" },
-- 	},
-- }

return SkillInfo
