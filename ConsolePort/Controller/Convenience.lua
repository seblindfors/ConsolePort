---------------------------------------------------------------
-- Convenience UI modifications and hacks
---------------------------------------------------------------
local name, db, L = ...; L = db.Locale;

-- Remove the need to type 'DELETE' when removing rare or better quality items
do  local DELETE_ITEM = CopyTable(StaticPopupDialogs.DELETE_ITEM);
	DELETE_ITEM.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_ITEM = DELETE_ITEM;

	local DELETE_QUEST = CopyTable(StaticPopupDialogs.DELETE_QUEST_ITEM);
	DELETE_QUEST.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_QUEST_ITEM = DELETE_QUEST;
end

-- Add reload option to addon action forbidden
do local popup = StaticPopupDialogs.ADDON_ACTION_FORBIDDEN;
	popup.button3 = 'Reload';
	popup.OnAlt = ReloadUI;
end

-- Remove experimental cvar confirmation:
-- This event shows an annoying popup on login/modifications to things
-- like the action camera settings.
UIParent:UnregisterEvent('EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED')

-- Cancel cinematics
do local MovieControls = {
		[MovieFrame] = {
			PAD1 = MovieFrame.CloseDialog.ResumeButton;
			PAD2 = MovieFrame.CloseDialog.ConfirmButton;
		};
		[CinematicFrame] = {
			PAD1 = CinematicFrameCloseDialogResumeButton;
			PAD2 = CinematicFrameCloseDialogConfirmButton;
		};
	};

	local function MovieOnGamePadButtonDown(controls, self, button)
		controls.PAD1:SetText(('%s %s'):format(GetBindingText('PAD1', '_ABBR'), NO))
		controls.PAD2:SetText(('%s %s'):format(GetBindingText('PAD2', '_ABBR'), YES))

		local binding = GetBindingFromClick(button)
		if controls[button] then
			controls[button]:Click()
		elseif ( binding == 'SCREENSHOT' or binding == 'TOGGLEMUSIC' or binding == 'TOGGLESOUND' ) then
			self:SetPropagateKeyboardInput(true)
		else
			(self.CloseDialog or self.closeDialog):Show()
		end
	end

	for frame, controls in pairs(MovieControls) do
		if frame then
			frame:HookScript('OnGamePadButtonDown', GenerateClosure(MovieOnGamePadButtonDown, controls))
		end
	end
end

-- Use color picker frame with sticks
if ColorPickerFrame then
	local controls = {
		PAD1 = ColorPickerOkayButton;
		PAD2 = ColorPickerCancelButton;
	};
	local tooltipLines = {
		PADLSTICKUP    = CreateColor(CPAPI.HSV2RGB(270, 0.5, 1)):WrapTextInColorCode(L'Purple');
		PADLSTICKDOWN  = CreateColor(CPAPI.HSV2RGB(090, 0.5, 1)):WrapTextInColorCode(L'Green');
		PADLSTICKLEFT  = CreateColor(CPAPI.HSV2RGB(000, 0.5, 1)):WrapTextInColorCode(L'Red');
		PADLSTICKRIGHT = CreateColor(CPAPI.HSV2RGB(180, 0.5, 1)):WrapTextInColorCode(L'Cyan');
		PADRSTICKUP    = L'Increase lightness';
		PADRSTICKDOWN  = L'Decrease lightness';
		PADRSTICKLEFT  = L'Decrease opacity';
		PADRSTICKRIGHT = L'Increase opacity';
	}
	for button, control in pairs(controls) do
		control:SetText(('%s %s'):format(GetBindingText(button, '_ABBR'), control:GetText()))
	end

	-- Handle color change
	local delta, lightness, oldNode = 40, 1;

	local function ColorPickerStickToRGB(self, x, y)
		local radius, theta = CPAPI.XY2Polar(x, y)
		local deg = CPAPI.Rad2Deg(theta)
		local r, g, b = CPAPI.HSV2RGB(deg, radius, lightness)
		self:SetColorRGB(r, g, b)
	end

	local function ColorPickerStickSaturation(self, y)
		local r, g, b = self:GetColorRGB()
		lightness = Clamp(lightness + y / delta, 0, 1);
		-- Handle case where we're picking a shade of gray
		if (r == g and g == b) then
			self:SetColorRGB(lightness, lightness, lightness)
		end
	end

	local function OpacitySliderStickValue(self, x)
		local opacityDelta = -x / delta;
		local a = self:GetValue()
		self:SetValue(a + opacityDelta)
	end

	-- Scripts
	ColorPickerFrame:SetScript('OnGamePadStick', function(self, stick, x, y, len)
		if ( stick == 'Left' ) then
			ColorPickerStickToRGB(self, x, y)
		elseif ( stick == 'Right' and len > .1 ) then
			if (math.abs(x) > math.abs(y) and OpacitySliderFrame and OpacitySliderFrame:IsShown()) then
				OpacitySliderStickValue(OpacitySliderFrame, x)
			else
				ColorPickerStickSaturation(self, y)
			end
		end
	end)
	ColorPickerFrame:SetScript('OnGamePadButtonDown', function(self, button)
		if controls[button] then
			controls[button]:Click()
		end
	end)
	ColorPickerFrame:HookScript('OnShow', function(self)
		oldNode = ConsolePort:GetCursorNode()
		ConsolePort:SetCursorNodeIfActive(ColorPickerOkayButton, true)

		local device = db('Gamepad/Active')
		if device then
			GameTooltip:SetOwner(self, 'ANCHOR_NONE')
			GameTooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT')
			GameTooltip:SetText(COLOR_PICKER)
			for button, line in db.table.spairs(tooltipLines) do
				GameTooltip:AddLine(device:GetTooltipButtonPrompt(button, line))
			end
		end
	end)
	ColorPickerFrame:HookScript('OnHide', function(self)
		if oldNode then
			ConsolePort:SetCursorNode(oldNode)
			oldNode = nil;
		end
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
end

-- Loads and disables extra modules
local OnDemandModules, TryLoadModule = {
	ConsolePort_Keyboard = 'keyboardEnable';
	ConsolePort_Cursor   = 'UIenableCursor';
}; do local EnableAddOn = EnableAddOn;
	
	function TryLoadModule(predicate, module)
		if not db(predicate) or IsAddOnLoaded(module) then
			return
		end
		EnableAddOn(module)
		local loaded, reason = LoadAddOn(module)
		if not loaded then
			CPAPI.Log('Failed to load %s. Reason: %s\nPlease check your installation.', (module:gsub('_', ' ')), _G['ADDON_'..reason])
		end
	end

	-- Automatically load modules when they are enabled through the addon list
	local function OnEnableAddOn(module)
		local name = GetAddOnInfo(module)
		local var  = name and OnDemandModules[name];
		if ( name and var ) then
			db('Settings/'..var, true)
			TryLoadModule(var, name)
		end
	end

	-- Automatically disable predicate variable when a module is disabled through the addon list
	local function OnDisableAddOn(module)
		local name = GetAddOnInfo(module)
		local var  = name and OnDemandModules[name];
		if ( var ) then
			db('Settings/'..var, false)
		end
	end

	if C_AddOns and C_AddOns.EnableAddOn  then hooksecurefunc(C_AddOns, 'EnableAddOn',  OnEnableAddOn)  end
	if C_AddOns and C_AddOns.DisableAddOn then hooksecurefunc(C_AddOns, 'DisableAddOn', OnDisableAddOn) end
	if EnableAddOn  then hooksecurefunc('EnableAddOn',  OnEnableAddOn)  end
	if DisableAddOn then hooksecurefunc('DisableAddOn', OnDisableAddOn) end
end

---------------------------------------------------------------
-- Convenience handler
---------------------------------------------------------------
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentConvenienceHandler', ConsolePort}, {
	'MERCHANT_SHOW';
	'MERCHANT_CLOSED';
	'BAG_UPDATE_DELAYED';
	'QUEST_AUTOCOMPLETE';
	'ADDON_ACTION_FORBIDDEN';
}, {
	SellJunkHelper = function(item)
		if (C_Item.GetItemQuality(item) == Enum.ItemQuality.Poor) then
			CPAPI.UseContainerItem(item:GetBagAndSlot())
		end
	end;
})

