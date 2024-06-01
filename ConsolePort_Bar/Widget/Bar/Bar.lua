local _, env, db = ...; db = env.db;
---------------------------------------------------------------
CPActionBar = Mixin({
---------------------------------------------------------------
    Env = {
        OnLoad = [[
            manager = self:GetFrameRef('Manager')
            cursor  = manager:GetFrameRef('Cursor')
            pager   = manager:GetFrameRef('Pager')
        ]];
    };
    -----------------------------------------------------------
}, CPAPI.AdvancedSecureMixin, env.CommonWidgetMixin, env.DynamicWidgetMixin);
---------------------------------------------------------------

function CPActionBar:OnLoad()
    db.Pager:RegisterHeader(self)
    self:SetFrameRef('Manager', env.Manager)
    self:Run(self.Env.OnLoad)
    self:EnableMouse(false)
end

function CPActionBar:RegisterDriver(type, driver, body, current)
    driver = env.ConvertDriver(driver)
    body   = CPAPI.ConvertSecureBody(body)

    RegisterStateDriver(self, type, driver)
    self:SetAttribute(type, current or SecureCmdOptionParse(driver))
    self:SetAttribute(env.Attributes.Driver(type), driver)
    self:SetAttribute(env.Attributes.State(type), body)
    self:Run([[local newstate = self:GetAttribute(%q) %s]], type, body)
end

function CPActionBar:RunDriver(type) self:Run([[
    local newstate = SecureCmdOptionParse(%q); %s
]], self:GetAttribute(env.Attributes.Driver(type)), self:GetAttribute(env.Attributes.State(type))) end

function CPActionBar:RunAttribute(attribute, ...) self:Run([[
    self::%s(%q)
]], attribute, ...) end

function CPActionBar:RegisterModifierDriver(driver, body, current)
    self:RegisterDriver('modifier', driver, body, current)
end

function CPActionBar:RegisterVisibilityDriver(driver, current)
    driver = env.ConvertDriver(driver)
    RegisterStateDriver(self, env.Attributes.Visible, driver)
    self:SetAttribute(env.Attributes.Visible, current or SecureCmdOptionParse(driver))
end

function CPActionBar:RegisterPageResponse(body)
    self:SetAttribute(env.Attributes.OnPage, body)
end