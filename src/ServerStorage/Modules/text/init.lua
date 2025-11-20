local module = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local s = [[info face="Minecraft V3 Final" size=18 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,1,1,1 spacing=1,1
common lineHeight=18 base=14 scaleW=138 scaleH=138 pages=1 packed=0
page id=0 file="Minecraft V3 Final.png"
chars count=91
char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=6 page=0 chnl=15
char id=33 x=15 y=86 width=5 height=15 xoffset=-1 yoffset=0 xadvance=4 page=0 chnl=15
char id=34 x=10 y=130 width=11 height=8 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=35 x=82 y=86 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=36 x=71 y=0 width=11 height=17 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=37 x=21 y=86 width=16 height=15 xoffset=0 yoffset=0 xadvance=16 page=0 chnl=15
char id=38 x=97 y=86 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=39 x=34 y=130 width=5 height=7 xoffset=-1 yoffset=-1 xadvance=4 page=0 chnl=15
char id=40 x=50 y=86 width=9 height=15 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15
char id=41 x=60 y=86 width=9 height=15 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15
char id=42 x=0 y=130 width=9 height=8 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15
char id=43 x=51 y=117 width=12 height=11 xoffset=0 yoffset=2 xadvance=12 page=0 chnl=15
char id=44 x=40 y=130 width=5 height=6 xoffset=-1 yoffset=11 xadvance=4 page=0 chnl=15
char id=45 x=46 y=130 width=8 height=5 xoffset=-1 yoffset=7 xadvance=7 page=0 chnl=15
char id=46 x=55 y=130 width=5 height=5 xoffset=-1 yoffset=10 xadvance=4 page=0 chnl=15
char id=47 x=70 y=86 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=48 x=89 y=0 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=49 x=101 y=0 width=9 height=15 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15
char id=50 x=111 y=0 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=51 x=0 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=52 x=12 y=22 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=53 x=26 y=22 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=54 x=41 y=22 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=55 x=55 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=56 x=67 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=57 x=79 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=58 x=132 y=102 width=5 height=12 xoffset=0 yoffset=3 xadvance=5 page=0 chnl=15
char id=59 x=133 y=86 width=5 height=14 xoffset=0 yoffset=3 xadvance=5 page=0 chnl=15
char id=61 x=79 y=117 width=11 height=9 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=63 x=38 y=86 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=64 x=24 y=0 width=18 height=18 xoffset=-1 yoffset=0 xadvance=17 page=0 chnl=15
char id=65 x=61 y=38 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=66 x=75 y=38 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=67 x=123 y=0 width=15 height=15 xoffset=-1 yoffset=0 xadvance=14 page=0 chnl=15
char id=68 x=90 y=38 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=69 x=105 y=38 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=70 x=120 y=38 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=71 x=0 y=54 width=15 height=15 xoffset=-1 yoffset=0 xadvance=14 page=0 chnl=15
char id=72 x=16 y=54 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=73 x=31 y=54 width=7 height=15 xoffset=0 yoffset=0 xadvance=7 page=0 chnl=15
char id=74 x=39 y=54 width=10 height=15 xoffset=-1 yoffset=0 xadvance=9 page=0 chnl=15
char id=75 x=50 y=54 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=76 x=64 y=54 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=77 x=78 y=54 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=78 x=93 y=54 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=79 x=108 y=54 width=16 height=15 xoffset=-1 yoffset=0 xadvance=15 page=0 chnl=15
char id=80 x=0 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=81 x=15 y=70 width=16 height=15 xoffset=-1 yoffset=0 xadvance=15 page=0 chnl=15
char id=82 x=32 y=70 width=16 height=15 xoffset=-1 yoffset=0 xadvance=15 page=0 chnl=15
char id=83 x=125 y=54 width=13 height=15 xoffset=-1 yoffset=0 xadvance=12 page=0 chnl=15
char id=84 x=49 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=85 x=64 y=70 width=13 height=15 xoffset=0 yoffset=0 xadvance=13 page=0 chnl=15
char id=86 x=78 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=87 x=93 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=88 x=108 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=89 x=123 y=70 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=90 x=0 y=86 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=91 x=43 y=0 width=7 height=18 xoffset=-1 yoffset=0 xadvance=6 page=0 chnl=15
char id=93 x=51 y=0 width=7 height=18 xoffset=-1 yoffset=0 xadvance=6 page=0 chnl=15
char id=94 x=22 y=130 width=11 height=8 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=95 x=61 y=130 width=13 height=3 xoffset=-1 yoffset=12 xadvance=12 page=0 chnl=15
char id=97 x=59 y=102 width=13 height=12 xoffset=-1 yoffset=3 xadvance=12 page=0 chnl=15
char id=98 x=91 y=22 width=14 height=15 xoffset=-1 yoffset=0 xadvance=13 page=0 chnl=15
char id=99 x=73 y=102 width=13 height=12 xoffset=-1 yoffset=3 xadvance=12 page=0 chnl=15
char id=100 x=106 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=101 x=87 y=102 width=11 height=12 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=102 x=118 y=22 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=103 x=59 y=0 width=11 height=17 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=104 x=0 y=38 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=105 x=130 y=22 width=5 height=15 xoffset=-1 yoffset=0 xadvance=4 page=0 chnl=15
char id=106 x=12 y=38 width=10 height=15 xoffset=-1 yoffset=2 xadvance=9 page=0 chnl=15
char id=107 x=23 y=38 width=11 height=15 xoffset=-1 yoffset=0 xadvance=11 page=0 chnl=15
char id=108 x=83 y=0 width=5 height=16 xoffset=-1 yoffset=-1 xadvance=4 page=0 chnl=15
char id=109 x=99 y=102 width=18 height=12 xoffset=-1 yoffset=3 xadvance=17 page=0 chnl=15
char id=110 x=118 y=102 width=13 height=12 xoffset=-1 yoffset=3 xadvance=12 page=0 chnl=15
char id=111 x=0 y=117 width=11 height=12 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=112 x=35 y=38 width=13 height=15 xoffset=-1 yoffset=3 xadvance=12 page=0 chnl=15
char id=113 x=49 y=38 width=11 height=15 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=114 x=12 y=117 width=10 height=12 xoffset=-1 yoffset=3 xadvance=9 page=0 chnl=15
char id=115 x=21 y=102 width=10 height=13 xoffset=-1 yoffset=2 xadvance=9 page=0 chnl=15
char id=116 x=112 y=86 width=8 height=14 xoffset=-1 yoffset=1 xadvance=7 page=0 chnl=15
char id=117 x=23 y=117 width=11 height=12 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=118 x=64 y=117 width=14 height=10 xoffset=-1 yoffset=5 xadvance=13 page=0 chnl=15
char id=119 x=35 y=117 width=15 height=11 xoffset=-1 yoffset=4 xadvance=14 page=0 chnl=15
char id=120 x=32 y=102 width=14 height=13 xoffset=-1 yoffset=2 xadvance=13 page=0 chnl=15
char id=121 x=121 y=86 width=11 height=14 xoffset=-1 yoffset=3 xadvance=11 page=0 chnl=15
char id=122 x=47 y=102 width=11 height=13 xoffset=-1 yoffset=2 xadvance=11 page=0 chnl=15
char id=123 x=6 y=0 width=8 height=20 xoffset=-1 yoffset=0 xadvance=7 page=0 chnl=15
char id=124 x=0 y=0 width=5 height=21 xoffset=-1 yoffset=-1 xadvance=4 page=0 chnl=15
char id=125 x=15 y=0 width=8 height=20 xoffset=-1 yoffset=0 xadvance=7 page=0 chnl=15
char id=8470 x=0 y=102 width=20 height=14 xoffset=-2 yoffset=1 xadvance=18 page=0 chnl=15

]]

