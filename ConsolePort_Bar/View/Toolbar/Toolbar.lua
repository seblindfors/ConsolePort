local _, env, db, L = ...; db = env.db; L = db.Locale;
---------------------------------------------------------------
local TooltipButton = {};
---------------------------------------------------------------

function TooltipButton:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, self.title)
    if self.instruction then GameTooltip_AddInstructionLine(GameTooltip, self.instruction) end
    if self.error then GameTooltip_AddErrorLine(GameTooltip, self.error) end
    GameTooltip:Show()
    db.Alpha.Flash(self.FlashBorder, 1, 1, -1, false, 0, 0, 'microbutton')
end

function TooltipButton:OnLeave()
    db.Alpha.Stop(self.FlashBorder)
end

---------------------------------------------------------------
local Eye = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
    instruction = L'Toggle visibility of all modifier flyouts.';
});

function Eye:OnLoad()
    env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
    self:OnShowAll(env('clusterShowAll'))
    self:RegisterForClicks('AnyDown', 'AnyUp')
    CPAPI.Start(self)
end

function Eye:OnShowAll(showAll)
    local icon = showAll and env.GetAsset([[Textures\Show]]) or env.GetAsset([[Textures\Hide]]);
    self.NormalTexture:SetTexture(icon)
    self.PushedTexture:SetTexture(icon)
    self.title = showAll and L'Hide Flyout Buttons' or L'Show Flyout Buttons';
end

function Eye:OnClick()
    env('Settings/clusterShowAll', not env('clusterShowAll'))
    self:OnEnter()
end

---------------------------------------------------------------
local Config = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
    title       = L'Action Bar Configuration';
    instruction = L'Open the configuration menu for the action bar.';
});

function Config:OnLoad()
    self:RegisterForClicks('AnyDown', 'AnyUp')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:RegisterEvent('PLAYER_REGEN_DISABLED')
    CPAPI.Start(self)
end

function Config:OnEvent()
    self:SetEnabled(not InCombatLockdown())
    self.error = InCombatLockdown() and L'Cannot open configuration menu in combat.' or nil;
end

function Config:OnClick()
    env:TriggerEvent('OnConfigToggle')
end

---------------------------------------------------------------
local PopoutFrame = {};
---------------------------------------------------------------
function PopoutFrame:OnLoad()
    Mixin(self.Eye, Eye):OnLoad()
    Mixin(self.Config, Config):OnLoad()

    self.MicroButtons = {};
    local count = CreateCounter()
    for _, button in pairs(MICRO_BUTTONS) do
        local button = _G[button];
        if button then
            self.MicroButtons[button] = button.layoutIndex or count();
        end
    end

    self:MoveMicroButtons()
    self:SlideOut()
    RunNextFrame(function()
        self:Layout()
    end)
end

function PopoutFrame:Layout()
    local container = self:GetParent()
    self.maximumWidth = ConsolePortToolbar:GetWidth() - 64;
    self.stride = math.floor(self.maximumWidth / 32) - 1;
    GridLayoutFrameMixin.Layout(self)
    container:SetSize(self:GetWidth() + 64, self:GetHeight() + 64)
    container.SlideIn.Translate:SetOffset(0, self:GetHeight())
    container.SlideOut.Translate:SetOffset(0, -self:GetHeight())
end

function PopoutFrame:MoveMicroButtons()
    for button in pairs(self.MicroButtons) do
        button:SetParent(self)
        button:SetIgnoreParentAlpha(true)
    end
    self:Layout()
end

function PopoutFrame:SlideIn()
    self:GetParent().SlideIn:Play()
end

function PopoutFrame:SlideOut()
    self:GetParent().SlideOut:Play()
end

function PopoutFrame:SetActive(active)
    self:SetPoint('BOTTOM', 0, active and 0 or -self:GetHeight())
    for button in pairs(self.MicroButtons) do
        -- Show help tip frames when the micro buttons are hidden,
        -- which is why this is true when the popout is NOT active.
        button:SetIgnoreParentAlpha(not active)
    end
end

---------------------------------------------------------------
CPMicroButton = {};
---------------------------------------------------------------
function CPMicroButton:OnLoad()
    CPAPI.SetAtlas(self.Background, 'UI-HUD-MicroMenu-ButtonBG-Up', true)
    CPAPI.SetAtlas(self.PushedBackground, 'UI-HUD-MicroMenu-ButtonBG-Down', true)
    CPAPI.SetAtlas(self.FlashBorder, 'UI-HUD-MicroMenu-Highlightalert', false)
    if self.normalAtlas then
        CPAPI.SetAtlas(self.NormalTexture, self.normalAtlas, true)
    end
    if self.highlightAtlas then
        CPAPI.SetAtlas(self.HighlightTexture, self.highlightAtlas, true)
    end
end

function CPMicroButton:OnEnter()
    if self.normalAtlas then
	    self.NormalTexture:SetAlpha(0)
    end
