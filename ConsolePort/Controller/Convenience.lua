---------------------------------------------------------------
-- Convenience UI modifications and hacks
---------------------------------------------------------------
local _, db, L = ...; L = db.Locale;

-- Remove the need to type 'DELETE' when removing rare or better quality items
do  local DELETE_ITEM = CopyTable(StaticPopupDialogs.DELETE_ITEM);
	DELETE_ITEM.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_ITEM = DELETE_ITEM;

	local DELETE_QUEST_ITEM = CopyTable(StaticPopupDialogs.DELETE_QUEST_ITEM);
	DELETE_QUEST_ITEM.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_QUEST_ITEM = DELETE_QUEST_ITEM;
end

-- Add reload option to addon action forbidden
do local ADDON_ACTION_FORBIDDEN = StaticPopupDialogs.ADDON_ACTION_FORBIDDEN;
	ADDON_ACTION_FORBIDDEN.button3 = L'Reload';
	ADDON_ACTION_FORBIDDEN.OnAlt = ReloadUI;
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
	local OkayButton   = ColorPickerOkayButton or ColorPickerFrame.Footer.OkayButton;
	local CancelButton = ColorPickerCancelButton or ColorPickerFrame.Footer.CancelButton;

	local controls = {
		PAD1 = OkayButton;
		PAD2 = CancelButton;
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
	local delta, lightness, opacityInversion, oldNode = 40, 1, ColorPickerFrameMixin and 1 or -1;

	local SetColorRGB, GetColorRGB, SetOpacity, GetOpacity;
	if ColorPickerFrame.Content then
		SetColorRGB = GenerateClosure(ColorPickerFrame.Content.ColorPicker.SetColorRGB,   ColorPickerFrame.Content.ColorPicker)
		GetColorRGB = GenerateClosure(ColorPickerFrame.Content.ColorPicker.GetColorRGB,   ColorPickerFrame.Content.ColorPicker)
		SetOpacity  = GenerateClosure(ColorPickerFrame.Content.ColorPicker.SetColorAlpha, ColorPickerFrame.Content.ColorPicker)
		GetOpacity  = GenerateClosure(ColorPickerFrame.Content.ColorPicker.GetColorAlpha, ColorPickerFrame.Content.ColorPicker)
	else
		SetColorRGB = GenerateClosure(ColorPickerFrame.SetColorRGB, ColorPickerFrame)
		GetColorRGB = GenerateClosure(ColorPickerFrame.GetColorRGB, ColorPickerFrame)
		SetOpacity  = GenerateClosure(OpacitySliderFrame.SetValue,  OpacitySliderFrame)
		GetOpacity  = GenerateClosure(OpacitySliderFrame.GetValue,  OpacitySliderFrame)
	end


	local function ColorPickerStickToRGB(x, y)
		local radius, theta = CPAPI.XY2Polar(x, y)
		local deg = CPAPI.Rad2Deg(theta)
		local r, g, b = CPAPI.HSV2RGB(deg, radius, lightness)
		SetColorRGB(r, g, b)
	end

	local function ColorPickerStickSaturation(y)
		local r, g, b = GetColorRGB()
		lightness = Clamp(lightness + y / delta, 0, 1);
		-- Handle case where we're picking a shade of gray
		if (r == g and g == b) then
			SetColorRGB(lightness, lightness, lightness)
		end
	end

	local function OpacitySliderStickValue(x)
		local opacityDelta = x * opacityInversion / delta;
		local a = GetOpacity()
		SetOpacity(a + opacityDelta)
	end

	-- Scripts
	ColorPickerFrame:SetScript('OnGamePadStick', function(self, stick, x, y, len)
		if ( stick == 'Left' ) then
			ColorPickerStickToRGB(x, y)
		elseif ( stick == 'Right' and len > .1 ) then
			if (math.abs(x) > math.abs(y)) then
				OpacitySliderStickValue(x)
			else
				ColorPickerStickSaturation(y)
			end
		end
	end)
	ColorPickerFrame:SetScript('OnGamePadButtonDown', function(self, button)
		if controls[button] then
			controls[button]:Click()
		end
	end)
	ColorPickerFrame:HookScript('OnShow', function(self)
		db.Radial:ToggleFocusFrame(self, true)
		oldNode = ConsolePort:GetCursorNode()
		ConsolePort:SetCursorNodeIfActive(OkayButton, true)

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
		db.Radial:ToggleFocusFrame(self, false)
		if oldNode then
			ConsolePort:SetCursorNode(oldNode)
			oldNode = nil;
		end
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
end

-- Loads extra modules
local OnDemandModules, TryLoadModule = {
	ConsolePort_Keyboard = 'keyboardEnable';
	ConsolePort_Cursor   = 'UIenableCursor';
}; do local RawEnableAddOn = CPAPI.EnableAddOn;

	function TryLoadModule(predicate, module)
		if not db(predicate) or CPAPI.IsAddOnLoaded(module) then
			return
		end
		RawEnableAddOn(module)
		local loaded, reason = CPAPI.LoadAddOn(module)
		if not loaded then
			CPAPI.Log('Failed to load %s. Reason: %s\nPlease check your installation.', (module:gsub('_', ' ')), _G['ADDON_'..reason])
		end
	end

	-- Automatically load modules when they are enabled through the addon list
	local function OnEnableAddOn(module)
		local name = CPAPI.GetAddOnInfo(module)
		local var  = name and OnDemandModules[name];
		if ( name and var ) then
			db('Settings/'..var, true)
			TryLoadModule(var, name)
		end
	end

	-- NOTE: Hook enable but NOT disable. People will commonly disable all
	-- modules one by one when they really want to turn the main addon off,
	-- and this gets picked up and falsely interpreted as them wanting to
	-- disable a specific module. It is what it is.
	if C_AddOns and C_AddOns.EnableAddOn then
		hooksecurefunc(C_AddOns, 'EnableAddOn', OnEnableAddOn)
	end
	if EnableAddOn then
		hooksecurefunc('EnableAddOn', OnEnableAddOn)
	end
end

---------------------------------------------------------------
-- Convenience handler
---------------------------------------------------------------
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentConvenienceHandler', ConsolePort}, {
	'MERCHANT_SHOW';
	'MERCHANT_CLOSED';
	'BAG_UPDATE_DELAYED';
	'QUEST_AUTOCOMPLETE';
	'TRADE_SHOW';
	'TRADE_CLOSED';
})

Handler.SellJunkHelper = function(item)
	local isUnlimited  = Handler.autoSellUnlimited;
	local isJunkItem   = CPAPI.GetItemQuality(item) == Enum.ItemQuality.Poor;
	local isEquippable = CPAPI.IsEquippableItem(CPAPI.GetItemLink(item))

	if isJunkItem and (isUnlimited or not isEquippable) then
		CPAPI.UseContainerItem(item:GetBagAndSlot())
	end
end

function Handler:MERCHANT_CLOSED()
	CPAPI.IsMerchantAvailable = nil;
end

function Handler:MERCHANT_SHOW()
	CPAPI.IsMerchantAvailable = true;
	if db('autoSellJunk') then
		self.autoSellUnlimited = UnitLevel('player') >= db('autoSellJunkLevelLimit');
		CPAPI.IteratePlayerInventory(self.SellJunkHelper)
	end
end

function Handler:TRADE_SHOW()
	CPAPI.IsTradeAvailable = true;
end

function Handler:TRADE_CLOSED()
	CPAPI.IsTradeAvailable = nil;
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