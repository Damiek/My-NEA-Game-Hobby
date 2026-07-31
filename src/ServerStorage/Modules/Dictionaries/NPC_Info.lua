local NPC_Info = {}

local info = {
	["TestNPC"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 12,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["ShootingStar"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["FracturedKunai"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["TestNPC2"] = {
		Difficulty = "Elite",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["Bandit"] = {
		Difficulty = "Elite",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Chest = false,
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["Asmondaios"] = {
		Difficulty = "Boss",
		Race = "Celestial",
		MobType = "Humanoid",
		Element = "Bone",
		Chest = true,
		ChestType = "...",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},
}

AIParams = {
	SmallFry = {
		AggroRange = 30,
		AttackRange = 8,
		ReactionTime = 0.5,
		LowHealthThreshold = 0.25,
		RetreatDuration = 1.5,
		BlockChance = 0.25,
		ParryChance = 0.15,
		HyprParryChance = 0.03,
		DodgeChance = 0.15,
		StaminaCost = 2,
	},
	MiniBoss = {
		AggroRange = 40,
		AttackRange = 10,
		ReactionTime = 0.35,
		LowHealthThreshold = 0.3,
		RetreatDuration = 1.2,
		BlockChance = 0.4,
		ParryChance = 0.25,
		HyprParryChance = 0.05,
		DodgeChance = 0.2,
		StaminaCost = 2,
	},
	Elite = {
		AggroRange = 50,
		AttackRange = 12,
		ReactionTime = 0.2,
		LowHealthThreshold = 0.35,
		RetreatDuration = 0.8,
		BlockChance = 0.6,
		ParryChance = 0.4,
		HyprParryChance = 0.08,
		DodgeChance = 0.3,
		StaminaCost = 2,
	},
	SuperEnemy = {
		AggroRange = 60,
		AttackRange = 14,
		ReactionTime = 0.15,
		LowHealthThreshold = 0.4,
		RetreatDuration = 0.4,
		BlockChance = 0.7,
		ParryChance = 0.5,
		HyprParryChance = 0.12,
		DodgeChance = 0.4,
		StaminaCost = 2,
	},

	Boss = {
		AggroRange = 60,
		AttackRange = 14,
		ReactionTime = 0.15,
		LowHealthThreshold = 0.4,
		RetreatDuration = 0, -- bosses likely never retreat
		BlockChance = 0.6,
		ParryChance = 0.4,
		DodgeChance = 0.3,
		StaminaCost = 2,
	},
}

function NPC_Info.getStats(npc)
	return info[npc]
end

-- NEW: lookup AI params by Difficulty tier
function NPC_Info.getAIParams(difficulty)
	return AIParams[difficulty]
end

return NPC_Info
