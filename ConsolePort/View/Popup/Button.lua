---------------------------------------------------------------
-- Shared popup menu button
---------------------------------------------------------------
local _, db = ...;
local MenuButton = db:Register('PopupMenuButton', {})
---------------------------------------------------------------
local COMMAND_OPT_ICON = {
	Default   = [[Interface\QuestFrame\UI-Quest-BulletPoint]];
	Sell      = [[Interface\GossipFrame\BankerGossipIcon]];
	Split     = [[Interface\Cursor\UI-Cursor-SizeLeft]];
	Equip     = [[Interface\GossipFrame\transmogrifyGossipIcon]];
	Pickup    = [[Interface\Cursor\openhand]];
	Delete    = [[Interface\Buttons\UI-GroupLoot-Pass-Up]];
	RingBind  = [[Interface\Buttons\UI-AttributeButton-Encourage-Up]];
	RingClear = [[Interface\Buttons\UI-MinusButton-Up]];
}
---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function MenuButton:OnClick()
	if self.command then
		self:GetParent()[self.command](self:GetParent(), self.data)
	end
end

function MenuButton:SpecialClick()
	self:OnClick()
end

function MenuButton:OnEnter()
	if not GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function MenuButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function MenuButton:SetCommand(text, command, data, handlers)
	self.data = data
	self.command = command
	self.Icon:SetTexture(COMMAND_OPT_ICON[command] or COMMAND_OPT_ICON.Default)
	self:SetAttribute('nohooks', true)
	self:SetScript('OnEnter', handlers and handlers.OnEnter or self.OnEnter)
	self:SetScript('OnLeave', handlers and handlers.OnLeave or self.OnLeave)
	self:SetText(text)
end

---------------------------------------------------------------
-- Shared popup action button
---------------------------------------------------------------
local MapActionButton = db:Register('PopupMenuMapActionButton', CreateFromMixins(CPIndexButtonMixin))

function MapActionButton:OnEnter()
	CPIndexButtonMixin.OnIndexButtonEnter(self)
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
	CPIndexButtonMixin.OnIndexButtonLeave(self)
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
	if self.bindingID then
		self:GetParent():ReportSetBinding(self, self.bindingID, self:GetID())
	end
end

function MapActionButton:OnClick(button)
	local actionID, bindingID = self:GetID(), self.bindingID;
	local isUnbound = not self:GetAttribute('slug');

	local parent = self:GetParent()
	if ( button == 'RightButton' ) then
		if not GetActionInfo(actionID) then
			parent:ReportClearBinding(bindingID)
		end
		PickupAction(actionID)
		self:Update()
		return ClearCursor()
	end
	ClearCursor()
	
	local spellID = parent:GetSpellID()
	PickupSpell(spellID)
	PlaceAction(actionID)
	self:Update()

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