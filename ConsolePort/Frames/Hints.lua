local addOn, db = ...
db.Hint = ConsolePortHintFrame

local Hint = ConsolePortHintFrame
local STATUS_FADETIME = 3.0
local queue = {}

function Hint:DisplayMessage(text, time, yOffset)
	if db.Settings.disableHints then return end
	if not self.isDisplaying then
		self.isDisplaying = true
		self.startTime = GetTime()
		self.fadeTime = type(time) == "number" and time or STATUS_FADETIME
		self:SetAlpha(1.0)
		self.Text:SetText(text)
		self.Text:SetPoint("CENTER", 0, yOffset or 0)
		self:Show()
		self:SetScript("OnUpdate", self.ShowHint)
	else
		queue[#queue + 1] = {text = text, time = time, yOffset = yOffset}
	end
end

function Hint:Disable()
	self:Hide()
	self:SetScript('OnUpdate', nil)
	self.fadeTime = nil
end

function Hint:ShowHint(elapsed)
	elapsed = GetTime() - self.startTime
	local time = self.fadeTime
	if ( elapsed < time ) then
		local alpha = 1.0 - (elapsed / time)^2
		self:SetAlpha(alpha)
		return
	end
	self.isDisplaying = nil
	if next(queue) then
		local index, hint = next(queue)
		local text, time, yOffset = hint.text, hint.time, hint.yOffset
		queue[index] = nil
		self:DisplayMessage(text, time, yOffset)
		return
	end
	self:Disable()
end