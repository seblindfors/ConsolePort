
local env, Container = CPAPI.GetEnv(...); Container = env.Frame;
local MockRing, MockRingButton = env.MockRingMixins.MockRing, env.MockRingMixins.MockRingButton;
---------------------------------------------------------------
local RingButton = CreateFromMixins(MockRingButton)
---------------------------------------------------------------

function RingButton:OnLoad()
	MockRingButton.OnLoad(self)
	self.OnLoad = nil;
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnDragStop', self.OnDragStop)
	FrameUtil.ReflectStandardScriptHandlers(self)
end

function RingButton:SetFocusTooltip()
	if not self:IsMouseOver() then return end;
	MockRingButton.SetFocusTooltip(self)
end

function RingButton:OnEnter()
	if GetCursorInfo() then
		self.replaceIcon = self:GetParent():GetReplaceIcon(self)
		self.replaceIcon:SetPoint('BOTTOMLEFT', self, 'TOPRIGHT', -10, -10)
		self.replaceIcon:Show()
		self:SetFrameLevel(self:GetFrameLevel() + 100)
	else
	end
end

function RingButton:OnLeave()
	if self.replaceIcon then
		self.replaceIcon:Hide()
		self.replaceIcon = nil;
		self:SetFrameLevel(self:GetFrameLevel() - 100)
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
end

function RingButton:AddFromCursorInfo()
	local currentSetID, buttonID = self:GetParent():GetCurrentSetID(), self:GetID()
	if Container:AddFromCursorInfo(currentSetID, buttonID) then
		Container:RemoveAction(currentSetID, buttonID + 1)
		ClearCursor()
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
	self:SetFrameLevel(5)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)
	env:RegisterCallback('OnIndexHighlight', self.OnIndexHighlight, self)
end

function Ring:OnSelectSet(elementData, setID, isSelected)
	self:SetShown(isSelected)
	self:GetParent():SetShown(isSelected)
	self.currentSetID = isSelected and setID or nil;
	if isSelected then
		self:Mock(env:GetSet(setID))
	end
end

function Ring:OnAddNewSet(container, node, isAdding)
	self.currentSetID = nil;
end

function Ring:OnTabSelected(tabIndex, panels)
	if ( tabIndex == panels.Options ) then
		self:GetParent():Hide()
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

function Ring:GetReplaceIcon(owner)
	if not self.ReplaceIcon then
		self.ReplaceIcon = self:CreateTexture(nil, 'OVERLAY')
		self.ReplaceIcon:SetAtlas('common-icon-undo', true)
	end
	self.ReplaceIcon:ClearAllPoints()
	self.ReplaceIcon:SetParent(owner)
	return self.ReplaceIcon;
end

function Ring:GetCurrentSetID()
	return self.currentSetID;
end

function Ring:Mock(data)
	MockRing.Mock(self, data)
	self.currentData = data;
	self:SetScale(390 / self:GetWidth())
end

function Ring:GetCurrentRadius()
	return self.radius;
end

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