local module = {}
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local FontsModule = require(script.Fonts)
local DialogueBindable = RS:FindFirstChild("DialogueBindable", true)

-- =============================================
-- CONFIG
-- =============================================

local CONFIG = {
	MAX_LINE_WIDTH = 800,
	LETTER_DELAY = 0.1,
	FADE_IN_TIME = 0.1,
	FADE_OUT_TIME = 0.03,
	READ_TIME = 1.5,
	SIZE = 18,

	USE_OUTLINE = true,
	OUTLINE_COLOR = Color3.new(0, 0, 0),
	OUTLINE_TRANSPARENCY = 0.3,
	SHADOW_OFFSET = Vector2.new(2, 2),

	SHAKE_MAGNITUDE = 2,
	SHAKE_SPEED = 0.02,
}

local TARGET_DISPLAY_SIZE = 20
local DEFAULT_FONT = "MinecraftFont"
local UI_SET_TAG = "AutoLetterUI"

-- =============================================
-- FONT INITIALIZATION
-- =============================================

local function parseFontData(s)
	local info = { fontInfo = {}, characterTable = {}, kernings = {}, lineHeight = 18 }

	local lineMatch = s:match("lineHeight=(%d+)")
	if lineMatch then
		info.lineHeight = tonumber(lineMatch)
	end

	local kernStart = s:find("kernings")
	if kernStart then
		for _, line in ipairs(s:sub(kernStart):split("\n")) do
			local first, second, amount =
				line:match("kerning first=([%-?%.?%d?]+) second=([%-?%.?%d?]+) amount=([%-?%.?%d?]+)")
			if first then
				info.kernings[utf8.char(first)] = info.kernings[utf8.char(first)] or {}
				info.kernings[utf8.char(first)][utf8.char(second)] = amount
			end
		end
		s = s:sub(1, kernStart - 1)
	end

	local split = s:split("\n")
	for i = 3, 1, -1 do
		if split[i] then
			for _, token in ipairs(split[i]:split(" ")) do
				local field, value = unpack(token:split("="))
				if field and value then
					field = field:gsub('"', "")
					value = value:gsub('"', "")
					info.fontInfo[field] = tonumber(value) or value
				end
			end
		end
		table.remove(split, i)
	end
	table.remove(split, 1)

	for i = #split, 1, -1 do
		local charId, x, y, w, h, xOff, yOff, xAdv, page, chnl = split[i]:match(
			"char id=([%-?%.?%d?]+) x=([%-?%.?%d?]+) y=([%-?%.?%d?]+) "
				.. "width=([%-?%.?%d?]+) height=([%-?%.?%d?]+) "
				.. "xoffset=([%-?%.?%d?]+) yoffset=([%-?%.?%d?]+) "
				.. "xadvance=([%-?%.?%d?]+) page=([%-?%.?%d?]+) chnl=([%-?%.?%d?]+)"
		)
		if charId then
			table.remove(split, i)
			table.insert(info.characterTable, {
				charId = charId,
				x = x,
				y = y,
				width = w,
				height = h,
				xOffset = xOff,
				yOffset = yOff,
				xAdvance = xAdv,
				page = page,
				chnl = chnl,
			})
		end
	end

	return info
end

local function buildStringFolder(fontName, fontData, fontMap, displaySize)
	local parsed = parseFontData(fontData)
	local folder = Instance.new("Folder")
	folder.Name = fontName
	folder:SetAttribute("LineHeight", parsed.lineHeight)
	folder:SetAttribute("DisplaySize", displaySize or parsed.lineHeight)
	folder.Parent = script

	for _, v in ipairs(parsed.characterTable) do
		local charFrame = Instance.new("Frame")
		charFrame.Name = utf8.char(v.charId)
		charFrame.Size = UDim2.fromOffset(tonumber(v.xAdvance) or tonumber(v.width), parsed.lineHeight)
		charFrame.BackgroundTransparency = 1

		local img = Instance.new("ImageLabel")
		img.Image = fontMap
		img.Size = UDim2.fromOffset(tonumber(v.width), tonumber(v.height))
		img.Position = UDim2.fromOffset(tonumber(v.xOffset), tonumber(v.yOffset))
		img.ImageRectSize = Vector2.new(tonumber(v.width), tonumber(v.height))
		img.ImageRectOffset = Vector2.new(tonumber(v.x), tonumber(v.y))
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Parent = charFrame

		charFrame.Parent = folder
	end

	return folder
