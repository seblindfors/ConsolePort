local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local TypeMetaMap = env.ActionButton:GetTypeMetaMap()
---------------------------------------------------------------
local MockButton = {}; env.MockButton = MockButton;
---------------------------------------------------------------
function MockButton:OnLoad()
	self:SetAttribute('state', 0)
	self.GetHotkey     = nop;
	self.state_types   = {};
	self.state_actions = {};
end

function MockButton:SetData(data)
	-- Coerce LAB into displaying the information we want
	local kind, action = env:GetKindAndAction(data)
	setmetatable(self, TypeMetaMap[kind] or TypeMetaMap.empty)
	local state = tostring(0)
	self:SetStateFromHandlerInsecure(state, kind, action)
	self._state_type   = self.state_types[state];
	self._state_action = self.state_actions[state];
	self:UpdateConfig(env.LABConfig)
	self:ButtonContentsChanged(state, self._state_type, self._state_action)
end

---------------------------------------------------------------
local MockRingButton = CreateFromMixins(env.DisplayButton, MockButton)
---------------------------------------------------------------
function MockRingButton:SetData(data)
	MockButton.SetData(self, data)
	self:UpdateText()
end

function MockRingButton:OnLoad()
	env.DisplayButton.OnLoad(self)
	MockButton.OnLoad(self)
	self:SetSize(64, 64)
	self.disableHints = true;
end

function MockRingButton:UpdateText()
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self:GetActiveText())
	end)
end

---------------------------------------------------------------
local MockRing = Mixin({
---------------------------------------------------------------
	buttonTemplate = 'ActionButtonTemplate';
	buttonMixin    = MockRingButton;
}, db.Radial.CalcMixin)

function MockRing:OnLoad()
	self:CreateFramePool(self.buttonTemplate, self.buttonMixin)
	self.ActiveSlice:Hide()
	self:SetRadialSize(db('radialPreferredSize'))
	db:RegisterSafeCallback('Settings/radialPreferredSize', self.SetRadialSize, self)
end

function MockRing:OnHide()
	self:ReleaseAll()
end

function MockRing:Mock(data)
	if not data then return end;
	self:ReleaseAll()
	self.radius = self:SetDynamicRadius(#data)
	for idx, action in ipairs(data) do
		local button, newObj = self:TryAcquireRegistered(idx)
		if newObj then
			button:OnLoad()
		end
		button:SetID(idx)
		button:SetFrameLevel(self:GetFrameLevel() + idx + 1)
		button:SetPoint('CENTER', db.Radial:GetPointForIndex(idx, #data, self.radius))
		button:SetData(action)
		button:Show()
	end
	self:UpdatePieSlices(true)
	return true;
end

env.MockRingMixins = {
	MockRing       = MockRing;
	MockButton     = MockButton;
	MockRingButton = MockRingButton;
};

function env:CreateMockRing(name, parent, mixin)
	local ring = CreateFrame('PieMenu', name, parent, 'ConsolePortSlicedPie')
	CPAPI.Specialize(ring, mixin or MockRing)
	return ring;
end