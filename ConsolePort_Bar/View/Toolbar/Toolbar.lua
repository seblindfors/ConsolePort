local _, env, db = ...; db = env.db;
---------------------------------------------------------------
local PATH = 'Layout/bars/Toolbar/';
---------------------------------------------------------------
CPToolbar = CreateFromMixins(env.CommonWidgetMixin);
---------------------------------------------------------------
function CPToolbar:OnLoad()
    env:RegisterCallbacks(self.OnDataLoaded, self,
        'OnDataLoaded',
        'Settings/enableXPBar',
        'Settings/fadeXPBar',
        'Settings/tintColor'
    );
end

function CPToolbar:ToggleXPBar(enabled)
    if ( not self.XPBar ) then
        if not enabled then return end;
        self.XPBar = CreateFrame('Frame', nil, self, 'CP_WatchBarContainer')
        self.XPBar:SetPoint('BOTTOM')
    end
    self.XPBar:SetShown(enabled)
end

function CPToolbar:ToggleXPBarFade(enabled)
    if ( not self.XPBar ) then return end;
    self.XPBar:OnShow()
end

function CPToolbar:SetTintColor(r, g, b, a)
    self.BG:SetGradient(env:GetColorGradient(r, g, b, a))
    self.BottomLine:SetVertexColor(r, g, b, a)
end

function CPToolbar:OnDataLoaded()
    self:SetTintColor(env:GetColorRGB('tintColor'))
    self:ToggleXPBar(env('enableXPBar'))
    self:ToggleXPBarFade(env('fadeXPBar'))
end

function CPToolbar:SetConfig(config)
    self:SetCommonConfig(config)
    self:OnDataLoaded()
end

env:AddFactory('Toolbar', function()
    if not ConsolePortToolbar then
        ConsolePortToolbar = CreateFrame('Frame', 'ConsolePortToolbar', env.Manager, 'CPToolbar')
        ConsolePortToolbar:OnLoad()
    end
    return ConsolePortToolbar;
end)