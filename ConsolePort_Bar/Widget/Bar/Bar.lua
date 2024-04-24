local _, env, db = ...; db = env.db;
---------------------------------------------------------------
CPActionBar = CreateFromMixins(CPAPI.AdvancedSecureMixin, env.CommonWidgetMixin);
---------------------------------------------------------------
CPActionBar.Env = {
};

function CPActionBar:OnLoad()
    db.Pager:RegisterHeader(self, true);
    self:SetFrameRef('Manager', env.Manager)
    self:SetFrameRef('Pager', db.Pager)
    self:Run([[
        manager = self:GetFrameRef('Manager')
        pager   = self:GetFrameRef('Pager')
    ]])
end

function CPActionBar:RegisterModifierDriver(driver, current)
    RegisterStateDriver(self, 'modifier', driver)
    self:SetAttribute('modifier', current or SecureCmdOptionParse(driver))
end

function CPActionBar:RegisterPageDriver(driver, current)
    RegisterStateDriver(self, 'actionpage', driver)
    self:SetAttribute('actionpage', current or SecureCmdOptionParse(driver))
end

function CPActionBar:RegisterVisibilityDriver(driver, current)
    RegisterStateDriver(self, 'visibility', driver)
    self:SetAttribute('visibility', current or SecureCmdOptionParse(driver))
end