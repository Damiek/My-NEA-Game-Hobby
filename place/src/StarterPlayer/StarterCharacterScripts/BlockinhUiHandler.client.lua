local Players = game:GetService("Players")

-- Wait for the LocalPlayer to exist
local plr = Players.LocalPlayer

-- Wait for the character to be added
local char = plr.Character or plr.CharacterAdded:Wait()

-- The UI is located inside the player's PlayerGui, not the script's parent.
-- We use :WaitForChild() to ensure the UI has loaded onto the player's screen.
local PlayerGui = plr:WaitForChild("PlayerGui")
local MainFrame = PlayerGui:WaitForChild("BlockingUi"):WaitForChild("MainFrame") -- **<-- FIX 1: You must replace 'TheNameOfYourScreenGui'**

local Bar = MainFrame.Bar

---

local function updateUI()
    -- Get the current Blocking attribute value
	local blockingValue = char:GetAttribute("Blocking") or 0
    
    -- Calculate the UDim2 scale (assuming Max Blocking is 100)
    local scale = blockingValue / 100
    
    -- Ensure scale is not negative
    if scale < 0 then scale = 0 end

    local newSize = UDim2.new(scale, 0, 1, 0)
    
    -- Use a non-negative time for TweenSize
    local tweenTime = 0.3 -- I recommend a small positive time for visibility

    -- Set visibility based on the attribute value
	if blockingValue > 0 then
		MainFrame.Visible = true
		Bar:TweenSize(newSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, tweenTime, true)
	else
		-- If blocking is 0 or less, hide the UI
		MainFrame.Visible = false
		Bar:TweenSize(newSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, tweenTime, true)
	end
end

-- Connect the function to the attribute change signal
char:GetAttributeChangedSignal("Blocking"):Connect(updateUI)

-- Run once on start to initialize the UI state
updateUI()