local fontMap = 'rbxassetid://140620201788732'
local RunService = game:GetService("RunService")

-----

local info = {}

info.fontInfo = {}
info.characterTable = {}
info.kernings = {}

local init, _ = s:find('kernings')
if init then
	local kernings = s:sub(init, s:len()):split('\n')

	local kerningsTable = info.kernings

	for i,v in ipairs(kernings) do
		local first, second, amount = v:match('kerning first=([%-?%.?%d?]+) second=([%-?%.?%d?]+) amount=([%-?%.?%d?]+)')
		if first then
			kerningsTable[utf8.char(first)] = kerningsTable[utf8.char(first)] or {}
			kerningsTable[utf8.char(first)][utf8.char(second)] = amount
		end
	end
	s = s:sub(1, init - 1)
end
local split = s:split('\n')

local characterTable = info.characterTable

for i = 3, 1, -1 do
	local infoThisIteration = split[i]:split(' ')
	for i,v in ipairs(infoThisIteration) do
		local field, value = unpack(v:split('='))
		if field and value then
			field, value = field:gsub('"', ''), value:gsub('"', '')
			info.fontInfo[field] = tonumber(value) or value
		end
	end
	table.remove(split, i)
end
table.remove(split, 1)

for i = #split, 1, -1 do
	local v = split[i]
	local charId, x, y, width, height, xOffset, yOffset, xAdvance, page, chnl = v:match('char id=([%-?%.?%d?]+) x=([%-?%.?%d?]+) y=([%-?%.?%d?]+) width=([%-?%.?%d?]+) height=([%-?%.?%d?]+) xoffset=([%-?%.?%d?]+) yoffset=([%-?%.?%d?]+) xadvance=([%-?%.?%d?]+) page=([%-?%.?%d?]+) chnl=([%-?%.?%d?]+)')
	if charId then
		table.remove(split,i)
		table.insert(characterTable, {
			charId = charId;
			x = x;
			y = y;
			width = width;
			height = height;
			xOffset = xOffset;
			yOffset = yOffset;
			xAdvance = xAdvance;
			page = page;
			chnl = chnl
		})
	end
