CPPopupBindingCatchButtonMixin = CreateFromMixins(CPButtonCatcherMixin)
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