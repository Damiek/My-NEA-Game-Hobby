local module = {}
local info ={
	["Fists"]={
		Damage = 8,
		BlockDmg = 6.6,
		Knockback =4,
		RagdollTime =1.2,
		SwingReset =0.3,
		StunTime = 1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6),

	},
	
	["Fractured_Kunai"]={
		Damage = 15,
		BlockDmg = 6.6,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =0.25,
		StunTime = 1.5,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5.5, 6),
	},
	 
	["Katana"]={
		Damage = 10,
		BlockDmg = 10,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6),
	},
	
	["DrakeFang"]={
		Damage = 15,
		BlockDmg = 12,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.1,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6.219),
	},

	
  ["Scythe"]={
		Damage = 25,
		BlockDmg = 20,
		Knockback = 8,
		RagdollTime =1.5,	
		SwingReset = .75,
		StunTime = 1.2,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6.219),
  },
  
	["Shooting Star"]={
		Damage = 25,
		BlockDmg = 20,
		Knockback = 8,
		RagdollTime =1.5,	
		SwingReset = .75,
		StunTime = 1.2,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6.219),
	},
	
	["Glock"]={
		Damage = 25,
		BlockDmg = 20,
		Knockback = 8,
		RagdollTime =1.5,	
		SwingReset = .15,
		StunTime = 1.2,
		BlockingWalkSpeed = 6,
		HitboxSize = Vector3.new(4, 5, 6.219),
	},





  
  
		
	
}
function module.getStats(weapon)
	return info[weapon]
end
return module
