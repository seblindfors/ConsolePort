local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local PET_ROW_INDEX = env.QMenuID();
---------------------------------------------------------------
local PetAction = Mixin({}, CPActionButtonMixin);
---------------------------------------------------------------

function PetAction:OnLoad()
	self:RegisterForClicks('AnyDown')
	self:SetSize(48, 48)

	env.QMenu:Hook(self, 'PostClick', [[
		if button == 'LeftButton' then
			owner::Disable()
		end
		self:::PostClick(button)
	]])
end

function PetAction:Init()
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	-- PetActionButtonTemplate inherits ActionButtonTemplate which provides
	-- many visual regions that conflict with the QMenu button style.
	for _, key in ipairs({
		'SlotBackground', 'SlotArt', 'IconMask',
		'Flash', 'Border', 'NewActionTexture', 'SpellHighlightTexture',
		'LevelLinkLockIcon', 'HotKey',
	}) do
		local region = self[key]
		if region then
			region:Hide()
			region:SetAlpha(0)
		end
	end

	for _, key in ipairs({'lossOfControlCooldown', 'chargeCooldown'}) do
		local frame = self[key];
		if frame then
			frame:Hide()
		end
	end

	-- Suppress pushed texture
	if self:GetPushedTexture() then
		self:GetPushedTexture():SetAlpha(0)
	end

	-- Restyle checked texture for active state indicator
	if self.GetCheckedTexture and self:GetCheckedTexture() then
		local checked = self:GetCheckedTexture()
		checked:SetBlendMode('ADD')
		CPAPI.SetAtlas(checked, 'UI-HUD-ActionBar-IconFrame-Mouseover')
		checked:SetSize(0, 0)
		checked:ClearAllPoints()
		checked:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
		checked:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 1, 0)
	end

	-- Restyle normal texture to match CPWorldButtonBaseTemplate
	local normalTexture = self:GetNormalTexture()
	if normalTexture then
		CPAPI.SetAtlas(normalTexture, 'UI-HUD-ActionBar-IconFrame')
		normalTexture:ClearAllPoints()
		normalTexture:SetPoint('TOPLEFT', -1, 1)
		normalTexture:SetPoint('BOTTOMRIGHT', 3, -2)
	end

	-- Restyle highlight texture
	local highlightTexture = self:GetHighlightTexture()
	if highlightTexture then
		highlightTexture:SetBlendMode('ADD')
		CPAPI.SetAtlas(highlightTexture, 'UI-HUD-ActionBar-IconFrame-Down')
		highlightTexture:ClearAllPoints()
		highlightTexture:SetPoint('TOPLEFT', 0, 0)
		highlightTexture:SetPoint('BOTTOMRIGHT', 1, -1)
	end

	-- Style icon to fill the button area
	if self.icon then
		self.icon:ClearAllPoints()
		self.icon:SetAllPoints()
		self.icon:SetDesaturated(true)
	end

	-- Restyle cooldown to match aura look
	if self.cooldown then
		self.cooldown:SetAllPoints(self)
		self.cooldown:SetSwipeColor(NORMAL_FONT_COLOR:GetRGBA())
		self.cooldown:SetSwipeTexture([[Interface\AddOns\ConsolePort_World\Assets\CooldownSwipe]])
        self.cooldown:SetUsingParentLevel(false)
		if CPAPI.IsRetailVersion then
			self.cooldown:SetDrawEdge(false)
		end
	end

	-- Scale up AutoCastOverlay to match 48x48 button
	if self.AutoCastOverlay then
        if CPAPI.IsRetailVersion then
		    self.AutoCastOverlay:SetPoint('TOPLEFT', self, 'TOPLEFT', -1, 1)
            self.AutoCastOverlay:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 1, -1)
        else
            self.AutoCastOverlay:SetPoint('TOPLEFT', self, 'TOPLEFT', 2, -2)
            self.AutoCastOverlay:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -2, 2)
            if self.AutoCastOverlay.Corners then
                self.AutoCastOverlay.Corners:Hide()
            end
        end
	end
    self:Update()
    self.Init = self.Update;
end

function PetAction:Update()
	local id = self:GetID()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(id)

	if not isToken then
		self:SetIcon(texture)
		self.tooltipName = name;
	else
		self:SetIcon(texture and _G[texture])
		self.tooltipName = name and _G[name];
	end
	self.isToken = isToken;
	self.spellID = spellID;
	self.isActive = isActive;
	self.autoCastAllowed = autoCastAllowed;
	self.autoCastEnabled = autoCastEnabled;

	if texture then
		if GetPetActionSlotUsable(id) then
			self.icon:SetVertexColor(1, 1, 1)
		else
			self.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	end

	self:SetChecked(isActive and true or false)

	if self.AutoCastOverlay then
		self.AutoCastOverlay:SetShown(autoCastAllowed)
		self.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
	end

	self:UpdateCooldown()
end

function PetAction:UpdateCooldown()
	local start, duration, enable = GetPetActionCooldown(self:GetID())
	CooldownFrame_Set(self.cooldown, start, duration, enable)
end

function PetAction:OnEnter()
	self:UpdateTooltip()
	self:LockHighlight()
end

