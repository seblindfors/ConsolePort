local env, db, L = CPAPI.GetEnv(...); L = env.L;
---------------------------------------------------------------
local TutorialSetting = { OnChecked = nop };
---------------------------------------------------------------

function TutorialSetting:PostMount()
	self.BaseUpdateTooltip = self.UpdateTooltip;
	self.UpdateTooltip = self.UpdateTooltipAndBackground;
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:SetWidth(self:GetParent():GetWidth())
	self.Text:SetPoint('LEFT', 8, 0)
	if self.Input then
		self.Input:SetWidth(min(self.Input:GetWidth(), self:GetWidth() * 0.4))
	end

	local normalTexture = self:GetNormalTexture()
	normalTexture:SetPoint('TOPLEFT', -8, 0)
	normalTexture:SetPoint('BOTTOMRIGHT', 8, 0)
	local hiliteTexture = self:GetHighlightTexture()
	hiliteTexture:SetPoint('TOPLEFT', -8, 0)
	hiliteTexture:SetPoint('BOTTOMRIGHT', 8, 0)
end

function TutorialSetting:SetData(varID, data)
	self:Mount({
		name     = data.name;
		varID    = varID;
		field    = data;
		newObj   = true;
		owner    = env.Config;
		registry = db;
	})
	self:PostMount()
end

function TutorialSetting:UpdateTooltipAndBackground(...)
	self.BaseUpdateTooltip(self, ...)
	if GameTooltip:IsOwned(self) then
		NineSliceUtil.ApplyLayoutByName(
			GameTooltip.NineSlice,
			'CharacterCreateDropdown',
			GameTooltip.NineSlice:GetFrameLayoutTextureKit()
		);
		GameTooltip:SetHeight(GameTooltip:GetHeight() + 20)
	end
end

---------------------------------------------------------------
local Display = {}; env.SharedConfig.Display = Display;
---------------------------------------------------------------

function Display:OnLoad()
	CPAPI.Specialize(self, env.SharedConfig.Env.Mixin.Background)
	self:SetBackgroundInsets(4, -4, 4, 4)
	self:AddBackgroundMaskTexture(self.BorderArt.BgMask)
	self:SetBackgroundAlpha(0.25)

	self.Ring = env:CreateMockRing('$parentRing', self.RingContainer, env.SharedConfig.Ring)
	CPAPI.SpecializeOnce(self.Details, env.SharedConfig.Details)

	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
end

function Display:OnTabSelected(tabIndex, panels)
	-- The options panel is in need of slightly more visual clarity
	self:SetBackgroundAlpha(tabIndex == panels.Options and 0.1 or 0.25)
	self.isRingsPanelActive = tabIndex == panels.Rings;
	self:UpdateTutorial()
end

function Display:OnSelectSet(_, setID, isSelected)
	self.isNoSetSelected = not isSelected;
	self:UpdateTutorial()
end

function Display:UpdateTutorial()
	local shouldAnimate = self.isRingsPanelActive and self.isNoSetSelected;
	if shouldAnimate then
		if self.CreateTutorials then
			self:CreateTutorials()
		end
		self.Animations:Cancel()
		self.Animations:Play()
	elseif self.Animations then
		self.Animations:Cancel()
		self:RestoreState()
	end
	self.Tutorial:SetShown(shouldAnimate)
	self.RingBlocker:SetShown(shouldAnimate)
end

function Display:RestoreState()
	self.Ring:SetAlpha(1)
	self.Ring:SetPoint('CENTER', 0, 0)
	self.Ring:OnInput(0, 0, 0)
	self.Ring.ActiveSlice:Hide()
end

