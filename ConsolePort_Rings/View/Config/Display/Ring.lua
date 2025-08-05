
local env, db, Container = CPAPI.GetEnv(...); Container = env.Frame;
local MockRing, MockRingButton = env.MockRingMixins.MockRing, env.MockRingMixins.MockRingButton;
---------------------------------------------------------------
local RingButton = CreateFromMixins(MockRingButton)
---------------------------------------------------------------
local BASE_FRAME_LEVEL = 5;

function RingButton:OnLoad()
	MockRingButton.OnLoad(self)
	self.OnLoad = nil;
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnDragStop', self.OnDragStop)
	FrameUtil.ReflectStandardScriptHandlers(self)
end

function RingButton:SetFocusTooltip()
	if self:IsMouseOver() or self:GetParent():IsManagingControls() then
		MockRingButton.SetFocusTooltip(self)
	end
end

function RingButton:OnEnter()
	if GetCursorInfo() and not self:IsReplacementTarget() then
		self:ShowReplace(true)
	else
		self:SetFocusTooltip()
	end
end

function RingButton:OnLeave()
	if self:IsReplaceShown() and not self:IsReplacementTarget() then
		self:ShowReplace(false)
	elseif GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function RingButton:IsReplaceShown()
	return self.isReplacing;
end

function RingButton:IsReplacementTarget()
	return self:GetID() == env.ReplaceID;
end

function RingButton:ShowReplace(replace)
	self.isReplacing = replace;
	if replace then
		local replaceIcon = self:GetParent():GetReplaceIcon(self)
		replaceIcon:SetPoint('BOTTOMLEFT', self, 'TOPRIGHT', -10, -10)
		replaceIcon:Show()
		self:SetFrameLevel(BASE_FRAME_LEVEL + self:GetID() + 100)
	else
		self:GetParent():ClearReplace()
		self:SetFrameLevel(BASE_FRAME_LEVEL + self:GetID() + 1)
	end
end

function RingButton:OnReceiveDrag(...)
	if self:AddFromCursorInfo() then
		return;
	end
end

function RingButton:OnClick(button)
	if ( button == 'RightButton' ) then
		local currentSetID = self:GetParent():GetCurrentSetID()
		Container:RemoveAction(currentSetID, self:GetID())
		return env:TriggerEvent('OnSetChanged', currentSetID)
	end
	if self:AddFromCursorInfo() then
		return;
	end
	self:SetChecked(false)
	self:GetParent():OnReplace(nil, self:GetID())
end

function RingButton:AddFromCursorInfo()
	local currentSetID, buttonID = self:GetParent():GetCurrentSetID(), self:GetID()
	local wasAdded = Container:AddFromCursorInfo(currentSetID, buttonID)
	ClearCursor()
	if wasAdded then
		Container:RemoveAction(currentSetID, buttonID + 1)
		env:TriggerEvent('OnSetChanged', currentSetID)
		return true;
	end
end

function RingButton:OnDragStart()
	self:SetScript('OnUpdate', self.OnUpdateDrag)
	self:GetParent():SetDragEntry(self)
end

function RingButton:OnDragStop()
	self:SetScript('OnUpdate', nil)
	self:GetParent():SetDragEntry(nil)
end

function RingButton:OnUpdateDrag()
	local x, y = self:GetParent():GetDragPosition()
	self:SetPoint('CENTER', x, y)
end

---------------------------------------------------------------
local Ring = CreateFromMixins(MockRing, {
---------------------------------------------------------------
	buttonMixin = RingButton;
}); env.SharedConfig.Ring = Ring;

function Ring:OnLoad()
	MockRing.OnLoad(self)
	self:SetPoint('CENTER', self:GetParent(), 'CENTER', 0, 0)
	self:SetFrameLevel(BASE_FRAME_LEVEL)
	self:SetAttribute('nodeignore', true)

	self.EmptyText = self:GetParent().EmptyText;
	self.EmptyText:SetText(env.L.RING_EMPTY_DESC)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)
	env:RegisterCallback('OnIndexHighlight', self.OnIndexHighlight, self)

	self:SetScript('OnGamePadStick', self.OnGamePadStick)
	self:SetPropagateKeyboardInput(false)

	local sticksToInterrupt = db.Radial:GetStickStruct('Movement')
	self.stickInterrupt = tInvert(sticksToInterrupt)
	self.stickIntercept = sticksToInterrupt[1];

	db:RegisterSafeCallback('Settings/radialCosineDelta', self.OnAxisInversionChanged, self)
	self:OnAxisInversionChanged()
end

function Ring:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

function Ring:OnSelectSet(elementData, setID, isSelected)
	self:SetShown(isSelected)
	self.EmptyText:Hide()
	self.currentSetID = isSelected and setID or nil;
	if isSelected then
		self:Mock(env:GetSet(setID))
	end
end

function Ring:OnTabSelected(tabIndex, panels)
	self:GetParent():SetShown(tabIndex ~= panels.Options)
	self:EnableGamePadStick(tabIndex == panels.Loadout)
	self:OnInput(0, 0, 0)
	if ( tabIndex == panels.Options ) then
		return self:Hide()
	elseif self.currentSetID then
		self:OnSelectSet(nil, self.currentSetID, true)
	end
end

function Ring:OnSetChanged(setID)
	if ( setID == self.currentSetID ) then
		self:Mock(env:GetSet(setID))
	end
end

function Ring:OnIndexHighlight(index)
	self:SetFocusByIndex(index)
end

function Ring:GetCurrentSetID()
	return self.currentSetID;
end

