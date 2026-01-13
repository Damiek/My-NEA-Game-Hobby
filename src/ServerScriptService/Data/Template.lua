return {
	GENARAL_PLAYER_INFO={
		IsAdmin = false,
		Number_of_Slots = 1,


		Bank = {},
		BankCash = {
			Gold =0,
			Silver =0,
			Copper =0,
		},
		Number_of_Bankslots = 2,
		
        

		Banned = false,
		Ban_Reason = "...",
		Ban_Date = "...",
		Ban_Duration = "...",


	     

	},
	
	SLOT_1 = {
		--- Actual Slot information
		Current_Slot= "1",
		Diffculty = "...",  -- Standard or Skill Check
		Is_Tainted = false, -- This Means if the slot is wiped or not




		--- Race and Customisation information

		Race = "Mortal",
		Character_Name = "...",
		Character_LastName = "...",
		Sub_Race = "...",
		Flaw = "...",
		Appearance  = {
			Gender = "...",
			Eyes = "",
			Mouth = "",
			Skin_Tone = "",
			HairIDs = {},
			Hair_Colour = "",
            Clothing = "...",

		},
			

     




		--- Combat information
		Weapon = "Fists";
		Element  = "...";
		Unlocked_Skills = {},
		Unlocked_Classes ={},
		Disabled_Classes = {},
		Disabled_Skills = {},





		-- Inventory information
		Inventory = {},
		Hotbar = {
			Slot1 = nil,
			Slot2 = nil,
			Slot3 = nil,
			Slot4 = nil,
			Slot5 = nil,
			Slot6 = nil,
			Slot7 = nil,
			Slot8 = nil,
			Slot9 = nil,
			Slot10 = nil,
		},
		Cash = {
			Gold =0,
			Silver =0,
			Copper =0,
		},


		-- EXP and Level Information
		GeneralExp = 0, -- The Genaral EXP used for leveling up and converting to Atrribute EXP
		Level = 1,  -- Player Level
		FreePoints = 0, -- Free Points to spend on Attributes without the need for EXP
		SkillPoints = 0, -- Points used to unlock skills and talents
		AttributeExp = {
			Vitality = 0,
			Endurance = 0,
			Strength =0,
			Spirit = 0,
			Dexterity = 0,
			Agility = 0,
			WeaponProficiency = 0,
		},
		
		
		
		-- Stats information
		STAT_POINTS = {
			Vitality = 10,
			Endurance = 10,
			Strength =10,
			Dexterity =10,
			Spirit = 10,
			Agility= 10,
			WeaponProficiency = 10,
		},



	},

	
	
	

		
}