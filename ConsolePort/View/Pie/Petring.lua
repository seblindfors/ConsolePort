local Petring, Petbutton, _, db = CPAPI.EventHandler(ConsolePortPetRing, {
	'PET_BAR_UPDATE';
	'PET_BAR_UPDATE_COOLDOWN';
}), CreateFromMixins(CPActionButton), ...;
local ActionButton = LibStub('ConsolePortActionButton')

function Petring:UpdateButtons()
	self:ReleaseAll()
	self:SetDynamicRadius(NUM_PET_ACTION_SLOTS)
	for i=1, NUM_PET_ACTION_SLOTS do
		local button, newObj = self:Acquire(i)
		local p, x, y = self:GetPointForIndex(i, NUM_PET_ACTION_SLOTS)
		if newObj then
			button:SetID(i)
			button:RegisterForDrag('LeftButton')
			button:OnLoad()
			button:SetSize(64, 64)
		end
		button:SetRotation(self:GetRotation(x, y))
		button:SetState('', 'custom', {func = nop})
		button:SetPoint(p, x, self.axisInversion * y)
		button:Show()
		self:SetFrameRef(tostring(i), button)
	end
	self:Execute(([[
		local numButtons = %d;
		self:SetAttribute('state', '')
		self:ChildUpdate('state', '')
		for i=1, numButtons do
			local button = self:GetFrameRef(tostring(i))
			button:SetAttribute('type', 'pet')
			button:SetAttribute('action', i)
		end
	]]):format(NUM_PET_ACTION_SLOTS))
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

	self:CreateObjectPool(ActionButton:NewPool({
		name   = self:GetName()..'Button';
		type   = 'Pet';
		header = self;
		mixin  = Petbutton;
	}))
	self:UpdateButtons()
	self:SetAttribute('size', NUM_PET_ACTION_SLOTS)
end

function Petring:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
	if self.ObjectPool then
		self:UpdateButtons()
	end
end

function Petring:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

function Petring:OnInput(x, y, len)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, NUM_PET_ACTION_SLOTS))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, self:IsValidThreshold(len))
end

db:RegisterSafeCallback('Settings/radialCosineDelta', Petring.OnAxisInversionChanged, Petring)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Petring.OnPrimaryStickChanged, Petring)

Petring:SetAttribute(CPAPI.ActionPressAndHold, true)
Petring:WrapScript(Petring, 'PreClick', (([[
	self:SetAttribute('TYPE', nil)
	if down then

		self:Show()
	else
		local index = self:Run(GetIndex)
		if index then
			local button = self:GetFrameRef(tostring(index))
			if button then
				self:SetAttribute('TYPE', button:GetAttribute('type'))
				self:SetAttribute('action', button:GetAttribute('action'))
			end
		end
		self:Hide()
	end
]]):gsub('TYPE', CPAPI.ActionTypeRelease)))

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Petring:PET_BAR_UPDATE()
	for button in self:EnumerateActive() do
		button:UpdateAction(true)
	end
end

function Petring:PET_BAR_UPDATE_COOLDOWN()
	for button in self:EnumerateActive() do
		button:UpdateAlpha()
	end
end

---------------------------------------------------------------
-- Petbutton mixin
---------------------------------------------------------------
function Petbutton:OnLoad()
	self:SetPreventSkinning(true)
	self:Initialize()
	self:HookScript('OnHide', self.OnClear)
	self:GetCheckedTexture():SetVertexColor(1, 0.84, 0, 1)
end

function Petbutton:OnFocus()
	self:LockHighlight(true)
	if not GameTooltip:IsOwned(self) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		self:SetTooltip()
		GameTooltip:Show()
	end
	self:GetParent():SetActiveSliceText(self.Name:GetText())
end

function Petbutton:OnClear()
	self:UnlockHighlight(false)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:GetParent():SetActiveSliceText(nil)
end

function Petbutton:UpdateLocal()
	ActionButton.CustomTypes.Pet.UpdateLocal(self)
	ActionButton.Skin.RingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self.Name:GetText())
	end)
end