end

local stringFolders = {}
for fontName, fontInfo in pairs(FontsModule.FontTable) do
	stringFolders[fontName] = buildStringFolder(fontName, fontInfo.FontData, fontInfo.FontMap, fontInfo.DisplaySize)
end

-- =============================================
-- SHARED INTERNAL HELPERS
-- =============================================

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

			if tagText:match("^pause:%d+%.?%d*$") then
				table.insert(segments, { text = "", tags = { tagText }, isPause = true })
			elseif tagText:sub(1, 1) == "/" then
				local closing = tagText:sub(2)
				for idx = #tagStack, 1, -1 do
					if
						(tagStack[idx]:match("^colour:") and closing == "colour")
						or (tagStack[idx]:match("^emotion:") and closing:match("^emotion:"))
						or tagStack[idx] == closing
					then
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
			if remaining ~= "" then
				table.insert(segments, { text = remaining, tags = table.clone(tagStack) })
			end
			break
		end
	end

	return segments
end

local function applyShakeEffect(letterFrame, imageLabel)
	local origFrame = letterFrame.Position
	local origImage = imageLabel.Position
	local active = true

	task.spawn(function()
		while active do
			local rx = math.random(-CONFIG.SHAKE_MAGNITUDE, CONFIG.SHAKE_MAGNITUDE)
			local ry = math.random(-CONFIG.SHAKE_MAGNITUDE, CONFIG.SHAKE_MAGNITUDE)
			letterFrame.Position = origFrame + UDim2.new(0, rx, 0, ry)
			imageLabel.Position = origImage + UDim2.new(0, rx, 0, ry)
			task.wait(CONFIG.SHAKE_SPEED)
		end
		letterFrame.Position = origFrame
		imageLabel.Position = origImage
	end)

	return function()
		active = false
	end
end

-- Controlled distortion engine for the corrupt tag
local function applyCorruptEffect(wrapperFrame, letterFrame, imageLabel, baseWidth, baseHeight)
	local active = true
	task.spawn(function()
		while active and letterFrame.Parent do
			local offsetY = math.random(-12, 12)
			local offsetX = math.random(-3, 3)
			letterFrame.Position = UDim2.fromOffset(offsetX, offsetY)

			local scaleMultiplier = math.random(7, 16) / 10
			wrapperFrame.Size = UDim2.fromOffset(baseWidth * scaleMultiplier, baseHeight * scaleMultiplier)

			imageLabel.ImageTransparency = math.random(0, 4) / 10

			task.wait(math.random(3, 8) / 100)
		end
		if letterFrame.Parent then
			letterFrame.Position = UDim2.fromOffset(0, 0)
			imageLabel.ImageTransparency = 0
		end
	end)
	return function()
		active = false
	end
end

local function applyOutline(image, parentLetter)
	local offsets = {
		{ -1, -1 },
		{ 0, -1 },
		{ 1, -1 },
		{ -1, 0 },
		{ 1, 0 },
		{ -1, 1 },
		{ 0, 1 },
		{ 1, 1 },
	}
	for idx, off in ipairs(offsets) do
		local clone = image:Clone()
		clone.Name = "Outline" .. idx
		clone.ImageColor3 = CONFIG.OUTLINE_COLOR
		clone.ZIndex = image.ZIndex - 1
		clone.Position = image.Position + UDim2.fromOffset(off[1], off[2])
		clone.ImageTransparency = 1
		clone.Parent = parentLetter
		TweenService
			:Create(clone, TweenInfo.new(CONFIG.FADE_IN_TIME), { ImageTransparency = CONFIG.OUTLINE_TRANSPARENCY })
			:Play()
	end
end

local function applyColorTag(image, tags)
	for _, tag in ipairs(tags) do
		local hex = tag:match("^colour:#(%x%x%x%x%x%x%x?%x?)$") or tag:match("^colour:#(%x%x%x)$")

		if hex then
			if #hex == 3 then
				local r, g, b = hex:sub(1, 1), hex:sub(2, 2), hex:sub(3, 3)
				hex = r .. r .. g .. g .. b .. b
			elseif #hex > 6 then
				hex = hex:sub(1, 6)
			end

			image.ImageColor3 = Color3.new(
				tonumber(hex:sub(1, 2), 16) / 255,
				tonumber(hex:sub(3, 4), 16) / 255,
				tonumber(hex:sub(5, 6), 16) / 255
			)
			break
		end
	end
