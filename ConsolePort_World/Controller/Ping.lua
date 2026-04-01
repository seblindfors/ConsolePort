if not CPAPI.IsRetailVersion then return end;
local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local PING_ROW_INDEX = env.QMenuID();
---------------------------------------------------------------
-- Ping data: enum value (0-indexed), slash arg (1-indexed), atlas, label
---------------------------------------------------------------
local PingTypes = {
	{ textureKit = 'Attack',    label = PING_TYPE_ATTACK };
	{ textureKit = 'Warning',   label = PING_TYPE_WARNING };
	{ textureKit = 'OnMyWay',   label = PING_TYPE_ON_MY_WAY };
	{ textureKit = 'Assist',    label = PING_TYPE_ASSIST };
	{ textureKit = 'NonThreat', label = PING_TYPE_NOT_THREAT };
	{ textureKit = 'Threat',    label = PING_TYPE_THREAT };
};

---------------------------------------------------------------
local PingButton = {};
---------------------------------------------------------------

function PingButton:OnLoad()
	self:SetAttribute(CPAPI.ActionTypePress, 'macro')
	self:SetAttribute(CPAPI.ActionUseOnKeyDown, true)
	self:RegisterForClicks('AnyDown')

	env.QMenu:Hook(self, 'PreClick', [[
		local id = tostring(self:GetID())
		local body;
		if button == 'MiddleButton' then
			body = '/ping [@player] ' .. id
		elseif button == 'RightButton' then
			body = '/console GamePadCursorCentering 1\n/ping ' .. id .. '\n/console GamePadCursorCentering 0'
		elseif UnitExists('target') then
			body = '/ping [@target] ' .. id
		else
			body = '/console GamePadCursorCentering 1\n/ping ' .. id .. '\n/console GamePadCursorCentering 0'
		end
		self:SetAttribute('macrotext', body)
	]])

	env.QMenu:Hook(self, 'PostClick', [[
		owner::Disable()
	]])
end

function PingButton:Init()
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	self:Update()
	self.Init = nop;
	self.NormalTexture:SetDrawLayer('BACKGROUND')
	self.NormalTexture:SetTexCoord(0, 1, 0, 1)
	self.HighlightTexture:ClearAllPoints()
	self.HighlightTexture:SetTexCoord(0, 1, 0, 1)
	self.HighlightTexture:SetPoint('TOPLEFT', -5, 0)
	self.HighlightTexture:SetPoint('BOTTOMRIGHT', 8, -4)
end

function PingButton:SetData(data)
	self.pingData = data;
end

function PingButton:Update()
	local data = self.pingData;
	if not data then return end;
	local icon = self.icon or self.Icon;
	if icon then
		icon:SetAtlas('Ping_Marker_Icon_'..data.textureKit)
		icon:SetDesaturated(false)
		icon:SetPoint('TOPLEFT', 10, -9)
		icon:SetPoint('BOTTOMRIGHT', -9, 9)
	end
	local mt = CPAPI.Index(self.NormalTexture)
	mt.SetAtlas(self.NormalTexture, 'Ping_UnitMarker_BG_'..data.textureKit)
	mt.SetAtlas(self.HighlightTexture, 'Ping_OVMarker_Pointer_'..data.textureKit)
end

function PingButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
	self:LockHighlight()
end

function PingButton:UpdateTooltip()
	local data = self.pingData;
	if not data then return end;
	GameTooltip:SetText(data.label)
	local hasAddedLine = false;
	for _, info in ipairs({
		{ 'LeftButton',   BINDING_NAME_TARGETFOCUS };
		{ 'RightButton',  BINDING_NAME_TARGETMOUSEOVER };
		{ 'MiddleButton', BINDING_NAME_TARGETSELF };
		{ 'CancelButton', CLOSE };
	}) do
		local text = env:GetTooltipPromptForClick(unpack(info))
		if text then
			hasAddedLine = true;
			GameTooltip:AddLine(text, 1, 1, 1)
		end
	end
	if hasAddedLine then
		GameTooltip:Show()
	end
end

function PingButton:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local PingRow = {};
---------------------------------------------------------------

function PingRow:OnLoad()
	local xOffset = tonumber(self:GetAttribute('xOffset')) or 0;
	local point   = self:GetAttribute('point') or 'TOPLEFT';

	self.buttons = {};
	for i, data in ipairs(PingTypes) do
		local button = CreateFrame('Button', '$parentPingSlot'..i, self, 'CPWorldSecureButtonBaseTemplate')
		CPAPI.Specialize(button, PingButton)
		button:SetID(i)
		button:SetData(data)
		if i == 1 then
			button:SetPoint(point, self, point, 0, 0)
		else
			button:SetPoint(point, self.buttons[i - 1], point, xOffset, 0)
		end
		self.buttons[i] = button;
	end

	self:SetTitle(PING_SYSTEM_LABEL)
	self:UpdateState()
	db:RegisterSafeCallback('Settings/QMenuCollectionPing', self.UpdateState, self)
end

function PingRow:LayoutItems()
	return self.buttons;
end

function PingRow:UpdateState()
	if not db('QMenuCollectionPing') then
		self:UnregisterAllEvents()
		return self:Hide()
	end
	self:RegisterEvent('PING_SYSTEM_ERROR')
	self:Show()
end

function PingRow:OnShow()
	for _, button in ipairs(self.buttons) do
		button:Init()
	end
end

function PingRow:PING_SYSTEM_ERROR()
	local cooldown = C_Ping.GetCooldownInfo()
	if cooldown and cooldown.startTimeMs and cooldown.endTimeMs then
		for _, button in ipairs(self.buttons) do
			button.cooldown:SetDrawBling(false)
			CooldownFrame_Set(button.cooldown,
				cooldown.startTimeMs / 1000,
				(cooldown.endTimeMs - cooldown.startTimeMs) / 1000,
				true
			);
		end
	end
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:AddQMenuFactory('QMenuCollectionPing', function(QMenu)
	local header = CreateFrame('Frame', '$parentPing', QMenu, 'QMenuRow')
	CPAPI.Specialize(CPAPI.EventHandler(header), env.QMenuRow, PingRow)
	QMenu:AddFrame(header, PING_ROW_INDEX)
	header:Layout()
end)