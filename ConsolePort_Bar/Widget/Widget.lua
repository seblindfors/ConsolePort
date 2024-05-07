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
        self:SetPoint(info.point, UIParent, info.relativePoint or info.point, info.x, info.y)
    end
    self.config = config;
end