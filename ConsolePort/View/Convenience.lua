---------------------------------------------------------------
-- Convenience UI modifications and hacks
---------------------------------------------------------------
local name, db = ...;

-- Popups:
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.
do  local popups, visible, oldNode = {}, {};
	for i=1, STATICPOPUP_NUMDIALOGS do
		popups[_G['StaticPopup'..i]] = _G['StaticPopup'..(i-1)] or false;
	end

	for popup, previous in pairs(popups) do
		popup:HookScript('OnShow', function(self)
			visible[self] = true;
			if not InCombatLockdown() then
				local prio = popups[previous];
				if not prio or ( not prio:IsVisible() ) then
					local current = db.Cursor:GetCurrentNode()
					-- assert not caching a return-to node on a popup
					if current and not popups[current:GetParent()] then
						oldNode = current;
					end
					db.Cursor:SetCurrentNode(self.button1)
				end
			end
		end)
		popup:HookScript('OnHide', function(self)
			visible[self] = nil;
			if not next(visible) and not InCombatLockdown() and oldNode then
				db.Cursor:SetCurrentNode(oldNode)
			end
		end)
	end
end

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

-- Map canvas:
-- Disable automatic cursor scrolling.
hooksecurefunc(MapCanvasScrollControllerMixin, 'OnLoad', function(self)
	self:SetAttribute('nodeignorescroll', true)
end)

if (WorldMapFrame and WorldMapFrame.ScrollContainer) then
	WorldMapFrame.ScrollContainer:SetAttribute('nodeignorescroll', true)
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
		frame:HookScript('OnGamePadButtonDown', GenerateClosure(MovieOnGamePadButtonDown, controls))
	end
end

-- Use color picker frame with sticks
if ColorPickerFrame then
	local delta, saturation, oldNode = 30, 1;

	local function ColorPickerStickToRGB(self, x, y, len)
		local radius, theta = CPAPI.XY2Polar(x, y)
		local deg = CPAPI.Rad2Deg(theta)
		local r, g, b = CPAPI.HSV2RGB(deg, radius, saturation)
		self:SetColorRGB(r, g, b)
	end

	local function ColorPickerStickSaturation(self, x, y, len)
		local r, g, b = self:GetColorRGB()
		saturation = Clamp(saturation + y / delta, 0, 1);
		-- Handle case where we're picking a shade of gray
		if (r == g and g == b) then
			self:SetColorRGB(saturation, saturation, saturation)
		end
	end

	local function OpacitySliderStickValue(self, x, y, len)
		local opacityDelta = -x / delta;
		local a = self:GetValue()
		self:SetValue(a + opacityDelta)
	end

	ColorPickerFrame:EnableGamePadStick(true)
	ColorPickerFrame:SetScript('OnGamePadStick', function(self, stick, x, y, len)
		if ( stick == 'Left' ) then
			ColorPickerStickToRGB(self, x, y, len)
		elseif ( stick == 'Right' and len > .1 ) then
			if (math.abs(x) > math.abs(y) and OpacitySliderFrame and OpacitySliderFrame:IsShown()) then
				OpacitySliderStickValue(OpacitySliderFrame, x, y, len)
			else
				ColorPickerStickSaturation(self, x, y, len)
			end
		end
	end)
	ColorPickerFrame:HookScript('OnShow', function()
		oldNode = db.Cursor:GetCurrentNode()
		db.Cursor:SetCurrentNodeIfActive(ColorPickerOkayButton, true)
	end)
	ColorPickerFrame:HookScript('OnHide', function()
		if oldNode then
			db.Cursor:SetCurrentNode(oldNode)
			oldNode = nil;
		end
	end)
end

-- Loads the keyboard
local function TryLoadKeyboardUI()
	if not db('keyboardEnable') or IsAddOnLoaded('ConsolePort_Keyboard') then
		return
	end
	local loaded, reason = LoadAddOn('ConsolePort_Keyboard')
	if not loaded then
		CPAPI.Log('Failed to load radial keyboard. Reason: %s', _G['ADDON_'..reason])
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
	TryLoadKeyboardUI()
end

db:RegisterCallback('Settings/keyboardEnable', TryLoadKeyboardUI, Handler)

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