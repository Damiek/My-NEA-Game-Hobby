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

	-- UI_inject: when a line is wider than the frame, shrink it to fit. If the
	-- required shrink drops below this ratio, word-wrap instead.
	MIN_FIT_SCALE = 0.75,

	-- Corrupt tag: chance per tick that a corrupted letter flashes its true
	-- glyph instead of a random one, and the min/max tick interval (in
	-- hundredths of a second) between glyph swaps.
	CORRUPT_REVEAL_CHANCE = 0.2,
	CORRUPT_SWAP_MIN = 4,
	CORRUPT_SWAP_MAX = 10,
}

local TARGET_DISPLAY_SIZE = 20
local DEFAULT_FONT = "MinecraftFont"
local UI_SET_TAG = "AutoLetterUI"
local activeInjections = {} -- keyed by targetFrame, module-level
local CORRUPT_POOL = {} -- keyed by fontName -> list of corruptible character names (fontmap glyphs, excludes "Æ")

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

local function buildCorruptPool(fontName, folder)
	local pool = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Æ" then
			table.insert(pool, child.Name)
		end
	end
	CORRUPT_POOL[fontName] = pool
end

local stringFolders = {}
for fontName, fontInfo in pairs(FontsModule.FontTable) do
	stringFolders[fontName] = buildStringFolder(fontName, fontInfo.FontData, fontInfo.FontMap, fontInfo.DisplaySize)
	buildCorruptPool(fontName, stringFolders[fontName])
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
						or (tagStack[idx]:match("^corrupt:") and closing == "corrupt")
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

