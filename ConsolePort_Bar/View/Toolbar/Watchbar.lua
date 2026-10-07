local _, env, db = ...; db = env.db;
local WATCHBAR_UNIT = 16;
---------------------------------------------------------------
CPWatchbar = CreateFromMixins(env.ConfigurableWidgetMixin);
---------------------------------------------------------------

function CPWatchbar:OnLoad()
	env:RegisterCallbacks(self.OnDataLoaded, self,
		'OnDataLoaded',
		'Settings/enableXPBar',
		'Settings/fadeXPBar',
		'Settings/tintEnable',
		'Settings/tintColor',
		'Settings/xpBarColor'
	);

	db:RegisterCallback('OnHintsFocus', self.OnHints, self, 0)
	db:RegisterCallback('OnHintsClear', self.OnHints, self, 1)

	self.snapToPixels = 16;
	self.TotemBar  = not CPAPI.IsModernVersion and MultiCastActionBarFrame;
	self.CastBar   = not CPAPI.IsModernVersion and CastingBarFrame;
	self.StanceBar = not CPAPI.IsModernVersion and StanceBarFrame;
end

function CPWatchbar:OnSizeChanged()
	if ( not self.XPBar ) then return end;
	self.XPBar:SetWidth(self:GetWidth() * 0.8)
	self.XPBar:UpdateBarsShown()
end

function CPWatchbar:SetTintColor(r, g, b, a)
	local orientation, minColor, maxColor = env:GetColorGradient(r, g, b, a, .25, self.inverted)
	self.BG:SetGradient(orientation, minColor, maxColor)
	self.DividerLine:SetVertexColor(r, g, b, a)
end

function CPWatchbar:OnDataLoaded()
	local enableTint, enableXP = env('tintEnable'), env('enableXPBar');
	self.BG:SetShown(enableTint)
	self.DividerLine:SetShown(enableTint)
	self:ToggleXPBar(enableXP)
	self:ToggleXPBarFade(enableXP)
	return CPAPI.KeepMeForLater;
end

function CPWatchbar:SetProps(props)
	self:OnDataLoaded()
	self:UpdateInversion(props)
	self:SetTintColor(env:GetColorRGBA('tintColor'))
	self:SetDynamicProps(props)
	self:OnSizeChanged()
	self:Show()
	self:SetTotemBarProps(props.totem)
	self:SetCastBarProps(props.castbar)
	self:SetStanceBarProps(props.totem)
end

function CPWatchbar:UpdateInversion(props)
	self.inverted = not not props.pos.point:match('^TOP');

	local delta = self.inverted and -1 or 1;
	local orientation = self.inverted and 'TOP' or 'BOTTOM';

	self.DividerLine:ClearAllPoints()
	self.DividerLine:SetPoint(orientation..'LEFT', 0, WATCHBAR_UNIT * delta)
	self.DividerLine:SetPoint(orientation..'RIGHT', 0, WATCHBAR_UNIT * delta)

	local bgOffsetTop = self.inverted and -16 or 60;
	local bgOffsetBot = self.inverted and -60 or 16;
	self.BG:SetPoint('TOPLEFT', WATCHBAR_UNIT, bgOffsetTop)
	self.BG:SetPoint('BOTTOMRIGHT', -WATCHBAR_UNIT, bgOffsetBot)

	if ( not self.XPBar ) then return end;
	self.XPBar:ClearAllPoints()
	self.XPBar:SetPoint(orientation)
	self.XPBar:SetInversion(self.inverted)
end

function CPWatchbar:OnPropsUpdated()
	self:SetProps(self.props)
end

---------------------------------------------------------------
-- Elements
---------------------------------------------------------------
function CPWatchbar:ToggleXPBar(enabled)
	if ( not self.XPBar ) then
		if not enabled then return end;
		self.XPBar = CreateFrame('Frame', nil, self, 'CPWatchBarContainer')
	end
	self.XPBar:SetShown(enabled)
	self.XPBar:SetMainBarColor(env:GetColorRGB('xpBarColor'))
end

function CPWatchbar:ToggleXPBarFade(xpBarEnabled)
	if ( not self.XPBar ) then return end;
	if not xpBarEnabled then return end;
	self.XPBar:OnShow() -- env('fadeXPBar') is handled by the XPBar itself
end

function CPWatchbar:SetTotemBarProps(props)
	if not self.TotemBar or not props.enabled then return end;
	if not self.TotemBar.SetDynamicProps then
		Mixin(self.TotemBar, env.ConfigurableWidgetMixin)
		self.TotemBar:SetScript('OnUpdate', nil)
		self.TotemBar.OnPropsUpdated = function(self) self:SetDynamicProps(self.props) end;
	end
	self.TotemBar:SetDynamicProps(props)
	self.TotemBar:SetParent(props.hidden and env.UIHandler or UIParent)
end

