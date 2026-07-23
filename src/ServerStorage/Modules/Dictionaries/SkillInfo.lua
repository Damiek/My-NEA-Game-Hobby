local SkillInfo = {}

SkillInfo.Elements = {
	Astral = {
		R = {
			Mode1 = { Name = "", Type = "Heavy" },
			Mode2 = { Name = "", Type = "Heavy" },
		},
		Z = {
			Mode1 = { Name = "", Type = "Light" },
			Mode2 = { Name = "", Type = "Light" },
		},
		X = {
			Mode1 = { Name = "", Type = "Light" },
			Mode2 = { Name = "", Type = "Light" },
		},
		C = {
			Mode1 = { Name = "", Type = "Heavy" },
			Mode2 = { Name = "", Type = "Heavy" },
		},
	},
	Bone = {
		R = {
			Mode1 = { Name = "WeaponSwap", Type = "Heavy" },
			Mode2 = { Name = "", Type = "Heavy" },
		},
		Z = {
			Mode1 = { Name = "", Type = "Light" },
			Mode2 = { Name = "", Type = "Light" },
		},
		X = {
			Mode1 = { Name = "", Type = "Light" },
			Mode2 = { Name = "", Type = "Light" },
		},
		C = {
			Mode1 = { Name = "", Type = "Heavy" },
			Mode2 = { Name = "", Type = "Heavy" },
		},
	},
}

SkillInfo.Stats = {
	DEX = {},
	STR = {},
	AGL = {},
	SPT = {},
}

-- NPC skills keyed by mob name (populate when mobs are added)
-- SkillInfo.NPCs = {
-- 	["MobName"] = {
-- 		R = { Name = "", Type = "Heavy" },
-- 		Z = { Name = "", Type = "Light" },
-- 		X = { Name = "", Type = "Light" },
-- 		C = { Name = "", Type = "Heavy" },
-- 	},
-- }

return SkillInfo