end

local size = 36

local stringFolder = Instance.new('Folder')
stringFolder.Name = info.fontInfo.face
stringFolder.Parent = script

for i,v in ipairs(characterTable) do
	local mainFrame = Instance.new('Frame')
	mainFrame.Size = UDim2.fromOffset(v.xAdvance or v.width, size)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Name = utf8.char(v.charId)
	mainFrame.BackgroundTransparency = 1
	local newLabel = Instance.new('ImageLabel')
	newLabel.Image = fontMap
	newLabel.Size = UDim2.fromOffset(v.width, v.height)
	newLabel.Parent = mainFrame
	newLabel.Name = utf8.char(v.charId)
	newLabel.Position = UDim2.fromOffset(v.xOffset, v.yOffset)
	newLabel.ImageRectSize = Vector2.new(v.width, v.height)
	newLabel.ImageRectOffset = Vector2.new(v.x, v.y)
	newLabel.Parent = mainFrame
	newLabel.BackgroundTransparency = 1
	newLabel.ScaleType = Enum.ScaleType.Fit
	newLabel.BackgroundTransparency = 1
	mainFrame.Parent = stringFolder
end

-----
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local messageQueue = {}
local isFeeding = false
local currentHeaderFrame

-- Function to parse tags inside the message
local function parseTags(str)
	local segments = {}
	local tagStack = {}
	local i = 1

	while i <= #str do
		local startTag, endTag = str:find("<[^>]*>", i)

		if startTag then
			local preText = str:sub(i, startTag - 1)
			if preText ~= "" then
				table.insert(segments, { text = preText, tags = table.clone(tagStack) })
			end

			local tagText = str:sub(startTag + 1, endTag - 1)
			if tagText:sub(1, 1) == "/" then
				local closing = tagText:sub(2)
				for idx = #tagStack, 1, -1 do
					if tagStack[idx]:match("^colour:") and closing:match("^colour:") then
						table.remove(tagStack, idx)
						break
					elseif tagStack[idx] == closing then
						table.remove(tagStack, idx)
						break
					end
				end
			else
				table.insert(tagStack, tagText)
			end

			i = endTag + 1
		else
			local remaining = str:sub(i)
			table.insert(segments, { text = remaining, tags = table.clone(tagStack) })
			break
		end
	end

	return segments
end

-- Function to apply shake effect to letter and image
local function applyShakeEffect(letterFrame, imageLabel)
	local originalPosition = letterFrame.Position
	local originalImagePosition = imageLabel.Position
	local shakeMagnitude = 5
	local cycleTime = 0.05
	local isShaking = true

	task.spawn(function()
		while isShaking do
			letterFrame.Position = originalPosition + UDim2.new(0, math.random(-shakeMagnitude, shakeMagnitude), 0, math.random(-shakeMagnitude, shakeMagnitude))
			imageLabel.Position = originalImagePosition + UDim2.new(0, math.random(-shakeMagnitude, shakeMagnitude), 0, math.random(-shakeMagnitude, shakeMagnitude))
			task.wait(cycleTime)
		end
	end)

	return function()
		isShaking = false
	end
end

-- Function to create frame for letters
local function createLetteredFrame(text, fadeDuration)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.ClipsDescendants = false

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = frame

	for i, unit in utf8.graphemes(text) do
		local char = text:sub(i, unit)
		local template = stringFolder:FindFirstChild(char)
		if template then
			local letter = template:Clone()
			letter.Visible = true
			letter.LayoutOrder = i
			local image = letter:FindFirstChildWhichIsA("ImageLabel")
			if image then
				image.ImageTransparency = 1
				local tween = TweenService:Create(image, TweenInfo.new(fadeDuration), { ImageTransparency = 0 })
				tween:Play()
			end
			letter.Parent = frame
		end
	end

	return frame
end

