local module = {}







local info = {
	["Fists"] = {
		Damage = 10,
		Scaling = 10,
		BlockDmg = 6.6,
		Knockback = 4,
		RagdollTime = 1.2,
		SwingReset = 0.08, -- was .25
		SwingFade = 0.15,
		StunTime = 1,
		BlockingWalkSpeed = 6,
		ChipDamage = 0,
		HitboxSize = Vector3.new(4, 5, 6),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},

	["Fractured_Kunai"] = {
		Damage = 8,
		Scaling = 10,
		BlockDmg = 6.6,
		Knockback = 5,
		RagdollTime = 1.2,
		SwingReset = 0.15,
		SwingFade = 0.15,
		StunTime = 1.5,
		BlockingWalkSpeed = 6,
		ChipDamage = 5,
		HitboxSize = Vector3.new(6, 6, 6),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},

	["Katana"] = {
		Damage = 10,
		Scaling = 10,
		BlockDmg = 10,
		Knockback = 5,
		RagdollTime = 1.2,
		SwingReset = 0.225,
		SwingFade = 0.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		ChipDamage = 0,
		HitboxSize = Vector3.new(6, 6, 6),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},

	["DrakeFang"] = {
		Damage = 25,
		Scaling = 10,
		BlockDmg = 12,
		Knockback = 5,
		RagdollTime = 1.2,
		SwingReset = 0.23,
		SwingFade = 0.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		ChipDamage = 0,
		HitboxSize = Vector3.new(6, 6, 6),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},

	["TwinSpears"] = {
		Damage = 18,
		Scaling = 9,
		BlockDmg = 12,
		Knockback = 5,
		RagdollTime = 1.2,
		SwingReset = 0.2,
		SwingFade = 0.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		ChipDamage = 0,
		HitboxSize = Vector3.new(6, 5, 9),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},

	["ShootingStar"] = {
		Damage = 21,
		Scaling = 10,
		BlockDmg = 25,
		Knockback = 6,
		RagdollTime = 1.5,
		SwingReset = 0.25,
		SwingFade = 0.25,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		ChipDamage = 10,
		HitboxSize = Vector3.new(4, 5, 6),
		HitboxOffset = CFrame.new(0, 0, -2.3),
	},
}

export type WeaponData = typeof(info.Fists)

function module.getStats(weapon): WeaponData
	return info[weapon]
end




return module
