local _, db = ...
----------------------------------
local function HintSort(_, a, b)
    local priority = { PADL = 1, PADR = 3 }

    local aPrefix = a:match('^PAD[LR]') or a;
    local bPrefix = b:match('^PAD[LR]') or b;

    if aPrefix ~= bPrefix then
        return (priority[aPrefix] or 2) < (priority[bPrefix] or 2)
    end

    return a < b;
end
----------------------------------
-- Hint mixin
----------------------------------
CPHintMixin = {}

function CPHintMixin:OnLoad()
	self.bar = self:GetParent()
	self.Text:SetShadowOffset(2, -2)
end

function CPHintMixin:OnShow()
	self.isActive = true
	db.Alpha.FadeIn(self, 0.2, 0, 1)
end

function CPHintMixin:OnHide()
	self.isActive = false
	self:SetData(nil, nil)
end

function CPHintMixin:UpdateParentWidth()
	if self.bar then
		self.bar:Update()
	end
end

function CPHintMixin:Enable()
	self.Icon:SetVertexColor(1, 1, 1)
	self.Text:SetVertexColor(1, 1, 1)
end

function CPHintMixin:Disable()
	self.Icon:SetVertexColor(0.5, 0.5, 0.5)
	self.Text:SetVertexColor(0.5, 0.5, 0.5)
end

function CPHintMixin:GetText()
	return self.Text:GetText()
end

function CPHintMixin:SetData(icon, text)
	db.Gamepad.SetIconToTexture(self.Icon, icon)
	self.Text:SetText(text)
	self:SetWidth(self.Text:GetStringWidth() + self.Icon:GetWidth() + 18)
	self:UpdateParentWidth()
	self:ClearTimer()
end

function CPHintMixin:SetTimer(duration)
	local timer = self:GetTimer(true)
	CooldownFrame_Set(timer, GetTime(), duration, 1, true)
end

function CPHintMixin:ClearTimer()
	local timer = self:GetTimer(false)
	if timer then
		CooldownFrame_Clear(self:GetTimer())
	end
end

function CPHintMixin:GetTimer(create)
	if not self.timer then
		if not create then return end;
		self.timer = CreateFrame('Cooldown', nil, self, 'CPHintTimerTemplate')
		self.timer:SetPoint('CENTER', self.Icon, 'CENTER', 0, 0)
	end
	return self.timer;
end

----------------------------------
-- HintBar mixin
----------------------------------
CPHintBarMixin = {}

function CPHintBarMixin:OnLoad()
	self.Hints = {}
	self:SetAlpha(0)
	self:SetParent(UIParent)
	self:SetIgnoreParentAlpha(true)
	self:SetFrameStrata('FULLSCREEN_DIALOG')
	db:RegisterCallback('Settings/UIscale', self.SetScale, self)
end

function CPHintBarMixin:Show()
	self:SetScale(db('UIscale'))
	getmetatable(self).__index.Show(self)
	db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
end

function CPHintBarMixin:Hide()
	db.Alpha.FadeOut(self, 0.1, self:GetAlpha(), 0, {
		finishedFunc = getmetatable(self).__index.Hide;
		finishedArg1 = self;
	})
end

function CPHintBarMixin:AdjustWidth(newWidth)
	self:SetScript('OnUpdate', function(self)
		local width = self:GetWidth()
		local diff = newWidth - width
		if abs(newWidth - width) < 1 then
			self:SetWidth(newWidth)
			self:SetScript('OnUpdate', nil)
		else
			self:SetWidth(width + ( diff / 4 ) )
		end
	end)
end

function CPHintBarMixin:Update()
	local width, previousHint = 0
	for _, hint in db.table.spairs(self.Hints, HintSort) do
		hint:ClearAllPoints()
		if previousHint then
			hint:SetPoint('LEFT', previousHint.Text, 'RIGHT', 16, 0)
		else
			hint:SetPoint('LEFT', self, 'LEFT', 0, 0)
		end
		if hint:IsVisible() then
			width = width + hint:GetWidth()
			previousHint = hint
		end
	end
	self:AdjustWidth(width)
end

function CPHintBarMixin:Reset()
	for _, hint in pairs(self.Hints) do
		hint:Hide()
	end
end

function CPHintBarMixin:GetHintFromPool(key, showBar)
	local hints = self.Hints
	local hint = hints[key]
	if not hint then
		hint = CreateFrame('Frame', '$parentHint'..key, self, 'CPHintTemplate')
		self.Hints[key] = hint
	end
	hint:Show()
	if showBar then
		self:Show()
	end
	return hint
end

function CPHintBarMixin:GetActiveHintForKey(key)
	local hint = self.Hints[key]
	return hint and hint.isActive and hint
end

function CPHintBarMixin:AddHint(key, text)
	local binding = db.UIHandle:GetUIControlBinding(key)
	if binding then
		local hint = self:GetHintFromPool(key)
		hint:SetData(binding, text)
		hint:Enable()
		return hint
	end
end

----------------------------------
-- HintFocus mixin
----------------------------------
CPHintFocusMixin = {}

function CPHintFocusMixin:SetHint(key, text)
	self.hints = self.hints or {};
	self.hints[key] = text;
end

function CPHintFocusMixin:OnEnter()
	if self.hints and next(self.hints) and self:GetAttribute('hintOnEnter') then
		self:ShowHints()
	end
end

function CPHintFocusMixin:OnLeave()
	if self.hints and self:GetAttribute('hintOnLeave') then
		self:HideHints()
	end
end

function CPHintFocusMixin:ShowHints()
	if self.hints then
		for key, text in db.table.spairs(self.hints, HintSort) do
			self.handle:AddHint(key, text)
		end
	end
end

function CPHintFocusMixin:HideHints()
	if self.hints then
		for key in pairs(hints) do
			self.handle:RemoveHint(key)
		end
	end
end

function CPHintFocusMixin:SetHintHandle(handle)
	self.handle = handle;
end

function CPHintFocusMixin:SetHintTriggers(OnEnter, OnLeave, OnShow, OnHide)
	self:SetAttribute('hintOnEnter', OnEnter)
	self:SetAttribute('hintOnLeave', OnLeave)
	self:SetAttribute('hintOnShow',  OnShow)
	self:SetAttribute('hintOnHide',  OnHide)
end