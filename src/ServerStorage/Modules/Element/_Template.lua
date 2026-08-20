local Template = {}
Template.__index = Template

function Template.new()
	local self = setmetatable({
		Name = "Template" :: "Template",
		Data = {},
	}, Template)

	return self
end

function Template:Innate(char)
end

function Template:Mode1Init(char)
end

function Template:Mode2Init(char)
end

function Template:Mode1_R(char)
end

function Template:Mode1_Z(char)
end

function Template:Mode1_X(char)
end

function Template:Mode1_C(char)
end

function Template:Mode1_V(char)
end

function Template:Mode2_R(char)
end

function Template:Mode2_Z(char)
end

function Template:Mode2_X(char)
end

function Template:Mode2_C(char)
end

function Template:Mode2_V(char)
end

function Template:RevengeCounter(char: Model, target: Model)
end

function Template:R(char: Model)
	if char:GetAttribute("Mode2") then
		self:Mode2_R(char)
	elseif char:GetAttribute("Mode1") then
		self:Mode1_R(char)
	end
end

function Template:Z(char: Model)
	if char:GetAttribute("Mode2") then
		self:Mode2_Z(char)
	elseif char:GetAttribute("Mode1") then
		self:Mode1_Z(char)
	end
end

function Template:X(char: Model)
	if char:GetAttribute("Mode2") then
		self:Mode2_X(char)
	elseif char:GetAttribute("Mode1") then
		self:Mode1_X(char)
	end
end

function Template:C(char: Model)
	if char:GetAttribute("Mode2") then
		self:Mode2_C(char)
	elseif char:GetAttribute("Mode1") then
		self:Mode1_C(char)
	end
end

function Template:V(char: Model)
	if char:GetAttribute("Mode2") then
		self:Mode2_V(char)
	elseif char:GetAttribute("Mode1") then
		self:Mode1_V(char)
	end
end

export type TemplateObject = typeof(Template.new())

return Template