---------------------------------------------------------------
-- Tutorial
---------------------------------------------------------------
function Display:CreateTutorials()
	local function CreateHeader()
		return CreateFrame('Frame', nil, self.Tutorial, 'CPPopupHeaderTemplate')
	end

	local function CreateText()
		local text = self.Tutorial:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed1')
		text:SetJustifyH('LEFT')
		text:SetTextColor(WHITE_FONT_COLOR:GetRGBA())
		return text;
	end

	-- Create tutorial texts
	local texts, layoutIndex = {
		{ text = DESCRIPTION, element = CreateHeader() },
		{ text = L.RING_MENU_DESC, element = CreateText() },
		{ text = OPTIONS, element = CreateHeader() };
	}, CreateCounter();

	for _, setup in ipairs(texts) do
		local element = setup.element;
		local string = element.Text or element;
		element:SetWidth(self.Tutorial:GetWidth())
		element.layoutIndex = layoutIndex();
		string:SetText(setup.text)
	end

	-- Create basic variables
	for varID, data in env.table.spairs(env.Variables, function(fields, a, b)
		local iA, iB = fields[a].sort, fields[b].sort;
		return iA < iB;
	end) do
		local widget = CreateFrame('CheckButton', nil, self.Tutorial, 'CPPopupButtonBaseTemplate')
		Mixin(widget, env.SharedConfig.Env.Setting, TutorialSetting)
		widget.layoutIndex = layoutIndex();
		widget:SetData(varID, data)
		widget:Show()
	end
	self.Tutorial:Layout()

	-- Create animations
	local animations = CPAPI.CreateAnimationQueue()

	local CubicFadeIn = animations:CreateAnimation(1, 'SetAlpha',
		animations.Fraction, EasingUtil.InOutCubic)

	local SetupRingAndMockData = animations:CreateCallback(1, 0, function(self, data)
		self:Show()
		self:Mock(data)
	end, { -- Create some mock ring data for demonstration purposes
		-- AB 1/2 are always visible because they are most likely to have some stuff on them.
		-- AB 3/4 are mostly out of view, but still visible during the animation. Auto-attack
		-- and Hearthstone should hopefully be available, and these are the primary focus.
		env.SecureHandlerMap.action(2),     -- Action Button 2 (top action)
		env.SecureHandlerMap.action(4),     -- Action Button 4 (mostly out of view)
		env.SecureHandlerMap.action(3),     -- Action Button 3 (mostly out of view)
		env.SecureHandlerMap.action(1),     -- Action Button 1 (bottom action)
		env.SecureHandlerMap.spellID(6603), -- Auto Attack
		env.SecureHandlerMap.item(6948),    -- Hearthstone
	})

	local MoveRingToTheRight = animations:CreateAnimation(1, function(self, fraction)
		self:Show()
		self:SetPoint('CENTER', 280 * fraction, 0)
	end, animations.Fraction, EasingUtil.InOutCubic)

	local PointAtFifthSlice = animations:CreateAnimation(1, function(self, x, y, len)
		local isValid = len > 0.5;
		self.ActiveSlice:SetShown(true)
		self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
		self:Reflect(x, y, len, isValid)
	end, function(_, elapsed)
		local eased = EasingUtil.InOutCubic(elapsed)
		local angle = 2 * math.pi  + (math.pi * 0.85)
		return math.cos(angle), math.sin(angle), eased;
	end)

	local RotateSelectionOneLap = animations:CreateAnimation(1, function(self, x, y)
		local len, isValid = 1, true;
		self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
		self:Reflect(x, y, len, isValid)
	end, function(_, fraction)
		local angle = 2 * math.pi * EasingUtil.InOutCubic(fraction) + (math.pi * 0.85)
		return math.cos(angle), math.sin(angle);
	end)

	animations:AddAnimations(
		{self.Tutorial, CubicFadeIn},
		{self.Ring, CubicFadeIn},
		{self.Ring, SetupRingAndMockData},
		{self.Ring, MoveRingToTheRight}
	);
	animations:AddAnimation(self.Ring, PointAtFifthSlice)
	animations:AddAnimation(self.Ring, RotateSelectionOneLap)

	self.Animations = animations;
	self.CreateTutorials = nil;
end