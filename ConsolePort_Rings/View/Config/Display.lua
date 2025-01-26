local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Display = {}; env.SharedConfig.Display = Display;
---------------------------------------------------------------

function Display:OnLoad()
	FrameUtil.SpecializeFrameWithMixins(self, CPBackgroundMixin)
	self:SetBackgroundInsets(4, -4, 4, 4)
	self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
	self:SetBackgroundAlpha(0.25)

	self.Ring = env:CreateMockRing('$parentRing', self.ScrollChild)
	self.Ring:SetPoint('CENTER', self, 'CENTER', 0, 0)
	self.Ring:SetSize(390, 390)
	self.Ring:SetFrameLevel(5)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)
end

function Display:OnSelectSet(elementData, setID, isSelected)
	self.Ring:SetShown(isSelected)
	self.currentSetID = isSelected and setID or nil;
	if isSelected then
		self.Ring:Mock(env:GetSet(setID))
	end
end

function Display:OnAddNewSet(container, node, isAdding)
	self.currentSetID = nil;
end

function Display:OnTabSelected(tabIndex, panels)
	if ( tabIndex == panels.Options ) then
		return self.Ring:Hide()
	elseif self.currentSetID then
		self:OnSelectSet(nil, self.currentSetID, true)
	end
end

function Display:OnSetChanged(setID)
	if ( setID == self.currentSetID ) then
		self.Ring:Mock(env:GetSet(setID))
	end
end