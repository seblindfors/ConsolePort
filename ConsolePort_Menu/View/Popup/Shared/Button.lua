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
-- Action slot widget
---------------------------------------------------------------
local THUMB_HEIGHT = 4;
local Fader, SlotColors = db('Alpha/Fader'), {
	Normal  = CreateColor(0.05, 0.05, 0.05, 0.35);
	Checked = CreateColor(1, 0.7451, 0, 1);
	Border  = CreateColor(0.15, 0.15, 0.15, 0.65);
	CheckBG = CPAPI.GetWebColor(CPAPI.GetClassFile(), 'ee');
};

CPPopupActionSlotMixin = {};

function CPPopupActionSlotMixin:OnLoad()
	self.CheckedThumb:SetColorTexture(SlotColors.Checked:GetRGBA())
	self.HiliteThumb:SetColorTexture(0, 0.68235, 1, 1)
	PixelUtil.SetHeight(self.CheckedThumb, THUMB_HEIGHT)
	PixelUtil.SetHeight(self.HiliteThumb, THUMB_HEIGHT)
	self:ApplyBackground()
end

function CPPopupActionSlotMixin:OnEnter()
	self:LockHighlight()
end

function CPPopupActionSlotMixin:OnLeave()
	self:UnlockHighlight()
end

function CPPopupActionSlotMixin:OnHide()
	self:UnlockHighlight()
end

function CPPopupActionSlotMixin:OnClick()
	self:OnChecked(self:GetChecked())
end

function CPPopupActionSlotMixin:OnChecked(checked)
	Fader.Toggle(self.CheckedThumb, 0.15, checked)
	Fader.Toggle(self.HiliteThumb, 0.15, not checked)
	self:ApplyBackground()
	if self.drawOutline then
		self:SetBackdropBorderColor(self:GetOutlineColor():GetRGBA())
		self:SetBackdropColor(self:GetBackgroundColor():GetRGBA())
	end
end

function CPPopupActionSlotMixin:Check()
	self:SetChecked(true)
	self:OnChecked(true)
end

function CPPopupActionSlotMixin:Uncheck()
	self:SetChecked(false)
	self:OnChecked(false)
end

function CPPopupActionSlotMixin:GetBackgroundColor()
	return SlotColors[self:GetChecked() and 'CheckBG' or 'Normal'];
end

function CPPopupActionSlotMixin:GetOutlineColor()
	return SlotColors[self:GetChecked() and 'Checked' or 'Border'];
end

function CPPopupActionSlotMixin:ApplyBackground()
	self.Background:SetVertexColor(self:GetBackgroundColor():GetRGBA())
end

function CPPopupActionSlotMixin:SetDrawOutline(enabled)
	self.drawOutline = enabled;
	self:SetBackdrop(enabled and CPAPI.Backdrops.Simple or nil)
	self:SetBackdropBorderColor(self:GetOutlineColor():GetRGBA())
end

---------------------------------------------------------------
-- Shared popup action button
---------------------------------------------------------------
local MapActionButton = db:Register('PopupMenuMapActionButton', CreateFromMixins(CPPopupActionSlotMixin))

function MapActionButton:OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetAction(self:GetID())
	GameTooltip:AddLine(self:GetAttribute('name'))
	local slug = self:GetAttribute('slug')
	if slug then
		GameTooltip:AddLine(('%s: %s'):format(KEY_BINDING, self.Slug:GetText()), GameFontGreen:GetTextColor())
	end
	GameTooltip:Show()
end

function MapActionButton:OnLeave()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide()
	end
end

function MapActionButton:OnHide()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide()
	end
end

function MapActionButton:Update()
	self:UpdateBinding()
	local texture = GetActionTexture(self:GetID())
	self.Icon:SetTexture(texture or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	self.Icon:SetDesaturated(not texture or false)
	if not texture then
		self.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
	else
		self.Icon:SetVertexColor(1, 1, 1, 1)
	end

	local isAlreadyMapped = self:GetParent():GetSpellID() == select(2, GetActionInfo(self:GetID()))
	if isAlreadyMapped then
		self:Check()
	else
		self:Uncheck()
	end
end

function MapActionButton:UpdateBinding()
	local binding = db('Actionbar/Action/'..self:GetID())
	if binding then
		local slug = db.Hotkeys:GetButtonSlugForBinding(binding)
		self.Slug:SetText(slug)
		self:SetAttribute('slug', slug)
	else
		self.Slug:SetText(nil)
		self.Slug:SetAttribute('slug', nil)
	end
	self.bindingID = binding;
end

function MapActionButton:OnSpecialClick(...)
	local parent = self:GetParent()
	if self.bindingID and not parent:HasPendingKeyChord() then
		parent:ReportSetBinding(self, self.bindingID, self:GetID())
	end
end

function MapActionButton:OnCancelClick(...)
	self:GetParent():Hide()
end

function MapActionButton:OnClick(button)
	local actionID, bindingID = self:GetID(), self.bindingID;
	local isUnbound = not self:GetAttribute('slug');

	local parent = self:GetParent()
	if ( button == 'RightButton' ) then
		if parent:HasPendingKeyChord() then
			parent:Hide()
			return ClearCursor()
		end
		if not GetActionInfo(actionID) then
			parent:ReportClearBinding(bindingID)
		end
		PickupAction(actionID)
		self:Update()
		return ClearCursor()
	end
	ClearCursor()

	local spellID = parent:GetSpellID()
	CPAPI.PickupSpell(spellID)
	PlaceAction(actionID)
	self:Update()

	if bindingID and parent:HasPendingKeyChord() then
		parent:ReportSetBindingToKeyChord(bindingID)
		isUnbound = false;
		self:Update()
	end

	local type, _, _, cursorSpellID = GetCursorInfo()
	if ( type == 'spell' and cursorSpellID ~= spellID ) then
		parent:SetSpellID(cursorSpellID)
		parent:MapActionBar()
	else
		if bindingID and isUnbound then
			parent:ReportNoBinding(self, bindingID, actionID)
		else
			parent:Hide()
		end
	end
	ClearCursor()
end