-- Function to feed message and show it letter by letter with effects
local function feedSingle(str, plr, isLast)
	local headerText
	str = str:gsub("<h>(.-)<h>", function(h)
		headerText = h
		return ""
	end)

	local parsed = parseTags(str)

	local subtitleContainer = plr.PlayerGui.CutsceneUI:FindFirstChild("SubtitleContainer")
	if not subtitleContainer then
		subtitleContainer = Instance.new("Frame")
		subtitleContainer.Name = "SubtitleContainer"
		subtitleContainer.BackgroundTransparency = 1
		subtitleContainer.AnchorPoint = Vector2.new(0.5, 1)
		subtitleContainer.Position = UDim2.new(0.5, 0, 1, -100)
		subtitleContainer.Size = UDim2.new(1, -100, 0, 100)
		subtitleContainer.AutomaticSize = Enum.AutomaticSize.Y
		subtitleContainer.ClipsDescendants = false
		subtitleContainer.Parent = plr.PlayerGui.CutsceneUI

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.Padding = UDim.new(0, 6)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Parent = subtitleContainer
	end

	if headerText then
		if currentHeaderFrame then
			for _, letter in ipairs(currentHeaderFrame:GetChildren()) do
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					TweenService:Create(img, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
				end
			end
			task.wait(0.25)
			currentHeaderFrame:Destroy()
			currentHeaderFrame = nil
		end
		currentHeaderFrame = createLetteredFrame(headerText, 0.5)
		currentHeaderFrame.Parent = subtitleContainer
	end

	local newFrame = Instance.new("Frame")
	newFrame.BackgroundTransparency = 1
	newFrame.Size = UDim2.new(1, 0, 0, 40)
	newFrame.ClipsDescendants = false
	newFrame.AutomaticSize = Enum.AutomaticSize.X
	newFrame.Name = "DialogueLine"

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = newFrame

	newFrame.Parent = subtitleContainer

	local letterCount = 0
	local stopShaking

	-- Loop through the parsed message segments and apply effects
	for _, segment in ipairs(parsed) do
		local graphemes = {}
		for i, v in utf8.graphemes(segment.text) do
			table.insert(graphemes, segment.text:sub(i, v))
		end

		for _, char in ipairs(graphemes) do
			local template = stringFolder:FindFirstChild(char)
			if template then
				local newLetter = template:Clone()
				newLetter.LayoutOrder = letterCount
				newLetter.Visible = true
				newLetter.Parent = newFrame
				letterCount += 1

				local image = newLetter:FindFirstChildWhichIsA("ImageLabel")
				if image then
					image.ImageTransparency = 1

					-- Apply color if specified
					for _, tag in ipairs(segment.tags) do
						if tag:match("^colour:#%x%x%x%x%x%x$") then
							local hex = tag:match("#%x%x%x%x%x%x")
							local r = tonumber(hex:sub(2, 3), 16) / 255
							local g = tonumber(hex:sub(4, 5), 16) / 255
							local b = tonumber(hex:sub(6, 7), 16) / 255
							image.ImageColor3 = Color3.new(r, g, b)
						end
					end

					-- Apply fade effect
					local fade = TweenService:Create(image, TweenInfo.new(0.1), { ImageTransparency = 0 })
					fade:Play()

					-- Check and play sound if specified in tags
					for _, tag in ipairs(segment.tags) do
						if tag == "shake" then
							stopShaking = applyShakeEffect(newLetter, image)
						elseif tag:match("^sound:rbxassetid://%d+$") then
							local soundId = tag:match("sound:rbxassetid://(%d+)")

							local sound = Instance.new("Sound")
							sound.SoundId = "rbxassetid://" .. soundId
							sound.Volume = 1
							sound.Parent = plr.PlayerGui or workspace.CurrentCamera
							sound:Play()

							-- Clean up the sound after 2 seconds
							Debris:AddItem(sound, 2)
						end
					end
				end

				task.wait(0.1)
			end
		end
	end

	-- Fade out letters
	task.wait(1.5)

	for t = 0, 1, 0.1 do
		for _, letter in ipairs(newFrame:GetChildren()) do
			if letter:IsA("Frame") then
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					img.ImageTransparency = t
				end
			end
		end
		task.wait(0.03)
	end

	if stopShaking then stopShaking() end
	newFrame:Destroy()

	-- Fade out header if last message
	if isLast and currentHeaderFrame then
		for _, letter in ipairs(currentHeaderFrame:GetChildren()) do
			local img = letter:FindFirstChildWhichIsA("ImageLabel")
			if img then
				TweenService:Create(img, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
			end
		end
		task.wait(0.25)
		currentHeaderFrame:Destroy()
		currentHeaderFrame = nil
	end
end

local module = {}

function module.feed(input, plr)
	local lines = typeof(input) == "table" and input or { input }

	for _, line in ipairs(lines) do
		table.insert(messageQueue, line)
	end

	if not isFeeding then
		isFeeding = true
		while #messageQueue > 0 do
			local msg = table.remove(messageQueue, 1)
			local isLast = #messageQueue == 0
			feedSingle(msg, plr, isLast)
			task.wait(2)
		end
		isFeeding = false
	end
end

return module
	