local _, db = ...;
---------------------------------------------------------------
CPPopupFrameBaseMixin = CreateFromMixins(CPFrameMixin, CPIndexPoolMixin)
---------------------------------------------------------------
function CPPopupFrameBaseMixin:OnLoad()
	CPFrameMixin.OnLoad(self)
	CPIndexPoolMixin.OnLoad(self);
	self.Name:SetPoint('TOPLEFT', self.nameOffsetX, -20)
end

---------------------------------------------------------------
CPPopupFrameMixin = CreateFromMixins(CPPopupFrameBaseMixin)
---------------------------------------------------------------
function CPPopupFrameMixin:OnLoad()
	CPPopupFrameBaseMixin.OnLoad(self)
	db:RegisterCallback('OnPopupShown', self.OnPopupShown, self)
	ConsolePort:AddInterfaceCursorFrame(self)
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
CPPopupBindingCatchButtonMixin = CreateFromMixins(CPButtonCatcherMixin)
---------------------------------------------------------------
local TIME_UNTIL_CANCEL = 5;

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

function CPPopupBindingCatchButtonMixin:CatchClosure(...)
	if self:OnBindingCaught(...) then
		self:GetParent():Hide()
	end
end

function CPPopupBindingCatchButtonMixin:TryCatchBinding(popupInfo)
	CPAPI.Popup('ConsolePort_Popup_Change_Binding', popupInfo, nil, nil, nil, self)
end

function CPPopupBindingCatchButtonMixin:OnBindingCaught(...)
	-- override
end