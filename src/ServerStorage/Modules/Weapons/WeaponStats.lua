local module = {}
local info ={
	["Fists"]={
		Damage = 8,
		Scaling = 5,
		BlockDmg = 6.6,
		Knockback =4,
		RagdollTime =1.2,
		SwingReset =0.3,
		StunTime = 1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),

	},
	
	["Fractured_Kunai"]={
		Damage = 15,
		Scaling = 7,
		BlockDmg = 6.6,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =0.25,
		StunTime = 1.5,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),
	},
	 
	["Katana"]={
		Damage = 10,
		Scaling = 7,
		BlockDmg = 10,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),
	},
	
	["DrakeFang"]={
		Damage = 15,
		Scaling = 9,
		BlockDmg = 12,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.1,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),
	},

	["TwinSpears"]={
		Damage = 15,
		Scaling = 9,
		BlockDmg = 12,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.1,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),
	},

	
	["Shooting Star"]={
		Damage = 25,
		Scaling = 8,
		BlockDmg = 25,
		Knockback = 8,
		RagdollTime =1.5,	
		SwingReset = .75,
		StunTime = 1.2,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(6.152, 8.458, 11.534),
	},	
	
}
function module.getStats(weapon)
	return info[weapon]
end
return module
