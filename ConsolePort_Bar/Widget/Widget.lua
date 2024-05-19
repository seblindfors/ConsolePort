local _, env = ...;
---------------------------------------------------------------
local CommonWidget = setmetatable({}, GetFrameMetatable());
env.CommonWidgetMixin = CommonWidget;
---------------------------------------------------------------
local CommonHandlers = {
    height = CommonWidget.SetHeight;
    level  = CommonWidget.SetFrameLevel;
    point  = CommonWidget.ClearAllPoints;
    scale  = CommonWidget.SetScale;
    strata = CommonWidget.SetFrameStrata;
    width  = CommonWidget.SetWidth;
};

function CommonWidget:SetCommonConfig(config)
    for key, handler in pairs(CommonHandlers) do
        if ( config[key] ~= nil ) then
            handler(self, config[key]);
        end
    end
    if config.pos then
        local info = config.pos;
        self:ClearAllPoints()
        self:SetPoint(info.point, UIParent, info.relativePoint or info.point, info.x, info.y)
    end
    self.config = config;
end

---------------------------------------------------------------
local DynamicWidget = {};
env.DynamicWidgetMixin = DynamicWidget;
---------------------------------------------------------------
local NESTING_LEVEL = 1; -- How deep to register callbacks

function DynamicWidget:SetDynamicCallbacks(config, level)
    env:RegisterCallback(tostring(config), self.OnConfigChanged, self);
    if level == 0 then return end;
    for _, datapoint in pairs(config) do
        if type(datapoint) == 'table' then
            self:SetDynamicCallbacks(datapoint, level - 1)
        end
    end
end

function DynamicWidget:ClearDynamicCallbacks(config, level)
    env:UnregisterCallback(tostring(config), self);
    if level == 0 then return end;
    for _, datapoint in pairs(config) do
        if type(datapoint) == 'table' then
            self:ClearDynamicCallbacks(datapoint, level - 1)
        end
    end
end

function DynamicWidget:SetDynamicConfig(config)
    if self.config then
        self:ClearDynamicCallbacks(self.config, NESTING_LEVEL)
        self.config = nil;
    end
    if self.SetCommonConfig then
        self:SetCommonConfig(config)
    end
    self.config = config;
    self:SetDynamicCallbacks(config, NESTING_LEVEL)
end

function DynamicWidget:OnConfigChanged(key, value)
    -- Implement in child
    CPAPI.Log('Config changed '..tostring(key)..' to '..tostring(value)..' but it was not handled.');
end

---------------------------------------------------------------
local MovableWidget = {OnConfigUpdated = DynamicWidget.OnConfigChanged};
env.MovableWidgetMixin = MovableWidget;
---------------------------------------------------------------

function MovableWidget:OnConfigChanged(key, ...)
    if ( key == 'OnMoveStart' ) then
        return env:TriggerEvent('OnMoveFrame', self:GetMoveTarget(), ..., self:GetSnapSize())
    end
    return self:OnConfigUpdated(key, ...);
end

function MovableWidget:GetMoveTarget()
    return self; -- Implement in child
end

function MovableWidget:GetSnapSize()
    return self.snapToPixels or 1; -- Implement in child
end

---------------------------------------------------------------
env.ConfigurableWidgetMixin = CreateFromMixins(
    CommonWidget,
    DynamicWidget,
    MovableWidget
);
---------------------------------------------------------------