function Handler:MERCHANT_CLOSED()
	CPAPI.IsMerchantAvailable = nil;
end

function Handler:MERCHANT_SHOW()
	CPAPI.IsMerchantAvailable = true;
	if db('autoSellJunk') then
		CPAPI.IteratePlayerInventory(self.SellJunkHelper)
	end
end

function Handler:BAG_UPDATE_DELAYED()
	-- repeat attempt to auto-sell junk to handle server throttling
	if CPAPI.IsMerchantAvailable then
		self:MERCHANT_SHOW()
	end
end

function Handler:QUEST_AUTOCOMPLETE(...)
	-- automatically show autocomplete quests
	ShowQuestComplete(...)
end

function Handler:OnDataLoaded()
	for module, predicate in pairs(OnDemandModules) do
		TryLoadModule(predicate, module)
	end
end

db:RegisterCallback('Settings/keyboardEnable', GenerateClosure(TryLoadModule, 'keyboardEnable', 'ConsolePort_Keyboard'))
db:RegisterCallback('Settings/UIenableCursor', GenerateClosure(TryLoadModule, 'UIenableCursor', 'ConsolePort_Cursor'))

-- Replace popup messages for forbidden actions which cannot be fixed by the addon
do local ForbiddenActions = {
		['FocusUnit()'] = ([[
			While the interface cursor is active, focus cannot reliably be set from unit dropdown menus.

			Please use another method to set focus, such as the %s binding, a /focus macro or the raid cursor.
		]]):format(BLUE_FONT_COLOR:WrapTextInColorCode(BINDING_NAME_FOCUSTARGET));
		['ClearFocus()'] = ([[
			While the interface cursor is active, focus cannot reliably be cleared from unit dropdown menus.

			Please use another method to clear focus, such as the %s binding, a /focus macro or the raid cursor.
		]]):format(BLUE_FONT_COLOR:WrapTextInColorCode(BINDING_NAME_FOCUSTARGET));
		['CastSpellByID()'] = [[
			While the interface cursor is active, a few actions are not possible to perform reliably.
			It appears you tried to cast a spell from a source that has been tainted by the
			interface cursor.

			Please use another method to cast this spell, such as using a macro or your action bars.
		]];
	};

	function Handler:ADDON_ACTION_FORBIDDEN(addOnName, func)
		if ( addOnName == name and ForbiddenActions[func] ) then
			local message = CPAPI.FormatLongText(db.Locale(ForbiddenActions[func]))
			local popup = StaticPopup_FindVisible('ADDON_ACTION_FORBIDDEN')
			if popup then
				_G[popup:GetName()..'Text']:SetText(message)
				popup.button1:SetEnabled(false)
				StaticPopup_Resize(popup, 'ADDON_ACTION_FORBIDDEN')
			end
		end
	end
end