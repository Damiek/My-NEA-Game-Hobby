local module = {}


local info = {
    Races = {
        ["Celestial"] = {
            ["Seraphim"] = {
                PhysicalTraits = {
                    Top = {},
                    Middle = {},
                    Bottom = {},
                    Extras = {},
                },
                StatBonuses = { WNP = 3, SPT = 3, DEX = 1, END = 2 },
                Talents = {},
            },

            ["Arch-Draculain"] = {
                PhysicalTraits = {
                    Top = {},
                    Middle = {},
                    Bottom = {},
                    Extras = {},
                },
                StatBonuses = { WNP = 3, SPT = 3, DEX = 1, END = 2 },
                Talents = {},
            },

        },

        ["Mortal"] = {
            ["Human"] = {
                PhysicalTraits = {},
                StatBonuses = { WNP = 1, DEX = 1 },
                Talents = {},
            },

            ["Elf"] = {
                PhysicalTraits = { "Pointed ears" },
                StatBonuses = { DEX = 2, SPT = 1 },
                Talents = {},
            },

            ["Dullahan"] = {
                PhysicalTraits = { "" },
                StatBonuses = { END = 2 },
                Talents = {},
            },
            -- Crystalith, Feline, Rabbitkyn, Hyaenidae, etc.
        },
    },

    -- Anomaly = infection status layered onto an existing Mortal race,
   
    AnomalyData = {
        ["Human"] = {
            BaseRace = "Human", -- points back into Races.Mortal.Human for appearance/base talents
            InfectionTalents = {
                -- e.g. Waveform access, Balance drain, whatever's Anomaly-universal
            },
            StatModifiers = {
                -- deltas applied ON TOP of Races.Mortal.Human.StatBonuses, not a replacement
            },
        },

        ["Elf"] = {
            BaseRace = "Elf",
            InfectionTalents = {},
            StatModifiers = {},
        },
        -- only needs an entry once a Mortal race has actually had a documented Anomaly case
        
    },
}



return module

