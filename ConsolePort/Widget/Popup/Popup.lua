local _, db = ...;
---------------------------------------------------------------
CPPopupFrameBaseMixin = CreateFromMixins(CPFrameMixin, CPIndexPoolMixin)
---------------------------------------------------------------
function CPPopupFrameBaseMixin:OnLoad()
	CPFrameMixin.OnLoad(self)
	CPIndexPoolMixin.OnLoad(self);
end

---------------------------------------------------------------
CPPopupFrameMixin = CreateFromMixins(CPPopupFrameBaseMixin)
---------------------------------------------------------------
function CPPopupFrameMixin:OnLoad()
	CPPopupFrameBaseMixin.OnLoad(self)
	db:RegisterCallback('OnPopupShown', self.OnPopupShown, self)
	CPAPI.Next(ConsolePort.AddInterfaceCursorFrame, ConsolePort, self)
end

function CPPopupFrameMixin:OnPopupShown(shown, frame)
	if ( frame == self or not shown or self.nonExclusive ) then return end;
	self:Hide()
end

function CPPopupFrameMixin:OnShow()
	db:TriggerEvent('OnPopupShown', true, self)
end

function CPPopupFrameMixin:OnHide()
	self:ReturnCursor()
	db:TriggerEvent('OnPopupShown', false, self)
end

function CPPopupFrameMixin:FixHeight()
	local lastItem = self:GetObjectByIndex(self:GetNumActive())
	if lastItem then
		local height = self:GetHeight() or 0;
		local bottom = self:GetBottom() or 0;
		local anchor = lastItem:GetBottom() or 0;
		self:SetTargetHeight(height + bottom - anchor + self.bottomPadding)
	end
end

function CPPopupFrameMixin:RedirectCursor()
	self.returnToNode = self.returnToNode or ConsolePort:GetCursorNode()
	ConsolePort:SetCursorNode(self:GetObjectByIndex(1))
end

function CPPopupFrameMixin:ReturnCursor()
	if self.returnToNode then
		ConsolePort:SetCursorNode(self.returnToNode)
		self.returnToNode = nil;
	end
end

function CPPopupFrameMixin:SetTargetHeight(height)
	if ( self:GetHeight() == height ) then
		return self:SetScript('OnUpdate', nil)
	end
	self.targetHeight, self.adjustTimer = height, 0;
	self:SetScript('OnUpdate', function(self, elapsed)
		self.adjustTimer = self.adjustTimer + elapsed;
		if self.adjustTimer > 0.01 then
			self.adjustTimer = 0;
			local currentHeight = self:GetHeight();
			local targetHeight = self.targetHeight;
			local diff = targetHeight - currentHeight;
			local step = diff / 3;
			if abs(step) < 1 then
				self:SetHeight(targetHeight)
				self:SetScript('OnUpdate', nil)
			else
				self:SetHeight(currentHeight + step)
			end
		end
	end)
end

---------------------------------------------------------------
CPPopupPortraitFrameMixin = CreateFromMixins(CPPopupFrameMixin)
---------------------------------------------------------------

function CPPopupPortraitFrameMixin:OnLoad()
	CPPopupFrameMixin.OnLoad(self)
	self.Name:SetPoint('TOPLEFT', self.nameOffsetX, self.nameOffsetY or -12)
end

---------------------------------------------------------------
CPPopupPortraitMixin = {};
---------------------------------------------------------------

function CPPopupPortraitMixin:OnShow()
	self.Border.Anim:Restart(false, 0.5)
	self.BorderSheen.Anim:Restart(false, 0.5)
	self.BorderBling.Anim:Restart(false, 0.5)
end

function CPPopupPortraitMixin:Play(reverse)
	self.Border.Anim:Restart(reverse)
	self.BorderSheen.Anim:Restart(reverse)
	self.BorderBling.Anim:Restart(reverse)
end

---------------------------------------------------------------
CPPopupBindingCatchButtonMixin = CreateFromMixins(CPButtonCatcherMixin)
---------------------------------------------------------------
local TIME_UNTIL_CANCEL = 5;

CPPopupBindingCatchButtonMixin.Template = (CPAPI.IsRetailVersion
	and 'SharedButtonLargeTemplate'
	or  'UIPanelButtonTemplate')
	..  ',CPPopupBindingCatchButtonTemplate';

function CPPopupBindingCatchButtonMixin:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	self.timeUntilCancel = TIME_UNTIL_CANCEL;
	self:SetSize(260, 50)
end

function CPPopupBindingCatchButtonMixin:OnShow()
	self:CatchAll(self.CatchClosure, self)
	self:ToggleInputs(true)
end

function CPPopupBindingCatchButtonMixin:OnHide()
	self.timeUntilCancel = TIME_UNTIL_CANCEL;
	self:ToggleInputs(false)
end

function CPPopupBindingCatchButtonMixin:OnUpdate(elapsed)
	self.timeUntilCancel = self.timeUntilCancel - elapsed;
	self:SetText(('%s (%d)'):format(CANCEL, ceil(self.timeUntilCancel)))
	if self.timeUntilCancel <= 0 then
		self.timeUntilCancel = TIME_UNTIL_CANCEL;
		self:GetParent():Hide()
	end
end

function CPPopupBindingCatchButtonMixin:OnClick()
	self:GetParent():Hide()
end

function CPPopupBindingCatchButtonMixin:CatchClosure(button)
	if self:OnBindingCaught(button, self:GetParent().data) then
		self:GetParent():Hide()
	end
end

function CPPopupBindingCatchButtonMixin:TryCatchBinding(popupInfo, t1, t2, d)
	self:Show()
	CPAPI.Popup('ConsolePort_Popup_Change_Binding', popupInfo, t1, t2, d, self)
end

function CPPopupBindingCatchButtonMixin:OnBindingCaught(button, data)
	-- override, return true to close the popup
end