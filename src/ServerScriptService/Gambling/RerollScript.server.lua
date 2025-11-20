-- Define elements with rarity weights for each race
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rerollEvent = ReplicatedStorage.Events.RerollElement


local raceElementRarities = {
	SoulReaper = {
		Brute = 50,     -- Common
		Astral = 30,    -- Uncommon
		Bone = 20, -- Rare
	},
	Hollow = {
		Astral = 40,    -- Common
		Brute = 30,      -- Uncommon
		Fire = 20,     -- Rare
	},
	Quincy = {
		Water = 40,    -- Common
		Lightning = 30, -- Uncommon
		Earth = 20,    -- Rare
	}
}

-- Define race-specific restrictions for elements
local raceRestrictions = {
	SoulReaper = {"Brute", "Bone", "Astral"},  -- SoulReapers can use Fire, Water, Lightning
	Hollow = {"Brute", "Astral", "Fire"},           -- Hollows can use Earth, Air, Fire
	Quincy = {"Water", "Lightning", "Earth"}     -- Quincies can use Water, Lightning, Earth
}

-- Helper function: Weighted random element selection based on rarity
local function selectRandomElement(race)
	local totalWeight = 0
	local elementRarities = raceElementRarities[race]

	-- Calculate total weight of the selected race's elements
	for _, weight in pairs(elementRarities) do
		totalWeight = totalWeight + weight
	end

	-- Pick a random number within the total weight
	local randomWeight = math.random(0, totalWeight)

	-- Determine which element is selected based on the random weight
	local currentWeight = 0
	for element, weight in pairs(elementRarities) do
		currentWeight = currentWeight + weight
		if randomWeight <= currentWeight then
			return element
		end
	end
end

-- Function to reroll a player's element based on their race
local function rerollElement(player)
	local race = player.Character:GetAttribute("Race")  -- Get the player's race

	-- Ensure the race attribute is valid
	if not race or not raceElementRarities[race] then
		warn("Invalid race or no race attribute found for " .. player.Name)
		return
	end

	-- Get the allowed elements for this race
	local allowedElements = raceRestrictions[race]

	-- Try selecting a valid element based on the allowed list
	local selectedElement = selectRandomElement(race)

	-- If the element is not compatible with the player's race, reroll
	while not table.find(allowedElements, selectedElement) do
		selectedElement = selectRandomElement(race)
	end

	-- Set the new element on the player
	player.Character:SetAttribute("Element", selectedElement)
	print(player.Name .. " has been rerolled to the " .. selectedElement .. " element!")
end

-- Function to handle the remote event when the player triggers the reroll


-- Connect the remote event to the reroll function
rerollEvent.OnServerEvent:Connect(function(player)
	-- Ensure the player has a character and valid race before rerolling
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		rerollElement(player)  -- Call the reroll function
	end
end)

-- Example: Set initial race when a player joins the game (e.g., SoulReaper by default)
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- Set a default race (or choose based on your game logic)
		character:SetAttribute("Race", "SoulReaper")  -- Default race

		
	end)
end)

