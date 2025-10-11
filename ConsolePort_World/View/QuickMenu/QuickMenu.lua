local env, db = CPAPI.GetEnv(...);
local QMenu = env:Register('QMenu', Mixin(CPAPI.EventHandler(ConsolePortQuickMenu), CPAPI.SecureEnvironmentMixin));

---------------------------------------------------------------
local QMenuRow = env:Register('QMenuRow', {})
---------------------------------------------------------------
CPAPI.Props(QMenuRow)
	.Prop('Mixin') -- Mixin to apply to buttons
	.Prop('Title') -- Display title
	.Prop('Items') -- List of items to display (data provider)
	.Prop('Pool')  -- Button pool to acquire buttons from

function QMenuRow:LayoutItems()
	local point       = self:GetAttribute('point') or 'TOPLEFT';
	local xOffset     = tonumber(self:GetAttribute('xOffset')) or 0;
	local yOffset     = tonumber(self:GetAttribute('yOffset')) or 0;
	local wrapXOffset = tonumber(self:GetAttribute('wrapXOffset')) or 0;
	local wrapYOffset = tonumber(self:GetAttribute('wrapYOffset')) or 0;
	local minWidth    = tonumber(self:GetAttribute('minWidth')) or 0;
	local minHeight   = tonumber(self:GetAttribute('minHeight')) or 0;
	local wrapAfter   = tonumber(self:GetAttribute('wrapAfter')) or 10;

	local btns = {};
	local pool = self:GetPool();
	local code = self:GetMixin();
	for i, item in ipairs(self:GetItems()) do
		local button, newObj = pool:Acquire();
		if newObj then
			CPAPI.Specialize(button, code)
		end
		button:SetParent(self)
		button:ClearAllPoints()
		button:SetData(item)
		button:Show()
		btns[i] = button;
		-- Anchor logic
		if i == 1 then
			-- First button anchors directly to the header
			button:SetPoint(point, self, point, 0, 0)
		else
			local needsWrap = ((i - 1) % wrapAfter == 0);
			if needsWrap then
				local prevWrapButton = btns[i - wrapAfter];
				-- Start of a new row anchored relative to the button one wrap back (same column reference)
				button:SetPoint(point, prevWrapButton, point, wrapXOffset, wrapYOffset)
			else
				-- Continue current row horizontally
				button:SetPoint(point, btns[i - 1], point, xOffset, -yOffset)
			end
		end
	end

	-- Compute bounding box similar to configureAuras
	local left, right, top, bottom = math.huge, -math.huge, -math.huge, math.huge;
	for i = 1, #btns do
		local b = btns[i];
		left   = math.min(left,   b:GetLeft()   or left)
		right  = math.max(right,  b:GetRight()  or right)
		top    = math.max(top,    b:GetTop()    or top)
		bottom = math.min(bottom, b:GetBottom() or bottom)
	end

	if #btns > 0 and left < math.huge and right > -math.huge then
		self:SetWidth(math.max(right - left, minWidth))
		self:SetHeight(math.max(top - bottom, minHeight))
	else
		self:SetWidth(minWidth)
		self:SetHeight(minHeight)
	end
end

---------------------------------------------------------------
db.Secure:RegisterUser(QMenu) -- Secure
---------------------------------------------------------------
QMenu:SetAttribute(CPAPI.ActionUseOnKeyDown, true)
QMenu:SetAttribute(CPAPI.SkipHotkeyRender, true)
QMenu:Run([[
	FRAMES, FCOUNT = {}, 0;
	AURAS, AHEIGHT = {}, 0;
]])

QMenu:CreateEnvironment({
	UpdateLayout = [[
		local padding, height, isFirst, frame, prev, skipCalc = self:GetAttribute('padding'), 0, true;
		for i = 1, FCOUNT do
			frame = FRAMES[i];
			if frame and frame:IsShown() then
				self:::DecorateFrame(i);
				frame:ClearAllPoints();

				local framePadding = prev and prev:GetAttribute('paddingBottom') or padding;
				if isFirst then
					isFirst = false;
					frame:SetPoint('TOPLEFT', self, 'TOPRIGHT', 0, -framePadding)
				else
					frame:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -framePadding)
				end
				height = height + framePadding + (frame:GetAttribute('skipHeightCalc') and 0 or frame:GetHeight());
				prev = frame;
			end
		end
		self:SetHeight(height + AHEIGHT + padding * 0.5)
	]];
	OnAurasChanged = [[
		local filter, delta = ...;
		AURAS[filter] = math.max(0, AURAS[filter] + delta);

		AHEIGHT = 0;
		local padding, spacing, numRows = self:GetAttribute('padding'), 4;
		local wrapAfter, wrapYOffset = self:GetAttribute('wrapAfter'), self:GetAttribute('wrapYOffset') - spacing;
		for f, count in pairs(AURAS) do
			if count > 0 then
				numRows = math.max(1, math.ceil(count / wrapAfter));
				AHEIGHT = AHEIGHT + (numRows * math.abs(wrapYOffset)) + (numRows - 1) * spacing;
			end
		end
		self::UpdateLayout();
	]];
	Enable = [[
		self:Show()

		-- Cancel bindings
		self:SetBindingClick(true, self:GetAttribute('cancelButton'), self, 'LeftButton')
		for _, key in ipairs({ GetBindingKey('TOGGLEGAMEMENU') }) do
			self:SetBindingClick(true, key, self, 'LeftButton')
		end

		-- Force layout update
		self::UpdateLayout()
	]];
	Disable = [[
		self:Hide()
		self:ClearBindings()
	]];
})

QMenu:Wrap('PreClick', ([[
	local genericClick = button == 'LeftButton';

	if self:IsShown() then
		self::Disable()
	else
		self::Enable()
	end
]]):format(CPAPI.ActionTypePress))

---------------------------------------------------------------
-- Handlers
---------------------------------------------------------------
function QMenu:AddFrame(frame, layoutIndex)
	frame:SetAttribute('layoutIndex', layoutIndex);
	self:SetAttribute(layoutIndex, frame);
	self:SetFrameRef(tostring(layoutIndex), frame);

	frame.titleText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	frame.titleText:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 4);
	frame.titleText:SetJustifyH('LEFT');

	self:Run([[
		local index = %d;
		local frame = self:GetFrameRef(tostring(index));
		FRAMES[index] = frame;
		FCOUNT = math.max(FCOUNT, index);

		-- Initialize aura tracking frames
		if ( frame:GetAttribute('template') == 'CPQMenuAura' ) then
			self:SetAttribute('wrapAfter', frame:GetAttribute('wrapAfter'));
			self:SetAttribute('wrapYOffset', frame:GetAttribute('wrapYOffset'));
			AURAS[frame:GetAttribute('filter')] = 0;
		end

		if self:IsVisible() then
			self::UpdateLayout()
		end
	]], layoutIndex)
end

function QMenu:DecorateFrame(index)
	local frame = self:GetAttribute(index);
	if not frame then return end;
	frame.titleText:SetText(frame:GetTitle());
end

function QMenu:OnDataLoaded()
	env:TriggerEvent('QMenu.Loaded', self);
	self:SetAttribute('cancelButton', 'PAD3');
	self:Run([[ self::UpdateLayout() ]])

	CPAPI.Specialize(self.Slug, CPSlugMixin)
	self.Slug:SetBinding(db.Bindings.Custom.QuickMenu)

	self:HookScript('OnShow', env:Signal('QMenu.Show', true));
	self:HookScript('OnHide', env:Signal('QMenu.Show', false));
	return CPAPI.BurnAfterReading;
end