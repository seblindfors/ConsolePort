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

function CPActionBar:RegisterDriver(type, driver, body, current) body = CPAPI.ConvertSecureBody(body)
    RegisterStateDriver(self, type, driver)
    self:SetAttribute(type, current or SecureCmdOptionParse(driver))
    self:SetAttribute(env.Driver(type), driver)
    self:SetAttribute(env.State(type), body)
    self:Run([[local newstate = self:GetAttribute(%q) %s]], type, body)
end

function CPActionBar:RunDriver(type) self:Run([[
    local newstate = SecureCmdOptionParse(%q); %s
]], self:GetAttribute(env.Driver(type)), self:GetAttribute(env.State(type))) end

function CPActionBar:RunAttribute(attribute, ...) self:Run([[
    self::%s(%q) 
]], attribute, ...) end

function CPActionBar:RegisterModifierDriver(driver, body, current)
    self:RegisterDriver('modifier', driver, body, current)
end

function CPActionBar:RegisterVisibilityDriver(driver, current)
    RegisterStateDriver(self, env.Visible, driver)
    self:SetAttribute(env.Visible, current or SecureCmdOptionParse(driver))
end

function CPActionBar:RegisterPageResponse(body)
    self:SetAttribute(env.OnPage, body)
end