local _, env, db = ...; db = env.db;
---------------------------------------------------------------
CPActionBar = CreateFromMixins(CPAPI.AdvancedSecureMixin, env.CommonWidgetMixin);
---------------------------------------------------------------
local STATE_PREFIX, DRIVER_PREFIX = '_onstate-', 'driver-';
---------------------------------------------------------------
CPActionBar.Env = {
    OnLoad = [[
        manager = self:GetFrameRef('Manager')
        pager   = self:GetFrameRef('Pager')
    ]];
};

function CPActionBar:OnLoad()
    db.Pager:RegisterHeader(self, true);
    self:SetFrameRef('Manager', env.Manager)
    self:SetFrameRef('Pager', db.Pager)
    self:Run(self.Env.OnLoad)
end

function CPActionBar:RegisterDriver(type, driver, body, current) body = CPAPI.ConvertSecureBody(body)
    RegisterStateDriver(self, type, driver)
    self:SetAttribute(type, current or SecureCmdOptionParse(driver))
    self:SetAttribute(DRIVER_PREFIX..type, driver)
    self:SetAttribute(STATE_PREFIX..type, body)
    self:Run([[local newstate = self:GetAttribute(%q) %s]], type, body)
end

function CPActionBar:RunDriver(type) self:Run([[
    local newstate = SecureCmdOptionParse(%q); %s
]], self:GetAttribute(DRIVER_PREFIX..type), self:GetAttribute(STATE_PREFIX..type)) end

function CPActionBar:RegisterModifierDriver(driver, body, current)
    self:RegisterDriver('modifier', driver, body, current)
end

function CPActionBar:RegisterPageDriver(driver, body, current)
    self:RegisterDriver('actionpage', driver, body, current)
end

function CPActionBar:RegisterVisibilityDriver(driver, current)
    RegisterStateDriver(self, 'visibility', driver)
    self:SetAttribute('visibility', current or SecureCmdOptionParse(driver))
end