function Ring:Mock(data)
	MockRing.Mock(self, data)
	self.currentData = data;
	self:SetScale(390 / self:GetWidth())
	self.EmptyText:SetShown(not data or #data == 0)
	self:ClearManagementControls()
end

function Ring:GetCurrentRadius()
	return self.radius;
end

---------------------------------------------------------------
-- Drag and drop (mouse based controls)
---------------------------------------------------------------
function Ring:GetDragPosition()
	local fx, fy = self:GetCenter()
	local mx, my = GetCursorPosition()
	local scale = self:GetEffectiveScale()
	mx, my = mx / scale, my / scale;

	local dx, dy = mx - fx, my - fy;
	local angle  = math.atan2(dy, dx)
	local radius = self:GetCurrentRadius()
	local x, y   = radius * math.cos(angle), radius * math.sin(angle)
	return x, y;
end

function Ring:SetDragEntry(button)
	if button then
		self.dragButton, self.dragIndex = button, button:GetID();
		self.dragData = CopyTable(self.currentData)
		self.poolBtns = {};
		for other in self:EnumerateActive() do
			if ( other ~= button ) then
				tinsert(self.poolBtns, other)
			end
		end
		self:SetScript('OnUpdate', self.OnUpdateDrag)
		self:ClearManagementControls()
	elseif self.dragData then
		self.dragButton, self.dragIndex = nil, nil;
		self:SetScript('OnUpdate', nil)
		if ( #self.dragData == #self.currentData ) then
			for i, action in ipairs(self.dragData) do
				self.currentData[i] = action;
			end
			Container:RefreshAll()
		end
		self.dragData, self.poolBtns = nil, nil;
		self:Mock(self.currentData)
	end
end

local function tswap(t, a, b)
	if a == b then return end;
	t[a], t[b] = t[b], t[a];
end

function Ring:OnUpdateDrag()
	local numActive   = self:GetNumActive()
	local x, y        = self:GetDragPosition()
	local radius      = self:GetCurrentRadius()
	local targetIndex = self:GetIndexForPos(x, y, 1, numActive)

	tswap(self.dragData, self.dragIndex, targetIndex)
	self.dragIndex = targetIndex;

	local i = 1; -- iterate the other buttons and assign them a mocked pos/data
	for cacheID, button in ipairs(self.poolBtns) do
		if cacheID == targetIndex then
			i = i + 1;
		end
		button:SetID(i)
		button:SetData(self.dragData[i])
		button:SetPoint(self:GetPointForIndex(i, numActive, radius))
		i = i + 1;
	end
	self:SetSliceText(self.dragIndex, self.dragButton:GetActiveText())
end

---------------------------------------------------------------
-- Replace controls
---------------------------------------------------------------
function Ring:GetReplaceIcon(owner)
	if not self.ReplaceIcon then
		self.ReplaceIcon = self:CreateTexture(nil, 'OVERLAY')
		self.ReplaceIcon:SetAtlas('common-icon-undo', true)
	end
	self:ClearReplace()
	self.ReplaceIcon:ClearAllPoints()
	self.ReplaceIcon:SetParent(owner)
	return self.ReplaceIcon;
end

function Ring:ClearReplace()
	env.ReplaceID = nil;
	if self.ReplaceIcon then
		self.ReplaceIcon:Hide()
	end
end

function Ring:OnReplace(_, index)
	index = index or self:GetFocusIndex()
	if not env.ReplaceID then
		self:GetObjectByIndex(index):ShowReplace(true)
		env.ReplaceID = index;
	else
		local replaceID, focusID = env.ReplaceID, index;
		self:GetObjectByIndex(replaceID):ShowReplace(false)
		tswap(self.currentData, replaceID, focusID)
		Container:RefreshAll()
		env:TriggerEvent('OnSetChanged', self.currentSetID)
	end
end

---------------------------------------------------------------
-- Gamepad controls
---------------------------------------------------------------
function Ring:OnRemove()
	Container:RemoveAction(self.currentSetID, self:GetFocusIndex())
	env:TriggerEvent('OnSetChanged', self.currentSetID)
end

Ring.Controls = {
	PAD1 = { func = Ring.OnReplace, text = REPLACE };
	PAD2 = { func = Ring.OnRemove,  text = REMOVE  };
};

function Ring:OnHide()
	self:ClearManagementControls()
end

function Ring:OnGamePadStick(stick, x, y, len)
	if not self.stickInterrupt[stick] then
		return self:SetPropagateKeyboardInput(true)
	end
	if stick ~= self.stickIntercept then
		return self:SetPropagateKeyboardInput(false)
	end
	self:OnInput(x, y, len)
end

function Ring:OnInput(x, y, len)
	local isValid =  len > self:GetValidThreshold();
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
	self:Reflect(x, y, len, isValid)
	self:SetManagementControls(isValid)
end

function Ring:Reflect(x, y, len, isValid)
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, isValid)
end

function Ring:SetManagementControls(enabled)
	if self.isManaging == enabled then return end;
	self.isManaging = enabled;

	self.ActiveSlice:SetShown(enabled)
	ConsolePort:SetCursorObstructor(self, enabled)
	local handle = db.UIHandle:ToggleHintFocus(self, enabled)

	if enabled then
		for button, info in pairs(self.Controls) do
			env:TriggerEvent('OnAcquireControlButton', button, info.func, self)
			handle:AddHint(button, info.text)
		end
	else
		for button in pairs(self.Controls) do
			env:TriggerEvent('OnReleaseControlButton', button)
		end
	end
end

function Ring:ClearManagementControls()
	self.isManaging = nil;
	self:ClearReplace()
end

function Ring:IsManagingControls()
	return self.isManaging;
end