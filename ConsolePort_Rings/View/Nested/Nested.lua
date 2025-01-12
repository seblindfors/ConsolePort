local env, db, Container = CPAPI.GetEnv(...); Container = env.Frame;
---------------------------------------------------------------
local TypeMetaMap = env.ActionButton:GetTypeMetaMap()
---------------------------------------------------------------
local Button = CreateFromMixins(env.DisplayButton, {
---------------------------------------------------------------
	GetHotkey = nop;
	config = {
		showGrid = true;
		hideElements = {
			macro = true;
		};
	};
})

function Button:SetData(data)
	-- Coerce LAB into displaying the information we want
	local kind, action = Container:GetKindAndAction(data)
	setmetatable(self, TypeMetaMap[kind] or TypeMetaMap.empty)
	local state = tostring(0)
	self:SetStateFromHandlerInsecure(state, kind, action)
	self._state_type   = self.state_types[state];
	self._state_action = self.state_actions[state];
	self:UpdateConfig(self.config)
	self:ButtonContentsChanged(state, self._state_type, self._state_action)
	env.ActionButton.Skin.UtilityRingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self:GetActiveText())
	end)
end

function Button:OnLoad()
	env.DisplayButton.OnLoad(self)
	self:SetSize(64, 64)
	self:SetAttribute('state', 0)
	self.state_types   = {};
	self.state_actions = {};
end

---------------------------------------------------------------
local Ring = CreateFromMixins(db.Radial.CalcMixin, {
---------------------------------------------------------------
	relScale = 1 / .75;
	offScale = .75;
})

local function HideContainer(enabled, instant)
	db.Alpha.FadeOut(Container, instant and 0 or 0.1, Container:GetAlpha(), enabled and 0 or 1)
	Container.ActiveSlice:SetIgnoreParentAlpha(enabled)
	Container.Arrow:SetIgnoreParentAlpha(enabled)
end

function Ring:OnLoad()
	self:CreateFramePool('ActionButtonTemplate', Button)
	self:SetFrameLevel(100)
	self:SetIgnoreParentAlpha(true)
	self.ActiveSlice:Hide() -- TODO: maybe allow multi-stick selection?
	env:RegisterCallback('OnSelectionChanged', self.OnSelectionChanged, self)
end

function Ring:OnHide()
	self:SetScript('OnUpdate', nil)
	self:ReleaseAll()
	self:ClearAllPoints()
	self:ClearOwner()
	HideContainer(false)
end

function Ring:OnShow()
	self:SetScale(self.offScale)
	self:SetSliceTextSize(self.relScale * Container:GetSliceTextSize())
	HideContainer(true)
end

function Ring:OnSelectionChanged(reportData)
    if not self:IsShown() or not reportData.ring then return end;
	local _, _, _, x, y = self:GetPoint()
	self.curScale, self.tarScale = self:GetScale(), Container:GetScale()
	self.curSize, self.tarSize = self:GetSliceTextSize(), Container:GetSliceTextSize()
	self.tarX, self.tarY = 0, 0;
	self.curX, self.curY = x, y;
	self.duration, self.elapsed = 0.1, 0;
	Container:SetSliceTextAlpha(1)
	self:SetScript('OnUpdate', self.OnRingTransition)
end

function Ring:OnRingTransition(elapsed)
	self.elapsed = self.elapsed + elapsed;
	local progress = self.elapsed / self.duration;
	local scale = Lerp(self.curScale, self.tarScale, progress)
	local x = Lerp(self.curX, self.tarX, progress)
	local y = Lerp(self.curY, self.tarY, progress)
	local size = Lerp(self.curSize, self.tarSize, progress)
	self:SetScale(scale)
	self:ClearAllPoints()
	self:SetPoint('CENTER', Container, 'CENTER', x, y)
	self:SetSliceTextSize(size)
	if progress >= 1 then
		self:Hide()
		HideContainer(false, true)
	end
end

function Ring:SetOwner(owner)
	local pX, pY = Container:GetCenter()
	local oX, oY = owner:GetCenter()
	owner:SetIgnoreParentAlpha(true)
	db.Alpha.FadeIn(self, 0.1, 0, 1)

	self:ClearAllPoints()
	self:SetPoint('CENTER', Container, 'CENTER',
		(oX - pX) * self.relScale,
		(oY - pY) * self.relScale
	);
	self:Show()
	self.owner = owner;
	self.ticker = C_Timer.NewTicker(0, function()
		if self:GetScript('OnUpdate') then return end; -- in transition
		if ( not self.owner or Container:GetFocusWidget() ~= self.owner ) then
			self:Hide()
		end
	end)
end

function Ring:ClearOwner()
	if self.owner then
		self.owner:SetIgnoreParentAlpha(false)
		self.owner = nil;
	end
	if self.ticker then
		self.ticker:Cancel()
		self.ticker = nil;
	end
end

function Ring:SetData(owner, data)
	if not data then return self:Hide() end;
	local size = self:GetParent():GetSize();
	self:SetSize(size, size)
	for idx, action in ipairs(data) do
		local button, newObj = self:TryAcquireRegistered(idx)
		if newObj then
			button:SetFrameLevel(idx + 101)
			button:SetID(idx)
			button:OnLoad()
		end
		button:SetPoint('CENTER', db.Radial:GetPointForIndex(idx, #data, self:GetWidth() / 2))
		button:SetData(action)
		button:Show()
	end
	self:SetOwner(owner)
end

---------------------------------------------------------------
-- Observer
---------------------------------------------------------------
env:RegisterCallback('OnButtonFocus', function(_, button, focused)
	if button:IsOwned(env.NestedRing) then return end;
	if focused then
		if not button:IsCustomType() then return end;
		local data = button:RunCustom()
		if ( data.type ~= env.Attributes.NestedRing ) then return end;

		if not env.NestedRing then
			env.NestedRing = CreateFrame('PieMenu', '$parentNested', env.Frame, 'ConsolePortSlicedPie')
			FrameUtil.SpecializeFrameWithMixins(env.NestedRing, Ring)
		end
		env.NestedRing:SetData(button, Container.Data[Container:GetSetForBindingSuffix(data.ring)]);
	end
end)