function PetAction:UpdateTooltip()
	if not self.tooltipName then return end;
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetPetAction(self:GetID())
	local leftLabel = self.spellID and ('%s & %s'):format(USE, CLOSE)
		or self.isActive and CLOSE
		or ('%s & %s'):format(ACTIVATE, CLOSE);
	local hasAddedLine, text = false, env:GetTooltipPromptForClick('LeftButton', leftLabel)
	if text then
		hasAddedLine = true;
		GameTooltip:AddLine(text, 1, 1, 1)
	end
	if self.autoCastAllowed then
		local label = self.autoCastEnabled and DISABLE or ACTIVATE;
		text = env:GetTooltipPromptForClick('RightButton', label)
		if text then
			hasAddedLine = true;
			GameTooltip:AddLine(text, 1, 1, 1)
		end
	end
	if hasAddedLine then
		GameTooltip:Show()
	end
end

function PetAction:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

function PetAction:OnHide()
	if CPAPI.Scrub(GameTooltip:IsOwned(self)) then
		GameTooltip:Hide()
	end
end

function PetAction:PostClick(button)
	if GetPetActionInfo(self:GetID()) == 'PET_ACTION_MOVE_TO' then
		db.Mouse:SetFreeCursor()
	end
end

---------------------------------------------------------------
local PetRow = {
---------------------------------------------------------------
	Events  = {
		'PET_BAR_UPDATE_COOLDOWN';
		'PET_BAR_UPDATE';
		'PET_SPECIALIZATION_CHANGED';
		'PLAYER_CONTROL_GAINED';
		'PLAYER_CONTROL_LOST';
		'PLAYER_FARSIGHT_FOCUS_CHANGED';
	};
	PetEvents = {
		'UNIT_AURA';
		'UNIT_FLAGS';
	};
	PlayerEvents = {
		'UNIT_PET';
	};
};

function PetRow:OnLoad()
	local xOffset = tonumber(self:GetAttribute('xOffset')) or 0;
	local point   = self:GetAttribute('point') or 'TOPLEFT';

	-- Pre-create all 10 buttons so they exist before combat.
	self.buttons = {};
	for i = 1, NUM_PET_ACTION_SLOTS or 10 do
		local button = CreateFrame('CheckButton', '$parentPetSlot'..i, self, 'PetActionButtonTemplate')
		CPAPI.Specialize(button, PetAction)
		button:SetID(i)
		if i == 1 then
			button:SetPoint(point, self, point, 0, 0)
		else
			button:SetPoint(point, self.buttons[i - 1], point, xOffset, 0)
		end
		self.buttons[i] = button;
	end

	self:SetTitle(PET)
	self:UpdateState()
	db:RegisterSafeCallback('Settings/QMenuCollectionPet', self.UpdateState, self)
end

function PetRow:UpdateState()
	if db('QMenuCollectionPet') then
		local condition = '[pet] true; nil';
		RegisterStateDriver(self, 'pet', condition)
		self:SetShown(SecureCmdOptionParse(condition) == 'true')
		self:SetAttribute('_onstate-pet', [[
			if newstate then
				self:Show()
			else
				self:Hide()
			end
			self:GetParent():RunAttribute('UpdateLayout')
		]])
	else
		UnregisterStateDriver(self, 'pet')
		self:Hide()
	end
end

function PetRow:LayoutItems()
	return self.buttons;
end

function PetRow:UpdateButtons()
	for _, button in ipairs(self.buttons) do
		button:Update()
	end
end

function PetRow:UpdateCooldowns()
	for _, button in ipairs(self.buttons) do
		button:UpdateCooldown()
	end
end

function PetRow:OnShow()
    for _, button in ipairs(self.buttons) do
        button:Init()
    end
    CPAPI.RegisterFrameForEvents(self, self.Events)
	CPAPI.RegisterFrameForUnitEvents(self, self.PetEvents, 'pet')
	CPAPI.RegisterFrameForUnitEvents(self, self.PlayerEvents, 'player')
end

function PetRow:OnHide()
    self:UnregisterAllEvents()
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
PetRow.PET_BAR_UPDATE_COOLDOWN       = PetRow.UpdateCooldowns;
PetRow.PET_BAR_UPDATE                = PetRow.UpdateButtons;
PetRow.PET_BAR_UPDATE_USABLE         = PetRow.UpdateButtons;
PetRow.PET_SPECIALIZATION_CHANGED    = PetRow.UpdateButtons;
PetRow.PLAYER_CONTROL_GAINED         = PetRow.UpdateButtons;
PetRow.PLAYER_CONTROL_LOST           = PetRow.UpdateButtons;
PetRow.PLAYER_FARSIGHT_FOCUS_CHANGED = PetRow.UpdateButtons;
PetRow.UNIT_AURA                     = PetRow.UpdateButtons;
PetRow.UNIT_FLAGS                    = PetRow.UpdateButtons;
PetRow.UNIT_PET                      = PetRow.UpdateButtons;

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local header = CreateFrame('Frame', '$parentPet', QMenu, 'QMenuRow, SecureHandlerStateTemplate')
	CPAPI.Specialize(CPAPI.EventHandler(header), env.QMenuRow, PetRow)
	QMenu:AddFrame(header, PET_ROW_INDEX)
	header:Layout()
end)