end

function CPMicroButton:OnLeave()
    if self.normalAtlas then
	    self.NormalTexture:SetAlpha(1)
    end
end

function CPMicroButton:SetPushed()
	self.Background:Hide()
	self.PushedBackground:Show()

	self:SetButtonState('PUSHED', true)
    if self.highlightAtlas then
        self.HighlightTexture:SetBlendMode('ADD')
	    self.HighlightTexture:SetAlpha(0.5)
    end
end

function CPMicroButton:SetNormal()
	self:SetButtonState('NORMAL')
    if self.highlightAtlas then
        CPAPI.SetAtlas(self.HighlightTexture, self.highlightAtlas, true)
        self.HighlightTexture:SetBlendMode('BLEND')
        self.HighlightTexture:SetAlpha(1)
    end
	self.Background:Show()
	self.PushedBackground:Hide()
end

function CPMicroButton:OnShow()
	self:GetParent():Layout()
end

function CPMicroButton:OnHide()
	self:GetParent():Layout()
end

function CPMicroButton:OnMouseDown()
	if self:IsEnabled() then
		self:SetPushed()
	end
end

function CPMicroButton:OnMouseUp()
    if self:IsEnabled() then
        self:SetNormal()
    end
end

---------------------------------------------------------------
CPToolbar = CreateFromMixins(env.ConfigurableWidgetMixin);
---------------------------------------------------------------
function CPToolbar:OnLoad()
    env:RegisterCallbacks(self.OnDataLoaded, self,
        'OnDataLoaded',
        'Settings/enableXPBar',
        'Settings/fadeXPBar',
        'Settings/tintColor',
        'Settings/xpBarColor'
    );
    self.snapToPixels = 16;
    self:RegisterEvent('CURSOR_CHANGED')
    self.PopoutContainer:SetParent(self:GetParent())
    self.PopoutContainer:SetFrameLevel(self:GetFrameLevel() + 10)
    Mixin(self.PopoutContainer.PopoutFrame, PopoutFrame):OnLoad()
end

function CPToolbar:OnEnter()
    if self:GetScript('OnUpdate') then return end;
    self.PopoutContainer.SlideIn:Play()
    self:SetScript('OnUpdate', self.OnUpdate)
    self.fadeOutTimer = 0;
end

function CPToolbar:OnSizeChanged()
    self.PopoutContainer.PopoutFrame:Layout()
    if ( not self.XPBar ) then return end;
    self.XPBar:SetWidth(self:GetWidth() * 0.8)
    self.XPBar:UpdateBarsShown()
end

function CPToolbar:OnUpdate(elapsed)
    if self.PopoutContainer:IsMouseOver() then
        self.fadeOutTimer = 0;
        return
    end
    self.fadeOutTimer = self.fadeOutTimer + elapsed;
    if self.fadeOutTimer > 1 then
        self.PopoutContainer.SlideOut:Play()
        self:SetScript('OnUpdate', nil)
    end
end

function CPToolbar:OnEvent()
    self.PopoutContainer:SetShown(not GetCursorInfo())
end

function CPToolbar:ToggleXPBar(enabled)
    if ( not self.XPBar ) then
        if not enabled then return end;
        self.XPBar = CreateFrame('Frame', nil, self, 'CPWatchBarContainer')
    end
    self.XPBar:SetShown(enabled)
    self.XPBar:SetMainBarColor(env:GetColorRGB('xpBarColor'))
end

function CPToolbar:ToggleXPBarFade(xpBarEnabled)
    if ( not self.XPBar ) then return end;
    if not xpBarEnabled then return end;
    self.XPBar:OnShow() -- env('fadeXPBar') is handled by the XPBar itself
end

function CPToolbar:SetTintColor(r, g, b, a)
    self.BG:SetGradient(env:GetColorGradient(r, g, b, a))
    self.BottomLine:SetVertexColor(r, g, b, a)
    self.PopoutContainer.PopoutFrame.Gradient:SetGradient(env:GetColorGradient(r, g, b, a))
end

function CPToolbar:OnDataLoaded()
    self:SetTintColor(env:GetColorRGBA('tintColor'))
    self:ToggleXPBar(env('enableXPBar'))
    self:ToggleXPBarFade(env('enableXPBar'))
end

function CPToolbar:SetProps(props)
    self:SetDynamicProps(props)
    self:OnDataLoaded()
    self:OnSizeChanged()
    self:Show()
end

function CPToolbar:OnPropsUpdated()
    self:SetProps(self.props)
end

env:AddFactory('Toolbar', function()
    if not ConsolePortToolbar then
        ConsolePortToolbar = CreateFrame('Frame', 'ConsolePortToolbar', env.Manager, 'CPToolbar')
        ConsolePortToolbar:OnLoad()
    end
    return ConsolePortToolbar;
end, env.Interface.Toolbar)