-- Selects which letters within each word of `text` get corrupted, based on
-- `intensity` (how many letters per word, clamped to that word's length).
-- Returns a set keyed by grapheme start-byte-index (as returned by
-- utf8.graphemes) -> true for every letter chosen.
local function selectCorruptIndices(text, intensity)
	local selected = {}
	local wordIndices = {}

	local function flushWord()
		if #wordIndices == 0 then
			return
		end
		local count = math.min(intensity, #wordIndices)
		local pool = table.clone(wordIndices)
		for _ = 1, count do
			local pick = math.random(1, #pool)
			selected[pool[pick]] = true
			table.remove(pool, pick)
		end
		table.clear(wordIndices)
	end

	for i, j in utf8.graphemes(text) do
		local char = text:sub(i, j)
		if char:match("%s") then
			flushWord()
		else
			table.insert(wordIndices, i)
		end
	end
	flushWord()

	return selected
end

-- Corruption engine for the corrupt tag: cycles a letter's displayed glyph
-- between random characters from the fontmap and its own correct glyph, so
-- the word reads as garbled while still periodically flashing its true form.
local function applyCorruptEffect(imageLabel, fontName, parentLetter)
	local pool = CORRUPT_POOL[fontName]
	local folder = stringFolders[fontName]
	if not pool or #pool == 0 or not folder then
		return function() end
	end

	local correctImage = imageLabel.Image
	local correctRectOffset = imageLabel.ImageRectOffset
	local correctRectSize = imageLabel.ImageRectSize

	-- Snapshot correct glyph data for each outline clone too
	local outlineCorrect = {}
	if parentLetter then
		for _, child in ipairs(parentLetter:GetChildren()) do
			if child:IsA("ImageLabel") and child.Name:match("^Outline") then
				outlineCorrect[child] = {
					Image = child.Image,
					ImageRectOffset = child.ImageRectOffset,
					ImageRectSize = child.ImageRectSize,
				}
			end
		end
	end

	local active = true
	task.spawn(function()
		while active and imageLabel.Parent do
			if math.random() < CONFIG.CORRUPT_REVEAL_CHANCE then
				-- Reveal correct glyph on main and all outlines
				imageLabel.Image = correctImage
				imageLabel.ImageRectOffset = correctRectOffset
				imageLabel.ImageRectSize = correctRectSize
				for outline, data in pairs(outlineCorrect) do
					if outline.Parent then
						outline.Image = data.Image
						outline.ImageRectOffset = data.ImageRectOffset
						outline.ImageRectSize = data.ImageRectSize
					end
				end
			else
				-- Pick a random glyph and apply it to main and all outlines
				local randomChar = pool[math.random(1, #pool)]
				local template = folder:FindFirstChild(randomChar)
				local randomImage = template and template:FindFirstChildWhichIsA("ImageLabel")
				if randomImage then
					imageLabel.Image = randomImage.Image
					imageLabel.ImageRectOffset = randomImage.ImageRectOffset
					imageLabel.ImageRectSize = randomImage.ImageRectSize
					for outline, _ in pairs(outlineCorrect) do
						if outline.Parent then
							outline.Image = randomImage.Image
							outline.ImageRectOffset = randomImage.ImageRectOffset
							outline.ImageRectSize = randomImage.ImageRectSize
						end
					end
				end
			end
			task.wait(math.random(CONFIG.CORRUPT_SWAP_MIN, CONFIG.CORRUPT_SWAP_MAX) / 100)
		end
		-- Restore correct glyph on cleanup
		if imageLabel.Parent then
			imageLabel.Image = correctImage
			imageLabel.ImageRectOffset = correctRectOffset
			imageLabel.ImageRectSize = correctRectSize
		end
		for outline, data in pairs(outlineCorrect) do
			if outline.Parent then
				outline.Image = data.Image
				outline.ImageRectOffset = data.ImageRectOffset
				outline.ImageRectSize = data.ImageRectSize
			end
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

	-- Tags sit between plain-text chunks, so a single source space that borders
	-- a tag gets emitted twice (trailing of one chunk + leading of the next).
	-- Collapse consecutive space tokens across tag boundaries.
	local collapsed = {}
	local lastNonTagWasSpace = false
	for _, token in ipairs(tokens) do
		if token.isTag then
			table.insert(collapsed, token)
		elseif token.isSpace then
			if not lastNonTagWasSpace then
				table.insert(collapsed, token)
				lastNonTagWasSpace = true
			end
		else
			table.insert(collapsed, token)
			lastNonTagWasSpace = false
		end
	end
	tokens = collapsed

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
			elseif t:match("^corrupt:") then
				table.insert(close, "/corrupt")
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
						or (activeTags[idx]:match("^corrupt:") and realName == "corrupt")
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
	--local rawLineHeight = folder:GetAttribute("LineHeight") or 18
	--local targetDisplay = folder:GetAttribute("DisplaySize") or TARGET_DISPLAY_SIZE
	--local normScale = targetDisplay / rawLineHeight

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

		local corruptSelected
		for _, tag in ipairs(segment.tags) do
			local intensity = tag:match("^corrupt:(%d+)$")
			if intensity then
				corruptSelected = selectCorruptIndices(segment.text, tonumber(intensity))
				break
			end
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
						elseif tag:match("^corrupt:%d+$") then
							if corruptSelected and corruptSelected[i] then
								local stop = applyCorruptEffect(image, DEFAULT_FONT, newLetter)
								table.insert(activeStoppers, stop)
							end
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

	if activeInjections[targetFrame] then
		activeInjections[targetFrame]()
	end

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
	local useScale = options.useScale == true

	local horizontalAlignment = options.horizontalAlignment or Enum.HorizontalAlignment.Left
	local verticalAlignment = options.verticalAlignment or Enum.VerticalAlignment.Top

	local finalScaleModifier = normalizationMultiplier * textScale

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

	-- Width can still safely come from the container (assumed not auto-sizing on X).
	-- Height CANNOT come from the container anymore: Name/Title now use AutomaticSize.Y,
	-- meaning AbsoluteSize.Y sits at 0 until content exists inside them — deriving refHeight
	-- from it would be circular (glyphs wait on a size that only grows once glyphs exist).
	-- Derive refHeight from font metrics instead, which are known up front.
	local refWidth = targetFrame.AbsoluteSize.X > 0 and targetFrame.AbsoluteSize.X or CONFIG.MAX_LINE_WIDTH
	local refHeight = rawLineHeight * finalScaleModifier

	local targetWrapBoundary = refWidth

	local segmentsOrLines = {}
	for rawLine in string.gmatch(text .. "\n", "([^\n]*)\n") do
		local baseWidth = calculateTextWidth(rawLine, folder, 1) * finalScaleModifier

		if baseWidth > refWidth then
			local fitScale = refWidth / baseWidth
			if fitScale >= CONFIG.MIN_FIT_SCALE then
				table.insert(segmentsOrLines, {
					text = rawLine,
					scaleModifier = finalScaleModifier * fitScale,
				})
			else
				local wrapped = wrapText(rawLine, targetWrapBoundary, folder, finalScaleModifier)
				if #wrapped == 0 then
					table.insert(segmentsOrLines, { text = "", scaleModifier = finalScaleModifier })
				else
					for _, wLine in ipairs(wrapped) do
						table.insert(segmentsOrLines, { text = wLine, scaleModifier = finalScaleModifier })
					end
				end
			end
		else
			table.insert(segmentsOrLines, { text = rawLine, scaleModifier = finalScaleModifier })
		end
	end

	local instant = false
	local cancelled = false
	local activeStoppers = {}

	local function finishInstantly()
		instant = true
	end

	local function cancel()
		cancelled = true
		for _, stop in ipairs(activeStoppers) do
			stop()
		end
	end
	activeInjections[targetFrame] = cancel

	task.spawn(function()
		local letterCount = 0
		local lineIndex = 1

		for _, lineData in ipairs(segmentsOrLines) do
			if cancelled then
				return
			end

			local lineText = lineData.text
			local lineScaleModifier = lineData.scaleModifier

			local lineFrame = Instance.new("Frame")
			lineFrame.Name = "Line_" .. lineIndex
			lineFrame.BackgroundTransparency = 1
			lineFrame.AutomaticSize = Enum.AutomaticSize.Y
			lineFrame.Size = UDim2.new(1, 0, 0, 0)
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
				if cancelled then
					return
				end

				if segment.isPause and not instant then
					for _, tag in ipairs(segment.tags) do
						if tag:match("^pause:%d+%.?%d*$") then
							task.wait(tonumber(tag:match("pause:(%d+%.?%d*)")))
						end
					end
					continue
				end

				local corruptSelected
				for _, tag in ipairs(segment.tags) do
					local intensity = tag:match("^corrupt:(%d+)$")
					if intensity then
						corruptSelected = selectCorruptIndices(segment.text, tonumber(intensity))
						break
					end
				end

				for i, unit in utf8.graphemes(segment.text) do
					if cancelled then
						return
					end

					local char = segment.text:sub(i, unit)
					local template = folder:FindFirstChild(char)

					if template then
						local rawW = template.Size.X.Offset * lineScaleModifier
						local rawH = template.Size.Y.Offset * lineScaleModifier

						local wrapper = Instance.new("Frame")
						wrapper.Name = "LetterWrapper"
						wrapper.BackgroundTransparency = 1
						wrapper.Size = useScale and UDim2.new(rawW / refWidth, 0, rawH / refHeight, 0)
							or UDim2.fromOffset(rawW, rawH)
						wrapper.LayoutOrder = letterCount
						wrapper.Parent = lineFrame

						local letterFrame = template:Clone()
						letterFrame.Position = UDim2.fromOffset(0, 0)
						letterFrame.Size = UDim2.fromScale(1, 1)
						letterFrame.Visible = true
						letterFrame.Parent = wrapper
						letterCount += 1

						if options.onCharacter then
							options.onCharacter(char, letterFrame)
						end

						local image = letterFrame:FindFirstChildWhichIsA("ImageLabel")
						local emotionFired = false
						if image then
							local imgRawW = image.Size.X.Offset
							local imgRawH = image.Size.Y.Offset
							local imgRawPX = image.Position.X.Offset
							local imgRawPY = image.Position.Y.Offset

							if useScale then
								image.Size = UDim2.new(
									rawW > 0 and (imgRawW * lineScaleModifier) / rawW or 0,
									0,
									rawH > 0 and (imgRawH * lineScaleModifier) / rawH or 0,
									0
								)
								image.Position = UDim2.new(
									rawW > 0 and (imgRawPX * lineScaleModifier) / rawW or 0,
									0,
									rawH > 0 and (imgRawPY * lineScaleModifier) / rawH or 0,
									0
								)
							else
								image.Size = UDim2.fromOffset(imgRawW * lineScaleModifier, imgRawH * lineScaleModifier)
								image.Position =
									UDim2.fromOffset(imgRawPX * lineScaleModifier, imgRawPY * lineScaleModifier)
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
								elseif tag:match("^corrupt:%d+$") then
									if corruptSelected and corruptSelected[i] then
										local stop = applyCorruptEffect(image, fontName, letterFrame)
										table.insert(activeStoppers, stop)
									end
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

		if not cancelled then
			activeInjections[targetFrame] = nil
			if onComplete then
				onComplete()
			end
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
