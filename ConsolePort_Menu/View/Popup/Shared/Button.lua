---------------------------------------------------------------
-- Shared popup menu button
---------------------------------------------------------------
local env, db = CPAPI.GetEnv(...);
local MenuButton = db:Register('PopupMenuButton', {})
---------------------------------------------------------------
local COMMAND_OPT_ICON = CPAPI.Proxy({
	Sell       = 'Auctioneer';
	Split      = 'Banker';
	Trade      = 'Auctioneer';
	Equip      = 'poi-transmogrifier';
	Pickup     = 'MiniMap-QuestArrow';
	Delete     = 'XMarksTheSpot';
	Inspect    = 'None';
	RingBind   = 'GreenCross';
	RingClear  = 'Islands-MarkedArea';
	Disenchant = 'UpgradeItem-32x32';
	ShowSocket = 'AzeriteReady';
	MapActionBar = 'TorghastDoor-ArrowDown-32x32';
}, 'Waypoint-MapPin-Minimap-Tracked')
---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function MenuButton:OnLoad()
	self:HookScript('OnClick', self.OnClick)
	self:HookScript('OnHide', self.OnLeave)
end

function MenuButton:OnClick()
	if self.command then
		self:GetParent()[self.command](self:GetParent(), self.data)
	end
end

function MenuButton:SpecialClick()
	self:OnClick()
end

function MenuButton:OnCancelClick(...)
	self:GetParent():Hide()
end

function MenuButton:OnEnter()
	if not GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:LockHighlight()
end

function MenuButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:UnlockHighlight()
end

function MenuButton:SetCommand(text, command, data, handlers, init)
	self.data, self.command = data, command;
	CPAPI.SetAtlas(self.Icon, COMMAND_OPT_ICON[command])
	self:SetAttribute('nohooks', true)
	self:SetEnabled(true)
	self:SetScript('OnEnter',  handlers and handlers.OnEnter or self.OnEnter)
	self:SetScript('OnLeave',  handlers and handlers.OnLeave or self.OnLeave)
	self:SetScript('OnUpdate', handlers and handlers.OnUpdate or nil)
	self:SetText(text)
	if init then
		init(self)
	end
end

---------------------------------------------------------------
-- Action placement, owned by the config addon
---------------------------------------------------------------
function env.ShowActionPlacer(kind, keyChord, ...)
	if not CPAPI.LoadAddOn(CPAPI.ConfigAddOn) then return end;
	return ConsolePortConfig:GetEnvironment():ShowActionPlacer(kind, keyChord, ...)
end
