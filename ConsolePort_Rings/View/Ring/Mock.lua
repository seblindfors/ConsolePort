local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local TypeMetaMap = env.ActionButton:GetTypeMetaMap()
---------------------------------------------------------------
local MockButton = CreateFromMixins(env.DisplayButton)
---------------------------------------------------------------

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
	env.ActionButton.Skin.UtilityRingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self:GetActiveText())
	end)
end

function MockButton:OnLoad()
	env.DisplayButton.OnLoad(self)
	self:SetSize(64, 64)
	self:SetAttribute('state', 0)
	self.GetHotkey     = nop;
	self.state_types   = {};
	self.state_actions = {};
end

---------------------------------------------------------------
local MockRing = CreateFromMixins(db.Radial.CalcMixin)
---------------------------------------------------------------
function MockRing:OnLoad()
	self:CreateFramePool('ActionButtonTemplate', MockButton)
	self.ActiveSlice:Hide()
end

function MockRing:OnHide()
	self:ReleaseAll()
end

function MockRing:Mock(data)
	if not data then return end;
	self:ReleaseAll()
	for idx, action in ipairs(data) do
		local button, newObj = self:TryAcquireRegistered(idx)
		if newObj then
			button:SetFrameLevel(self:GetFrameLevel() + idx + 1)
			button:SetID(idx)
			button:OnLoad()
		end
		button:SetPoint('CENTER', db.Radial:GetPointForIndex(idx, #data, self:GetWidth() / 2))
		button:SetData(action)
		button:Show()
	end
	self:UpdatePieSlices(true)
	return true;
end

function env:CreateMockRing(name, parent)
	local ring = CreateFrame('PieMenu', name, parent, 'ConsolePortSlicedPie')
	FrameUtil.SpecializeFrameWithMixins(ring, MockRing)
	return ring;
end