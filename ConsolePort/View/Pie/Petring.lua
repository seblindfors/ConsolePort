local Petring, Petbutton, _, db = CPAPI.EventHandler(ConsolePortPetRing), CreateFromMixins(CPActionButton), ...;

function Petring:UpdateButtons()
	self:ReleaseAll()
	for i=1, NUM_PET_ACTION_SLOTS do
		local button, newObj = self:Acquire(i)
		local p, x, y = self:GetPointForIndex(i, NUM_PET_ACTION_SLOTS)
		if newObj then
			button:SetID(i)
			button:RegisterForDrag('LeftButton')
			button:OnLoad()
		end
		button:SetState('', 'pet', i)
		button:SetPoint(p, x, self.axisInversion * y)
		button:Show()
		self:SetFrameRef(tostring(i), button)
	end
	self:Execute([[
		self:SetAttribute('state', '')
		self:ChildUpdate('state', '')
	]])
end

function Petring:OnDataLoaded()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});

	self:OnAxisInversionChanged()
	self:OnPrimaryStickChanged()

	self:CreateFramePool('SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate, CPUIActionButtonTemplate', Petbutton)
	self:UpdateButtons()
	self:SetAttribute('size', NUM_PET_ACTION_SLOTS)
end

function Petring:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

function Petring:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

function Petring:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, NUM_PET_ACTION_SLOTS))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
end

db:RegisterSafeCallback('Settings/radialCosineDelta', Petring.OnAxisInversionChanged, Petring)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Petring.OnPrimaryStickChanged, Petring)

Petring:WrapScript(Petring, 'PreClick', [[
	self:SetAttribute('type', nil)
	if down then

		self:Show()
	else
		local index = self:Run(GetIndex)
		if index then
			local button = self:GetFrameRef(tostring(index))
			if button then
				self:SetAttribute('type', button:GetAttribute('type'))
				self:SetAttribute('action', button:GetAttribute('action'))
			end
		end
		self:Hide()
	end
]])
---------------------------------------------------------------
-- Petbutton mixin
---------------------------------------------------------------
function Petbutton:OnLoad(i)
	self.Shine = CreateFrame('Frame', 'ConsolePortPetRingShine'..self:GetID(), self, 'AutoCastShineTemplate')
	self.Shine:SetAllPoints()
	self:Initialize()

	self:HookScript('OnHide', self.OnClear)
	self:HookScript('OnShow', self.UpdateAssets)
	self:GetCheckedTexture():SetVertexColor(1, 0.84, 0, 1)
end

function Petbutton:UpdateAssets()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(self._state_action)
	if ( autoCastEnabled ) then
		AutoCastShine_AutoCastStart(self.Shine, CPAPI.GetClassColor())
	else
		AutoCastShine_AutoCastStop(self.Shine)
	end
end

function Petbutton:OnFocus()
	self:LockHighlight(true)
	if not GameTooltip:IsOwned(self) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		self:SetTooltip()
		GameTooltip:Show()
	end
end

function Petbutton:OnClear()
	self:UnlockHighlight(false)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end