end

local function calculateTextWidth(text, folder, scaleMod)
	local width = 0
	local cleanText = text:gsub("<[^>]*>", "")
	for i, unit in utf8.graphemes(cleanText) do
		local char = cleanText:sub(i, unit)
		local template = folder:FindFirstChild(char)
		if template then
			width += (template.Size.X.Offset * scaleMod)
		end
	end
	return width
end

-- =============================================
-- TAG-AWARE WORD WRAP
-- =============================================
local function wrapText(str, maxWidth, folder, scaleMod)
	local lines = {}
	local activeTags = {}

	local tokens = {}
	local index = 1
	while index <= #str do
		local tagStart, tagEnd = str:find("<[^>]*>", index)
		if tagStart == index then
			table.insert(tokens, { isTag = true, text = str:sub(tagStart, tagEnd) })
			index = tagEnd + 1
		else
			local nextTag = tagStart or (#str + 1)
			local plainText = str:sub(index, nextTag - 1)

			for space, word in plainText:gmatch("(%s*)(%S+)") do
				if space ~= "" then
					table.insert(tokens, { isTag = false, isSpace = true, text = space })
				end
				table.insert(tokens, { isTag = false, text = word })
			end
			local trailingSpace = plainText:match("%s*$")
			if trailingSpace and trailingSpace ~= "" and not plainText:match("^%s*$") then
				table.insert(tokens, { isTag = false, isSpace = true, text = trailingSpace })
			end
			index = nextTag
		end
	end

	local currentLine = ""
	local currentWidth = 0

	local function getPrefixTags()
		if #activeTags == 0 then
			return ""
		end
		return "<" .. table.concat(activeTags, "><") .. ">"
	end

	local function getSuffixTags()
		if #activeTags == 0 then
			return ""
		end
		local close = {}
		for idx = #activeTags, 1, -1 do
			local t = activeTags[idx]
			if t:match("^colour:") then
				table.insert(close, "/colour")
			elseif t:match("^emotion:") then
				table.insert(close, "/emotion")
			else
				table.insert(close, "/" .. t)
			end
		end
		return "<" .. table.concat(close, "></") .. ">"
	end

	for _, token in ipairs(tokens) do
		if token.isTag then
			currentLine = currentLine .. token.text
			local tagName = token.text:sub(2, -2)
			if tagName:sub(1, 1) == "/" then
				local realName = tagName:sub(2)
				for idx = #activeTags, 1, -1 do
					if
						(activeTags[idx]:match("^colour:") and realName == "colour")
						or (activeTags[idx]:match("^emotion:") and realName == "emotion")
						or activeTags[idx] == realName
					then
						table.remove(activeTags, idx)
						break
					end
				end
			else
				table.insert(activeTags, tagName)
			end
		else
			local wordWidth = calculateTextWidth(token.text, folder, scaleMod)
			if currentWidth + wordWidth > maxWidth and not token.isSpace then
				table.insert(lines, currentLine .. getSuffixTags())
				currentLine = getPrefixTags() .. token.text
				currentWidth = wordWidth
			else
				currentLine = currentLine .. token.text
				currentWidth = currentWidth + wordWidth
			end
		end
	end

	if currentLine ~= "" then
		table.insert(lines, currentLine)
	end

	return lines
end

-- =============================================
-- SUBTITLES
-- =============================================

local messageQueue = {}
local isFeeding = false
local currentHeaderFrame

local function subtitleSingle(str, plr, isLast)
	local folder = stringFolders[DEFAULT_FONT]
	local rawLineHeight = folder:GetAttribute("LineHeight") or 18
	local targetDisplay = folder:GetAttribute("DisplaySize") or TARGET_DISPLAY_SIZE
	local normScale = targetDisplay / rawLineHeight

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

		local hFrame = Instance.new("Frame")
		hFrame.BackgroundTransparency = 1
		hFrame.Size = UDim2.new(1, 0, 0, TARGET_DISPLAY_SIZE)
		hFrame.AutomaticSize = Enum.AutomaticSize.X
		hFrame.ClipsDescendants = false
		hFrame.Parent = subtitleContainer

		local hLayout = Instance.new("UIListLayout")
		hLayout.FillDirection = Enum.FillDirection.Horizontal
		hLayout.SortOrder = Enum.SortOrder.LayoutOrder
		hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		hLayout.Parent = hFrame

		for i, unit in utf8.graphemes(headerText) do
			local char = headerText:sub(i, unit)
			local template = folder:FindFirstChild(char)
			if template then
				local letter = template:Clone()
				letter.Visible = true
				letter.LayoutOrder = i
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					img.ImageTransparency = 1
					TweenService:Create(img, TweenInfo.new(0.5), { ImageTransparency = 0 }):Play()
				end
				letter.Parent = hFrame
			end
		end

		currentHeaderFrame = hFrame
	end

	local newFrame = Instance.new("Frame")
	newFrame.BackgroundTransparency = 1
	newFrame.Size = UDim2.new(1, 0, 0, TARGET_DISPLAY_SIZE)
	newFrame.ClipsDescendants = false
	newFrame.AutomaticSize = Enum.AutomaticSize.X
	newFrame.Name = "DialogueLine"
	newFrame.Parent = subtitleContainer

	local lineLayout = Instance.new("UIListLayout")
	lineLayout.SortOrder = Enum.SortOrder.LayoutOrder
	lineLayout.FillDirection = Enum.FillDirection.Horizontal
	lineLayout.Padding = UDim.new(0, 0)
	lineLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lineLayout.Parent = newFrame

	local letterCount = 0
	local activeStoppers = {}

	for _, segment in ipairs(parsed) do
		if segment.isPause then
			for _, tag in ipairs(segment.tags) do
				if tag:match("^pause:%d+%.?%d*$") then
					task.wait(tonumber(tag:match("pause:(%d+%.?%d*)")))
				end
			end
			continue
		end

		for i, unit in utf8.graphemes(segment.text) do
			local char = segment.text:sub(i, unit)
			local template = folder:FindFirstChild(char)

			if template then
				local newLetter = template:Clone()
				newLetter.LayoutOrder = letterCount
				newLetter.Visible = true
				newLetter.Parent = newFrame
				letterCount += 1

				local image = newLetter:FindFirstChildWhichIsA("ImageLabel")
				if image then
					if CONFIG.USE_OUTLINE then
						applyOutline(image, newLetter)
					end
					applyColorTag(image, segment.tags)
					image.ImageTransparency = 1
					TweenService:Create(image, TweenInfo.new(CONFIG.FADE_IN_TIME), { ImageTransparency = 0 }):Play()

					for _, tag in ipairs(segment.tags) do
						if tag == "shake" then
							local stop = applyShakeEffect(newLetter, image)
							table.insert(activeStoppers, stop)
						elseif tag == "corrupt" then
							local stop = applyCorruptEffect(
								newLetter,
								newLetter,
								image,
								template.Size.X.Offset * normScale,
								template.Size.Y.Offset * normScale
							)
							table.insert(activeStoppers, stop)
						elseif tag:match("^emotion:") and DialogueBindable then
							local emotion = tag:match("^emotion:(.+)$")
							DialogueBindable:Fire("PlayAnimation", emotion)
						elseif tag:match("^sound:rbxassetid://%d+$") then
							local soundId = tag:match("sound:rbxassetid://(%d+)")
							local snd = Instance.new("Sound")
							snd.SoundId = "rbxassetid://" .. soundId
							snd.Volume = 1
							snd.Parent = plr.PlayerGui or workspace.CurrentCamera
							snd:Play()
							Debris:AddItem(snd, 2)
						end
					end
				end

				task.wait(CONFIG.LETTER_DELAY)
			end
		end
	end

	task.wait(CONFIG.READ_TIME)

	for t = 0, 1, 0.1 do
		for _, letter in ipairs(newFrame:GetChildren()) do
			if letter:IsA("Frame") then
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					img.ImageTransparency = t
				end
				for _, child in ipairs(letter:GetChildren()) do
					if child.Name:match("^Outline") and child:IsA("ImageLabel") then
						child.ImageTransparency = math.clamp(
							CONFIG.OUTLINE_TRANSPARENCY + t * (1 - CONFIG.OUTLINE_TRANSPARENCY),
							CONFIG.OUTLINE_TRANSPARENCY,
							1
						)
					end
				end
			end
		end
		task.wait(CONFIG.FADE_OUT_TIME)
	end

	for _, stopFunc in ipairs(activeStoppers) do
		stopFunc()
	end
	newFrame:Destroy()

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

function module.subtitles(input, plr)
	local folder = stringFolders[DEFAULT_FONT]
	local rawLineHeight = folder:GetAttribute("LineHeight") or 18
	local normScale = TARGET_DISPLAY_SIZE / rawLineHeight

	local lines = typeof(input) == "table" and input or { input }
	local wrappedLines = {}

	for _, line in ipairs(lines) do
		local headerText = line:match("<h>(.-)<h>")
		local mainText = line:gsub("<h>.-<h>", "")
		local wrapped = wrapText(mainText, CONFIG.MAX_LINE_WIDTH, folder, normScale)

		if headerText and wrapped[1] then
			wrapped[1] = "<h>" .. headerText .. "<h>" .. wrapped[1]
		end
		for _, w in ipairs(wrapped) do
			table.insert(wrappedLines, w)
		end
	end

	for _, line in ipairs(wrappedLines) do
		table.insert(messageQueue, line)
	end

	if not isFeeding then
		isFeeding = true
		while #messageQueue > 0 do
			local msg = table.remove(messageQueue, 1)
			subtitleSingle(msg, plr, #messageQueue == 0)
			task.wait(2)
		end
		isFeeding = false
	end
end

-- =============================================
-- UI_INJECT
-- =============================================
function module.UI_inject(targetFrame, text, fontName, options)
	fontName = fontName or DEFAULT_FONT
	options = options or {}

	local folder = stringFolders[fontName]
	if not folder then
		warn(("UI_inject: font '%s' not found in FontsModule.FontTable"):format(tostring(fontName)))
		return function() end
	end

	local rawLineHeight = folder:GetAttribute("LineHeight") or 18
	local targetDisplay = folder:GetAttribute("DisplaySize") or TARGET_DISPLAY_SIZE
	local normalizationMultiplier = targetDisplay / rawLineHeight

	local letterDelay = options.letterDelay ~= nil and options.letterDelay or CONFIG.LETTER_DELAY
	local fadeInTime = options.fadeInTime ~= nil and options.fadeInTime or CONFIG.FADE_IN_TIME
	local useOutline = options.useOutline ~= nil and options.useOutline or CONFIG.USE_OUTLINE
	local clearFirst = options.clearFirst ~= false
	local onComplete = options.onComplete
	local textScale = options.textScale ~= nil and options.textScale or 1
	local useScale = options.useScale == true -- nil/false -> offset, true -> scale

	-- Alignment passthrough: defaults to Left/Top to match original hardcoded behavior
	local horizontalAlignment = options.horizontalAlignment or Enum.HorizontalAlignment.Left
	local verticalAlignment = options.verticalAlignment or Enum.VerticalAlignment.Top

	local finalScaleModifier = normalizationMultiplier * textScale

	-- Fixed Content Injection Loop: Clear only injected line rows, never UI infrastructure objects
	if clearFirst then
		for _, child in ipairs(targetFrame:GetChildren()) do
			if child:IsA("Frame") and child.Name:match("^Line_") then
				child:Destroy()
			end
		end
	end

	local mainLayout = targetFrame:FindFirstChildWhichIsA("UIListLayout")
	if not mainLayout then
		mainLayout = Instance.new("UIListLayout")
		mainLayout.FillDirection = Enum.FillDirection.Vertical
		mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
		mainLayout.Parent = targetFrame
	end
	mainLayout.HorizontalAlignment = horizontalAlignment
	mainLayout.VerticalAlignment = verticalAlignment
	mainLayout.Padding = UDim.new(0, 0)

	local targetWrapBoundary = targetFrame.AbsoluteSize.X > 0 and targetFrame.AbsoluteSize.X or CONFIG.MAX_LINE_WIDTH

	local segmentsOrLines = {}
	for rawLine in string.gmatch(text .. "\n", "([^\n]*)\n") do
		local wrapped = wrapText(rawLine, targetWrapBoundary, folder, finalScaleModifier)
		if #wrapped == 0 then
			table.insert(segmentsOrLines, "")
		else
			for _, wLine in ipairs(wrapped) do
				table.insert(segmentsOrLines, wLine)
			end
		end
	end

	local instant = false
	local activeStoppers = {}

	local function finishInstantly()
		instant = true
	end

	task.spawn(function()
		local letterCount = 0
		local lineIndex = 1

		for _, lineText in ipairs(segmentsOrLines) do
			local lineFrame = Instance.new("Frame")
			lineFrame.Name = "Line_" .. lineIndex
			lineFrame.BackgroundTransparency = 1
			if useScale then
				lineFrame.Size = UDim2.new(1, 0, 0, TARGET_DISPLAY_SIZE * textScale) -- kept as-is; scale mode governs letters below
			else
				lineFrame.Size = UDim2.new(1, 0, 0, TARGET_DISPLAY_SIZE * textScale)
			end
			lineFrame.ClipsDescendants = false
			lineFrame.LayoutOrder = lineIndex
			lineFrame.Parent = targetFrame

			local lineLayout = Instance.new("UIListLayout")
			lineLayout.FillDirection = Enum.FillDirection.Horizontal
			lineLayout.SortOrder = Enum.SortOrder.LayoutOrder
			lineLayout.HorizontalAlignment = horizontalAlignment
			lineLayout.Parent = lineFrame

			if lineText == "" then
				lineIndex += 1
				continue
			end

			local parsed = parseTags(lineText)

			for _, segment in ipairs(parsed) do
				if segment.isPause and not instant then
					for _, tag in ipairs(segment.tags) do
						if tag:match("^pause:%d+%.?%d*$") then
							task.wait(tonumber(tag:match("pause:(%d+%.?%d*)")))
						end
					end
					continue
				end

				for i, unit in utf8.graphemes(segment.text) do
					local char = segment.text:sub(i, unit)
					local template = folder:FindFirstChild(char)

					if template then
						local rawCharW = template.Size.X.Offset * finalScaleModifier
						local rawCharH = template.Size.Y.Offset * finalScaleModifier

						local wrapper = Instance.new("Frame")
						wrapper.Name = "LetterWrapper"
						wrapper.BackgroundTransparency = 1
						if useScale then
							-- Scale relative to the parent line frame's absolute size at build time
							local parentAbsX = lineFrame.AbsoluteSize.X
							local parentAbsY = lineFrame.AbsoluteSize.Y
							wrapper.Size = UDim2.fromScale(
								parentAbsX > 0 and (rawCharW / parentAbsX) or 0,
								parentAbsY > 0 and (rawCharH / parentAbsY) or 1
							)
						else
							wrapper.Size = UDim2.fromOffset(rawCharW, rawCharH)
						end
						wrapper.LayoutOrder = letterCount
						wrapper.Parent = lineFrame

						local letterFrame = template:Clone()
						letterFrame.Position = UDim2.fromOffset(0, 0)
						letterFrame.Size = UDim2.fromScale(1, 1)
						letterFrame.Visible = true
						letterFrame.Parent = wrapper
						letterCount += 1

						local image = letterFrame:FindFirstChildWhichIsA("ImageLabel")
						local emotionFired = false
						if image then
							local rawW = image.Size.X.Offset
							local rawH = image.Size.Y.Offset
							local rawPX = image.Position.X.Offset
							local rawPY = image.Position.Y.Offset

							if useScale then
								-- Image fills its letterFrame (which is already scale-sized to 1,1);
								-- position/size the glyph as scale-of-wrapper instead of raw offset.
								local parentAbsX = wrapper.AbsoluteSize.X
								local parentAbsY = wrapper.AbsoluteSize.Y
								image.Size = UDim2.fromScale(
									parentAbsX > 0 and ((rawW * finalScaleModifier) / parentAbsX) or 1,
									parentAbsY > 0 and ((rawH * finalScaleModifier) / parentAbsY) or 1
								)
								image.Position = UDim2.fromScale(
									parentAbsX > 0 and ((rawPX * finalScaleModifier) / parentAbsX) or 0,
									parentAbsY > 0 and ((rawPY * finalScaleModifier) / parentAbsY) or 0
								)
							else
								image.Size = UDim2.fromOffset(rawW * finalScaleModifier, rawH * finalScaleModifier)
								image.Position =
									UDim2.fromOffset(rawPX * finalScaleModifier, rawPY * finalScaleModifier)
							end

							if useOutline then
								applyOutline(image, letterFrame)
							end
							applyColorTag(image, segment.tags)

							image.ImageTransparency = 1
							TweenService
								:Create(image, TweenInfo.new(instant and 0 or fadeInTime), { ImageTransparency = 0 })
								:Play()

							for _, tag in ipairs(segment.tags) do
								if tag == "shake" then
									local active = true
									task.spawn(function()
										while active and letterFrame.Parent do
											local rx = math.random(-CONFIG.SHAKE_MAGNITUDE, CONFIG.SHAKE_MAGNITUDE)
												* textScale
											local ry = math.random(-CONFIG.SHAKE_MAGNITUDE, CONFIG.SHAKE_MAGNITUDE)
												* textScale

											letterFrame.Position = UDim2.fromOffset(rx, ry)
											task.wait(CONFIG.SHAKE_SPEED)
										end
										if letterFrame.Parent then
											letterFrame.Position = UDim2.fromOffset(0, 0)
										end
									end)
									table.insert(activeStoppers, function()
										active = false
									end)
								elseif tag == "corrupt" then
									local stop = applyCorruptEffect(
										wrapper,
										letterFrame,
										image,
										template.Size.X.Offset * finalScaleModifier,
										template.Size.Y.Offset * finalScaleModifier
									)
									table.insert(activeStoppers, stop)
								elseif tag:match("^emotion:") and DialogueBindable and not emotionFired then
									local emotion = tag:match("^emotion:(.+)$")
									DialogueBindable:Fire("PlayAnimation", emotion)
									emotionFired = true
								end
							end
						end

						if not instant then
							task.wait(letterDelay)
						end
					end
				end
			end

			lineIndex += 1
		end

		if onComplete then
			onComplete()
		end
	end)

	return finishInstantly
end

-- =============================================
-- UI_SET (tag-driven one-time bake)
-- =============================================
-- Tag goes on the GUI/container itself (e.g. a ScreenGui or Frame), not on
-- individual TextLabels/TextBoxes. Every TextLabel/TextBox descendant of a
-- tagged container gets its .Text baked into the letter-based UI_inject
-- structure, in place, once. This is a build-time operation, not a runtime
-- system — call it once (server start / plugin run), not on a loop.
function module.UI_Set(tag)
	tag = tag or UI_SET_TAG

	for _, container in ipairs(CollectionService:GetTagged(tag)) do
		local ok, err = pcall(function()
			for _, sourceInstance in ipairs(container:GetDescendants()) do
				if sourceInstance:IsA("TextLabel") or sourceInstance:IsA("TextBox") then
					local text = sourceInstance.Text
					if not text or text == "" then
						continue
					end

					local parent = sourceInstance.Parent
					local fontName = sourceInstance:GetAttribute("FontName") or DEFAULT_FONT

					local xAlign = Enum.HorizontalAlignment[sourceInstance.TextXAlignment.Name]
					local yAlign = Enum.VerticalAlignment[sourceInstance.TextYAlignment.Name]

					local targetFrame = Instance.new("Frame")
					targetFrame.Name = sourceInstance.Name .. "_Letters"
					targetFrame.Size = sourceInstance.Size
					targetFrame.Position = sourceInstance.Position
					targetFrame.AnchorPoint = sourceInstance.AnchorPoint
					targetFrame.BackgroundTransparency = 1
					targetFrame.LayoutOrder = sourceInstance.LayoutOrder
					targetFrame.Parent = parent

					module.UI_inject(targetFrame, text, fontName, {
						letterDelay = 0,
						fadeInTime = 0,
						clearFirst = true,
						horizontalAlignment = xAlign,
						verticalAlignment = yAlign,
					})

					sourceInstance:Destroy()
				end
			end

			CollectionService:RemoveTag(container, tag)
		end)

		if not ok then
			warn(("UI_Set failed on %s: %s"):format(container:GetFullName(), tostring(err)))
		end
	end
end

return module