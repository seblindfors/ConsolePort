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

function MenuButton:SetCommand(text, command, data)
	self.data = data
	self.command = command
	self.Icon:SetTexture(COMMAND_OPT_ICON[command] or COMMAND_OPT_ICON.Default)
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
end

function MapActionButton:OnClick(button)
	if ( button == 'RightButton' ) then
		PickupAction(self:GetID())
		self:Update()
		return ClearCursor()
	end

	local parent = self:GetParent()
	local spellID = parent:GetSpellID()
	PickupSpell(spellID)
	PlaceAction(self:GetID())
	self:Update()

	local type, _, _, cursorSpellID = GetCursorInfo()
	if ( type == 'spell' and cursorSpellID ~= spellID ) then
		parent:SetSpellID(cursorSpellID)
		parent:MapActionBar()
	else
		parent:Hide()
	end
	ClearCursor()
end