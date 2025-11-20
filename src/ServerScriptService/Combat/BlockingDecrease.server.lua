local DecreaseBlockingTime = 3
local DeccreaseAmount = 2

local connectionRunning = {}

local function onBlockingChanged(char)
	if char:GetAttribute("Blocking") > 0 and connectionRunning[char] == nil then 
		connectionRunning[char] = true
		
		local signalConnection = nil
		signalConnection = char:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(char)
		end)
		
		coroutine.wrap(function()
			while char:GetAttribute("Blocking") > 0 do
				task.wait(1)
				for i, humanoids in char:GetChildren() do
					if humanoids:IsA("Humanoid") then
						local char = humanoids.Parent
						if  char then
							
							local  isBlocking = char:GetAttribute("IsBlocking")
							local  lastStopTime = char:GetAttribute("LastStopTime") or 0
							local currentTime = tick()
							
							if not isBlocking and currentTime - lastStopTime >= DecreaseBlockingTime then
								char:SetAttribute("Blocking",math.max(char:GetAttribute("Blocking")-DeccreaseAmount))
							end
							
						end
					end
				end
			end
			connectionRunning[char] = nil
			signalConnection:Disconnect()
		end)()
	end
end


for i,v in workspace.NPC:GetChildren() do
	if v:IsA("Model") and  v:FindFirstChild("Humanoid") then
		v:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(v)
		end)
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char:GetAttributeChangedSignal("Blocking"):Connect(function()
			 onBlockingChanged(char)
		end)
	end)
end)

workspace.NPC.ChildAdded:Connect(function(child)
	if child:IsA("Model") and  child:FindFirstChild("Humanoid") then
		child:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(child)
		end)
	end

end)