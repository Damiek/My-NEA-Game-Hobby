local Astral = {}
local function Mode1_R(char:Model)
	print(char, "Cassted R Mode 1")

end

local function Mode1_Z(char:Model)
	print(char, "Cassted Z Mode 1")
end

local function Mode1_X(char:Model)
	print(char, "Casted X Mode 1")
end

local function Mode1_C(char:Model)
	print(char, "Casted C Mode 1")
end

local function Mode2_R(char:Model)
	print(char, "Casted R Mode 2")
end

local function Mode2_Z(char:Model)
	print(char, "Casted Z Mode 2")
end

local function Mode2_X(char:Model)
	print(char, "Casted X Mode 2")
end

local function Mode2_C(char:Model)
	print(char, "Casted C Mode 2")
end





function Astral.R(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_R(char)
	elseif char:GetAttribute("Mode1") then
		Mode1_R(char)

	else
		return
	end
end

function Astral.Z(char: Model)
	print(char, "None")
	if char:GetAttribute("Mode2") then
		Mode2_Z(char)
	elseif char:GetAttribute("Mode1") then
		Mode1_Z(char)

	else
		return
	end
end

function Astral.X(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_X(char)
	elseif char:GetAttribute("Mode1") then
		Mode1_X(char)

	else
		return
	end
end

function Astral.C(char: Model)
	if char:GetAttribute("Mode2") then
		Mode2_C(char)
	elseif char:GetAttribute("Mode1") then
		Mode1_C(char)

	else
		return
	end

end




return Astral