function CPWatchbar:SetStanceBarProps(props)
	if not self.StanceBar or not props.enabled then return end;
	if not self.StanceBarUpdate then
		local stanceButtons = self.StanceBar.StanceButtons;
		self.StanceBarUpdate = function(stanceBar)
			local numForms = GetNumShapeshiftForms()
			if ( numForms == 0 ) then return end;
			local fL, fR = math.huge, 0;
			for i = 1, numForms do
				local button = stanceButtons[i];
				local left, _, width = button:GetRect()
				fL = min(fL, left)
				fR = max(fR, left + width)
			end
			env:RunSafe(stanceBar.SetWidth, stanceBar, fR - fL + 22)
			StanceBarLeft:SetTexture(nil)
			StanceBarMiddle:SetTexture(nil)
			StanceBarRight:SetTexture(nil)
		end;
		for i = 1, NUM_STANCE_SLOTS do
			local texture = stanceButtons[i]:GetNormalTexture()
			texture:ClearAllPoints()
			texture:SetPoint('TOPLEFT', -11, 11)
			texture:SetPoint('BOTTOMRIGHT', 12, -12)
		end
		self.StanceBar:HookScript('OnEvent', self.StanceBarUpdate)
		self.StanceBarUpdate(self.StanceBar)
	end
	if self.TotemBar then
		self.StanceBar:ClearAllPoints()
		self.StanceBar:SetPoint('CENTER', self.TotemBar, 'CENTER', 0, 0)
	else -- Classic Era (probably), no totem bar so stance bar owns the positioning
		if not self.StanceBar.SetDynamicProps then
			Mixin(self.StanceBar, env.ConfigurableWidgetMixin)
			self.StanceBar.OnPropsUpdated = function(self) self:SetDynamicProps(self.props) end;
		end
		self.StanceBar:SetDynamicProps(props)
		self.StanceBarUpdate(self.StanceBar)
	end
	self.StanceBar:SetParent(props.hidden and env.UIHandler or UIParent)
end

local MoveCastingBarFrame;
function CPWatchbar:SetCastBarProps(props)
	-- Classic only, hook persists until /reload
	if not self.CastBar or not props or not props.enabled then return end;

	local inverted = self.inverted;
	local delta = inverted and -1 or 1;
	local point = inverted and 'TOP' or 'BOTTOM';

	if self.castBarAnchor then
		self.castBarAnchor[1] = point;
		self.castBarAnchor[3] = point;
		self.castBarAnchor[5] = delta;
		return MoveCastingBarFrame()
	end

	self.castBarAnchor = { point, self, point, 0, delta };
	hooksecurefunc(self.CastBar, 'SetPoint', function(bar, _, region)
		if region ~= self then
			bar:ClearAllPoints()
			bar:SetPoint(unpack(self.castBarAnchor))
		end
	end)

	local function ModifyCastingBarFrame()
		CastingBarFrame_SetLook(self.CastBar, 'UNITFRAME')
		self.CastBar.Border:SetShown(false)
		self.CastBar.Text:SetPoint('TOPLEFT', 0, 0)
		self.CastBar.Text:SetPoint('TOPRIGHT', 0, 0)
		self.CastBar.Flash:SetTexture([[Interface\QUESTFRAME\UI-QuestLogTitleHighlight]])
		self.CastBar.Flash:SetAllPoints(self.CastBar)
		self.CastBar.BorderShield:SetTexture([[Interface\CastingBar\UI-CastingBar-Arena-Shield]])
		self.CastBar.BorderShield:SetPoint('CENTER', self.CastBar.Icon, 'CENTER', 10, 0)
		self.CastBar.BorderShield:SetSize(49, 49)
		local r, g, b = env:GetColorRGB('xpBarColor')
		CastingBarFrame_SetStartCastColor(self.CastBar, r, g, b)
	end

	function MoveCastingBarFrame()
		ModifyCastingBarFrame()
		self.CastBar:ClearAllPoints()
		self.CastBar:SetPoint(unpack(self.castBarAnchor))
		self.CastBar:SetSize(self:GetWidth() - 190, 14)
	end

	env:RegisterCallback('Settings/xpBarColor', ModifyCastingBarFrame)
	MoveCastingBarFrame()

	self:HookScript('OnSizeChanged', MoveCastingBarFrame)
	self:HookScript('OnShow', MoveCastingBarFrame)
	self:HookScript('OnHide', MoveCastingBarFrame)
end

function CPWatchbar:OnHints(alpha)
	if self.TotemBar  then self.TotemBar:SetAlpha(alpha)  end;
	if self.StanceBar then self.StanceBar:SetAlpha(alpha) end;
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Watchbar', function()
	if not ConsolePortWatchbar then
		ConsolePortWatchbar = CreateFrame('Frame', 'ConsolePortWatchbar', env.Manager, 'CPWatchbar')
	end
	return ConsolePortWatchbar;
end, env.Interface.Watchbar)
