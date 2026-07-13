--[[


   _____            __    _ __  ___           __           
  / ___/__  _______/ /_  (_)  |/  /___ ______/ /____  _____
  \__ \/ / / / ___/ __ \/ / /|_/ / __ `/ ___/ __/ _ \/ ___/
 ___/ / /_/ (__  ) / / / / /  / / /_/ (__  ) /_/  __/ /    
/____/\__,_/____/_/ /_/_/_/  /_/\__,_/____/\__/\___/_/     
                                                           




____________________________________________________________________________________________________________________________________________________________________________
				
	[ UPDATE LOG v1.1 :]
1. New property!!
	Hitbox.Key = "insert anything you want here"
		--- This property will be used for the new function | module:FindHitbox(key)
		
2. New function!!
	Module:FindHitbox(Key)
		--- Returns a hitbox using specified Key, nil otherwise
		
3. New detection mode! | "ConstantDetection"
	Hitbox.DetectionMode = "ConstantDetection"
		--- The same as the default detection mode but no hit pool / debounce
		--- You're free to customize the debounce anyway you want
		
4, Made the scripts cleaner
____________________________________________________________________________________________________________________________________________________________________________
	
	[ UPDATE LOG v1.2 :]
1. Made the code better

____________________________________________________________________________________________________________________________________________________________________________
	
	[ UPDATE LOG v1.3 :]
1. New property
	HitboxObject.AutoDestroy = true (Default)
		---  With the value being false you can keep using Stop() 
		and Start() without the hitbox being destroyed.

2. New metamethod
	HitboxObject:Destroy()
		---  This destroys the hitbox. You only need to use this
			 When having AutoDestroy's value set to false.
			 
3. Minor bug fixes
			 
____________________________________________________________________________________________________________________________________________________________________________

	[ UPDATE LOG v1.4  Experimental:]
1. New event
	HitboxObject.TouchEnded:Connect(instance)
				Description
					--- The event fires once a part stops touching the hitbox
				Arguments
					--- Instance part: Returns the part that the hitbox stopped touching
					
____________________________________________________________________________________________________________________________________________________________________________

	[ UPDATE LOG v1.5  Stable:]
1. Reverted touch ended, will add back after the bug is fixed

____________________________________________________________________________________________________________________________________________________________________________

	[ UPDATE LOG v1.6  Stable:]
1. Touch ended is back! It has been fixed
2. HitboxObject.Key is now generated automatically
3. Minor changes

____________________________________________________________________________________________________________________________________________________________________________

	[ UPDATE LOG v2.0 Experimental:]
1. Added VelocityPrediction and VelocityPredictionTime property
2. You can now set the color and transparency of a hitbox
2. Minor fixes
3. Code now uses type checking
____________________________________________________________________________________________________________________________________________________________________________

	[ UPDATE LOG v2.1 Experimental:]
1. Improved hit detection performance by replacing table.find with dictionary lookups
2. Fixed visualizer not updating size
____________________________________________________________________________________________________________________________________________________________________________

	Example code:
		local module = require(game.ServerStorage.MuchachoHitbox)

		local hitbox = module.CreateHitbox()
		hitbox.Size = Vector3.new(10,10,10)
		hitbox.CFrame = workspace.Part
		
		-- IF YOU WANT TO ADD VELOCITY PREDICTION
		hitbox.VelocityPrediction = true
		hitbox.VelocityPredictionTime = .2

		hitbox.Touched:Connect(function(hit, hum)
			print(hit)
			hum:TakeDamage(10)
		end)
		
		hitbox:Start()
	
	
	Alright thats all for the example code, its a pretty simple module, you could make a module similar to this yourself.
	And maybe even make it better.
	
	If you encounter any bugs, please tell me in the comment section, or you could DM me on discord
	sushimaster#7840
	
	If you encounter any bugs, p̶l̶e̶a̶s̶e̶ t̶e̶l̶l̶ m̶e̶ i̶n̶ t̶h̶e̶ c̶o̶m̶m̶e̶n̶t̶ s̶e̶c̶t̶i̶o̶n̶, o̶r̶ y̶o̶u̶ c̶o̶u̶l̶d̶ D̶M̶ m̶e̶ o̶n̶ d̶i̶s̶c̶o̶r̶d̶ 	
	s̶u̶s̶h̶i̶m̶a̶s̶t̶e̶r̶#̶7̶8̶4̶0̶
	
	Just let me know in dev forum comment section. Or my Youtube comment section.
	
	❤ SushiMaster
____________________________________________________________________________________________________________________________________________________________________________
	
	
	[MuchachoHitbox Documentation]

		* local Module = require(MuchachoHitbox)
				--- Require the module


			[ FUNCTIONS ]

		* Module.CreateHitbox()
				Description
					--- Creates a hitbox
					
		* Module:FindHitbox(Key)
				Description
					--- Returns a hitbox with specified Key

		* HitboxObject:Start()
				Description
					--- Starts the hitbox. 
					
		* HitboxObject:Stop()
				Description
					--- Stops the hitbox and resets the debounce.
					
		* HitboxObject:Destroy()
				Description
					--- Destroys the hitbox. Use this when you have
						HitboxObject.AutoDestroy set to false
					
			[ EVENTS ]

		* HitboxObject.Touched:Connect(hit, humanoid)
				Description
					--- If the hitbox touches a humanoid, it'll return information on them
					--- The hitbox can detect parts depending on the detection mode
				Arguments
					--- Instance part: Returns the part that the hitbox hit first
					--- Instance humanoid: Returns the Humanoid object 
					
		* HitboxObject.TouchEnded:Connect(instance)
				Description
					--- The event fires once a part stops touching the hitbox
				Arguments
					--- Instance part: Returns the part that the hitbox stopped touching
					
			[ PROPERTIES ]

		* HitboxObject.OverlapParams: OverlapParams
				Description
					--- Takes in a OverlapParams object

		* HitboxObject.Visualizer: boolean
				Description
					--- Turns on or off the visualizer part

		* HitboxObject.CFrame: CFrame / Instance
				Description
					--- Sets the hitbox CFrame to the CFrame
					--- If its an instance, then the hitbox would follow the instance
					
		* HitboxObject.Shape: Enum.PartType.Block / Enum.PartType.Ball
				Description
					--- Defaults to block
					--- Sets the hitbox shape to the property
					
		* HitboxObject.Size: Vector3 / number 
				Description
					--- Sets the size of the hitbox
					--- It uses Vector3 if the shape is block
					--- It uses number if the shape is ball
					
		* HitboxObject.Offset: CFrame
				Description
					--- Hitbox offset

		* HitboxObject.DetectionMode: string | "Default" , "HitOnce" , "HitParts" , "ConstantDetection"
				Description
					--- Default value set to "Default"
					--- Changes on how the detection works
					
		* HitboxObject.Key: String
				Description
					--- The key property for the find hitbox function
					--- MuchachoHitbox automatically generates a randomized key for you but you can change it. The module will save the hitbox, and can be found using | Module:FindHitbox(Key)
					
		* HitboxObject.AutoDestroy: boolean
				Description
					--- Default value is set to true
					--- When set to true, :Stop() atomatically destroys the hitbox.
					--- Does not destroy the hitbox when set to false. You'll 
						have to use :Destroy() to delete the hitbox.
						
		* HitboxObject.VelocityPrediction: boolean
				Description
					--- Default value is set to false
					--- When set to true, hitbox automatically predicts the velocity of the CFrame property if it is an instance. By "VelocityPredictionTime" amount of time
					
		* HitboxObject.VelocityPredictionTime: number
				Description
					--- Default value is set to 0.1
					--- When "VelocityPrediction" is set to true, this property determines how far in the future the hitbox will check for parts.

		* HitboxObject.VisualizerColor: Color3
				Description
					--- Sets the color of the visualizer part
					
		* HitboxObject.VisualizerTransparency: number
				Description
					--- Sets the transparency of the visualizer part

			[ DETECTION MODES ]

		* Default
				Description
					--- Checks if a humanoid exists when this hitbox touches a part. The hitbox will not return humanoids it has already hit for the duration
					--- the hitbox has been active.

		* HitParts
				Description
					--- OnHit will return every hit part, regardless if it's ascendant has a humanoid or not.
					--- OnHit will no longer return a humanoid so you will have to check it. The hitbox will not return parts it has already hit for the
					--- duration the hitbox has been active.

		* HitOnce
				Description
					--- Hitbox will stop as soon as it detects a humanoid
					
		* ConstantDetection
				Description
					--- The default detection mode but no hitlist / debounce
					
____________________________________________________________________________________________________________________________________________________________________________

]]
local rs = game:GetService("RunService")
local hs = game:GetService("HttpService")

local GoodSignal = require(script.GoodSignal)
local DictDiff = require(script.DictDiff)
local Types = require(script.Types)

local muchacho_hitbox = {}
muchacho_hitbox.__index = muchacho_hitbox

local adornment_form = {
	["Proportion"] = {
		[Enum.PartType.Ball] = "Radius",
		[Enum.PartType.Block] = "Size",
	},

	["Shape"] = {
		[Enum.PartType.Ball] = "SphereHandleAdornment",
		[Enum.PartType.Block] = "BoxHandleAdornment",
	},
}

local get_CFrame = {
	["Instance"] = function(point)
		return point.CFrame
	end,

	["CFrame"] = function(point)
		return point
	end,
}


local hitboxes = {}

-- public functions
function muchacho_hitbox.CreateHitbox()
	local self = setmetatable({}, muchacho_hitbox) :: Types.Hitbox
	self.DetectionMode = "Default"
	self.AutoDestroy = true
	
	self.Visualizer = true
	self.VisualizerColor = Color3.fromRGB(255,0,0)
	self.VisualizerTransparency = .8

	self.VelocityPrediction = false
	self.VelocityPredictionTime = 0.1
	
	self.OverlapParams = OverlapParams.new()
	
	self.Size = Vector3.new(0,0,0)
	self.Shape = Enum.PartType.Block
	self.CFrame = CFrame.new(0,0,0)
	self.Offset = CFrame.new(0,0,0)
	
	self.Key = hs:GenerateGUID(false)

	self.HitList = {}
	self.TouchingParts = {}
	
	self.Touched = GoodSignal.new()
	self.TouchEnded = GoodSignal.new()

	return self
end

function muchacho_hitbox:FindHitbox(key) -- deprecated
	if hitboxes[key] then
		return hitboxes[key]
	else
		return nil
	end
end

-- public methods
function muchacho_hitbox.Start(self: Types.Hitbox)
	if hitboxes[self.Key] then
		error("A hitbox with this Key has already been started. Change the key if you want to start this hitbox.")
	end

	hitboxes[self.Key] = self

	-- looping the hitbox
	task.spawn(function()	
		self._Connection = rs.Heartbeat:Connect(function()
			self:_visualize()
			self:_cast()
		end)
	end)
end

function muchacho_hitbox.Stop(self: Types.Hitbox)
	local hitbox = muchacho_hitbox:FindHitbox(self.Key)

	if not hitbox then
		error("Hitbox has already been stopped")
	end

	-- clear hitbox
	self:_clear()

	if not self.AutoDestroy then return end
	self.

	-- terminate hitbox
	self.Touched:DisconnectAll()
	self.TouchEnded:DisconnectAll()
	--setmetatable(self, nil)
end

function muchacho_hitbox:Destroy()
	local hitbox: Types.Hitbox = muchacho_hitbox:FindHitbox(self.Key)

	if not hitbox then
		error("Hitbox has already been destroyed")
	end

	-- clear hitbox
	self:_clear()

	-- terminate hitbox
	self.Touched:DisconnectAll()
	self.TouchEnded:DisconnectAll()
	--setmetatable(self, nil)
end


-- private methods
function muchacho_hitbox._CastSpatialQuery(self: Types.Hitbox) : {BasePart}?
	local point_type: CFrame | string = typeof(self.CFrame)
	local point_cframe: CFrame = self:_PredictVelocity() or get_CFrame[point_type](self.CFrame)

	local parts
	local hitboxCFrame: CFrame = point_cframe * self.Offset
	
	if self.Shape == Enum.PartType.Block then
		parts = workspace:GetPartBoundsInBox(hitboxCFrame, self.Size, self.OverlapParams)
	elseif self.Shape == Enum.PartType.Ball then
		parts = workspace:GetPartBoundsInRadius(hitboxCFrame.Position, self.Size, self.OverlapParams)
	else
		error("Part type: " .. self.Shape .. " isn't compatible with muchachoHitbox")
	end

	return parts
end

function muchacho_hitbox._cast(self: Types.Hitbox, part: BasePart)
	local mode = self.DetectionMode
	local parts = self:_CastSpatialQuery()
	-- Phase 1: filter and collect valid hits with pre-resolved data
	local hitsData = {}
	local currentTouchingParts = {}

	for _, hit in pairs(parts) do
		local character: Model = hit:FindFirstAncestorOfClass("Model") or hit.Parent
		local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")

		local passes = false
		if mode == "Default" then
			passes = humanoid ~= nil and not self.HitList[humanoid]
		elseif mode == "ConstantDetection" or mode == "HitOnce" then
			passes = humanoid ~= nil
		elseif mode == "HitParts" then
			passes = true
		end

		if passes then
			currentTouchingParts[hit] = hit
			table.insert(hitsData, { hit = hit, humanoid = humanoid })
		end
	end

	-- Phase 2: touch ended, then fire events
	self:_FindTouchEnded(currentTouchingParts)

	for _, data in pairs(hitsData) do
		local hit, humanoid = data.hit, data.humanoid

		if mode == "Default" then
			self.HitList[humanoid] = humanoid
			self:_InsertTouchingParts(hit)
			self.Touched:Fire(hit, humanoid)
		elseif mode == "ConstantDetection" then
			self:_InsertTouchingParts(hit)
			self.Touched:Fire(hit, humanoid)
		elseif mode == "HitOnce" then
			self:_InsertTouchingParts(hit)
			self.Touched:Fire(hit, humanoid)
			self.TouchEnded:Fire(hit)
			self:Destroy()
			break
		elseif mode == "HitParts" then
			self:_InsertTouchingParts(hit)
			self.Touched:Fire(hit, nil)
		end
	end
end

function muchacho_hitbox._visualize(self: Types.Hitbox)
	if not self.Visualizer then return end

	local predictedCFrame = self:_PredictVelocity()
	
	local point_type: string = typeof(self.CFrame)
	local point_cframe: CFrame = predictedCFrame or get_CFrame[point_type](self.CFrame)

	local proportion = adornment_form.Proportion[self.Shape]

	if not self._Box then
		local newBox = Instance.new(adornment_form.Shape[self.Shape])
		newBox.Name = "Visualizer"
		newBox.Adornee = workspace.Terrain
		newBox[proportion] = self.Size
		newBox.CFrame = point_cframe * self.Offset
		newBox.Color3 = self.VisualizerColor
		newBox.Transparency = self.VisualizerTransparency
		newBox.Parent = workspace.Terrain
		self._Box = newBox
	else
		self._Box.CFrame = point_cframe * self.Offset
		self._Box[proportion] = self.Size
		self._Box.Color3 = self.VisualizerColor
		self._Box.Transparency = self.VisualizerTransparency
	end
end

function muchacho_hitbox._PredictVelocity(self: Types.Hitbox): CFrame | nil
	if self.VelocityPrediction then
		local PredictionTime: number = self.VelocityPredictionTime
		local part: BasePart = self.CFrame
		local constant: number = 1/PredictionTime

		if PredictionTime > 0 and typeof(part) == "Instance" then
			--local velocityVector =  part.CFrame:VectorToObjectSpace(part.AssemblyLinearVelocity) / constant
			--local predictedCFrame = part.CFrame * CFrame.new(velocityVector)
			local Velocity = part.AssemblyLinearVelocity --// Normally this would be their ping
			local PredictedPosition = part.Position + Velocity * PredictionTime
			local PredictedCFrame = CFrame.new(PredictedPosition) * (part.CFrame - part.Position)

			
			return PredictedCFrame
		end
	end
	
	return nil
end

function muchacho_hitbox:_clear()
	self.HitList = {}

	if self._Connection then
		self._Connection:Disconnect()
	end

	if self.Key then
		hitboxes[self.Key] = nil
	end

	if self._Box then
		self._Box:Destroy()
		self.Box = nil
	end
end

function muchacho_hitbox._InsertTouchingParts(self: Types.Hitbox, part)
	if self.TouchingParts[part] then return end

	self.TouchingParts[part] = part
end

function muchacho_hitbox._FindTouchEnded(self: Types.Hitbox, parts: {[BasePart]: boolean}?)
	--print( next(self.TouchingParts))
	if not next(self.TouchingParts) then return end

	local mode = self.DetectionMode
	local differences = DictDiff.difference(self.TouchingParts, parts)

	if next(differences) then
		--print("difference exists", differences, self.TouchingParts, parts)
		for _, diff in ipairs(differences) do
			self.TouchEnded:Fire(diff)
			self.TouchingParts[diff] = nil
		end
	end
end



return muchacho_hitbox
