--------------------------------------
-- MORE FUCKING RINGZ
--------------------------------------
-- NUMRINGS: how many
-- DESCS: describe them in order
-- POINTS: where to put these bastards
--------------------------------------

local NUMRINGS = 2
local DESCS = {'Left', 'Right'}
local POINTS = {
    {'CENTER', -530, 0},
    {'CENTER', 530, 0},
}
--------------------------------------
local R, B = {}, {}

function R:OnRefresh(size)
    local tbl = ConsolePortRINGZ[self:GetID()]
    if tbl then
        for index, info in pairs(tbl) do
            local button = self.Buttons[index]
            if button and info.action then
                button:SetAttribute('type', info.action)
                button:SetAttribute('cursorID', info.cursorID)
                button:SetAttribute(info.action, info.value)
                button:Show()
            end
        end
    end
end

function R:OnButtonFocused(index)
    local button = self:GetAttribute(index)
    local focused = self.old and self:GetAttribute(self.old)
    if focused then focused:OnLeave() end
    if button and button:IsVisible() then button:OnEnter() end
    self.old = index
end

function R:OnNewButton(button, index)
    Mixin(button, B)
end

function B:OnContentChanged(actionType)
    ConsolePortRINGZ[self:GetParent():GetID()][self:GetID()] = {
        action = actionType;
        value = self:GetAttribute(actionType);
        cursorID = self:GetAttribute('cursorID');
    }
end

function B:OnContentRemoved()
    ConsolePortRINGZ[self:GetParent():GetID()][self:GetID()] = nil
end

local id, t = ...
local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_LOADED')
f:SetScript('OnEvent', function(self, _, name)
    if name == id then
        ConsolePortRINGZ = ConsolePortRINGZ or {{},{},{}}
        for i=1, NUMRINGS do
            local ring = CreateFrame('BUTTON', 'ConsolePortRING'..i, UIParent, 'ConsolePortRingTemplate')
            ring.Buttons = {}
            ring:SetID(i)
            ring:SetPoint(unpack(POINTS[i]))
            ring:Hide()
            Mixin(ring, R)
            ring:Initialize()
            ring:SetCursorDrop(true)
        end
        self:UnregisterEvent('ADDON_LOADED')
    end
end)



local GetCustomBindings = ConsolePort.GetCustomBindings

function ConsolePort:GetCustomBindings()
    local t = GetCustomBindings(self)
    local L = ConsolePort:GetData().CUSTOMBINDS
    for i=12, 11+NUMRINGS do
        local j = i-11
        local name = (L.CP_UTILITYBELT) .. ' '..DESCS[j]
        local bind = 'CLICK ConsolePortRING'..j..':LeftButton'
        tinsert(t, i, {
            name = name,
            binding = bind,
        })
        _G['BINDING_NAME_'..bind] = name
    end
    return t
end