local addOn, Language = ...
local Keyboard = ConsolePortKeyboard
---------------------------------------------------------------
-- EditBox mime (mimicks entered text in focused editbox)
---------------------------------------------------------------
local Mime = CreateFrame("EditBox", "$parentMime", Keyboard)
Mime:Disable()
Mime:SetPoint("LEFT", Keyboard, "CENTER", 0, 64)
Mime:SetSize(1, 1)
Mime.Text = Mime:CreateFontString("$parentText", "BACKGROUND")
Mime.Text:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 18)
Mime.Text:SetShadowColor(0, 0, 0, 1)
Mime.Text:SetShadowOffset(1, -2)
Mime.Text:SetPoint("LEFT", Mime, "LEFT", 0, 0)

Mime.offset = 0

Mime.AniGroup = Mime:CreateAnimationGroup()
Mime.Animation = Mime.AniGroup:CreateAnimation("Translation")
Mime.Animation:SetDuration(0.2)
Mime.Animation:SetSmoothing("OUT")

Keyboard.Mime = Mime

function Mime:OnTextSet()
	local text = self:GetText()
	for pattern, replacement in pairs(Language.Markers) do
		text = text:gsub(pattern:gsub("%%", "%%%%"), replacement)
	end
	self.Text:SetText(text)
	self.Text:SetTextColor(self:GetTextColor())
	self:Animate()
end

function Mime:OnFinished()
	local self = self:GetParent()
	self:ClearAllPoints()
	self:SetPoint("LEFT", Keyboard, "CENTER", -self.Text:GetWidth()/2, 64)
end

function Mime:Animate()
	local newX = self.Text:GetWidth()/2
	Mime.Animation:SetOffset(self.offset-newX, 0)
	Mime.AniGroup:Play()
	self.offset = newX
end

Mime.AniGroup:SetScript("OnFinished", Mime.OnFinished)
Mime:SetScript("OnTextSet", Mime.OnTextSet)