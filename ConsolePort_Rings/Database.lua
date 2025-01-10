local _, Data, env, db = CPAPI.LinkEnv(...)
---------------------------------------------------------------
-- The basics
---------------------------------------------------------------
env.ActionButton  = LibStub('ConsolePortActionButton');
env.DisplayButton = CreateFromMixins(CPActionButton);

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
function env:AddLoader(loader)
    if not self.Loaders then
        self.Loaders = {};
    end
    tinsert(self.Loaders, loader);
end

function env:LoadModules(data)
    if self.Loaders then
        for _, loader in ipairs(self.Loaders) do
            loader(self.Frame, data);
        end
    end
    self.Loaders, self.LoadModules, self.AddLoader = nil;
end

function env:GetTooltipPrompt(text, button)
    if not button then return end;
    local device = self.db.Gamepad.Active;
    if device then
        return device:GetTooltipButtonPrompt(button, text, 64);
    end
end