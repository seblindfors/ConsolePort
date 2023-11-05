local _, env = ...; local db, L = env.db, env.L;
local DEFAULT_BINDINGS, ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 0, 1, 2;
local LEFT_PANEL_WIDTH, MAPPER_WIDTH, CONTROL_BUTTON_WIDTH, CONTROL_HEIGHT = 360, 340, 112, 140;
local BindingsPanel = {}
---------------------------------------------------------------
-- Main frame
---------------------------------------------------------------
function BindingsPanel:OnShow()
	self.container:OnContainerSizeChanged()
	self:SnapshotBindings()
end

function BindingsPanel:OnActiveDeviceChanged(device)
	self.device = device;
end

function BindingsPanel:Validate()
	if self.snapshot and not db.table.compare(self.snapshot, db.Gamepad:GetBindings()) then
		self:WipeSnapshot()
		return false, self.SaveBindings, self.ResetBindingsOnClose;
	end
	return true
end

function BindingsPanel:LoadBindings(set)
	LoadBindings(set)
	SaveBindings(set)
	return self:SnapshotBindings()
end

function BindingsPanel:SaveBindings()
	local set = GetCurrentBindingSet()
	SaveBindings(set)
	if (set == CHARACTER_BINDINGS) then
		CPAPI.Log('Your gamepad bindings for %s have been saved.', CPAPI.GetPlayerName(true))
	else
		CPAPI.Log('Your gamepad bindings have been saved.')
	end
	return set, self:SnapshotBindings();
end

function BindingsPanel:ResetBindings()
	self:LoadBindings(GetCurrentBindingSet())
end

function BindingsPanel:ResetBindingsOnClose()
	self:ResetBindings()
	self:WipeSnapshot()
end

function BindingsPanel:SnapshotBindings()
	self.snapshot = db.Gamepad:GetBindings()
	return self.snapshot;
end

function BindingsPanel:WipeSnapshot()
	self.snapshot = nil;
end

---------------------------------------------------------------
-- State
---------------------------------------------------------------
BindingsPanel.State = {
	Loadout = {
		Combinations   = true;
		Shortcuts      = false;
		Mapper         = false;
	};
	Mapper = {
		Combinations   = false;
		Shortcuts      = false;
		Mapper         = true;
	};
	Categories = {
		Combinations   = false;
		Shortcuts      = true;
		Mapper         = false;
	};
}

function BindingsPanel:SetState(state)
	state = state or self.State.Categories;

	-- Handle going from mapper state to mapper state, we don't want that.
	self.StatePrev = (self.StateCurr ~= self.State.Mapper and self.StateCurr) or self.State.Categories;
	self.StateCurr = state;

	self.Mapper:ToggleFlex(state.Mapper)
	self.Control:ToggleFlex(state.Shortcuts)
	self.Shortcuts:ToggleFlex(state.Shortcuts)
	self.ComboShortcuts:ToggleFlex(state.Combinations)
	self.Flexer:ToggleFlex(state.Combinations)
	self.Flexer:SetChecked(state.Combinations)
	self.Flexer:FlyoutPopoutButtonSetReversed(state.Combinations)
end

function BindingsPanel:NotifyComboFocus(id, name, fraction)
	local combo = self.Combinations:GetWidgetByID(id, name)
	if fraction then
		self.Combinations:ScrollToOffset(fraction)
	end
end

function BindingsPanel:NotifyBindingFocus(widget, show, hideShortcuts)
	self.Mapper:ToggleWidget(widget, show)
end

function BindingsPanel:RefreshHeader()
	local ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 1, 2;
	local header = self.Control.Header;
	if not header then return end
	local isCharacterBindings = (GetCurrentBindingSet() == CHARACTER_BINDINGS)

	header.PortraitMask:SetShown(isCharacterBindings)
	header.Portrait:SetShown(isCharacterBindings)
	header.Button:SetShown(isCharacterBindings)

	if (isCharacterBindings) then
		local texture, coords = CPAPI.GetWebClassIcon()
		header.Button:SetTexture(texture)
		header.Button:SetTexCoord(unpack(coords))
		header.Button:SetSize(24, 24)

		SetPortraitTexture(header.Portrait, 'player')
		header.Text:SetText(CHARACTER_KEY_BINDINGS:format(CPAPI.GetPlayerName(true)))
	else
		header.Text:SetText(KEY_BINDINGS)
	end
end

---------------------------------------------------------------
-- Category shortcuts
---------------------------------------------------------------
local Shortcuts = {};

function Shortcuts:OnLoad()
	Mixin(self, env.FlexibleMixin, env.SettingShortcutsMixin)
	env.SettingShortcutsMixin.OnLoad(self)
	self.Child:SetMeasurementOrigin(self, self.Child, LEFT_PANEL_WIDTH, 8)
	self:SetFlexibleElement(self, LEFT_PANEL_WIDTH)
	self:SetScript('OnHide', nop)
end

function Shortcuts:Update()
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Binding button in mapper
---------------------------------------------------------------
local MapperBindingButton = {};

function MapperBindingButton:OnLoad()
	local label = self:GetFontString()
	local font, _, outline = label:GetFont()
	label:SetFont(font, 14, outline)
end

function MapperBindingButton:OnClick(button)
	local mapper = self:GetParent():GetParent();
	if (button == 'LeftButton') then
		mapper:SetCatchButton(true);
	elseif (button == 'RightButton') then
		mapper:ClearBinding();
		self.Slug:SetText(WrapTextInColorCode(NOT_BOUND, 'FF757575'))
		self:Uncheck()
	end
end

function MapperBindingButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetText(KEY_BINDING)
	if ConsolePort:IsCursorNode(self) then
		local leftClick = env:GetTooltipPromptForClick('LeftClick', CHOOSE)
		local rightClick = env:GetTooltipPromptForClick('RightClick', REMOVE)
		local specialClick = env:GetTooltipPromptForClick('Special', CLOSE)
		if leftClick then
			GameTooltip:AddLine(leftClick)
		end if rightClick then
			GameTooltip:AddLine(rightClick)
		end if specialClick then
			GameTooltip:AddLine(specialClick)
		end
	end
	GameTooltip:AddLine(('%s %s'):format(CreateAtlasMarkup('NPE_LeftClick', 24, 24), CHOOSE))
	GameTooltip:AddLine(('%s %s'):format(CreateAtlasMarkup('NPE_RightClick', 24, 24), REMOVE))
	GameTooltip:Show()
end

function MapperBindingButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function MapperBindingButton:OnDisable()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

MapperBindingButton.OnHide = CPIndexButtonMixin.Uncheck;

---------------------------------------------------------------
-- Setting up
---------------------------------------------------------------
function BindingsPanel:OnFirstShow()
	local function FlyoutPopoutButtonSetReversed(self, isReversed)
		if ( self:GetParent().verticalFlyout ) then
			if ( isReversed ) then
				self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0, 0.5);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 0.5, 1);
			else
				self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			end
		else
			if ( isReversed ) then
				self:GetNormalTexture():SetTexCoord(0.15625, 0, 0.84375, 0, 0.15625, 0.5, 0.84375, 0.5);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 1, 0.84375, 1);
			else
				self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
				self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			end
		end
	end

	-- Define in advance so they can be referenced
	local shortcuts, mapper;

	local comboShortcuts = self:CreateScrollableColumn('ComboShortcuts', {
		_Mixin  = env.ComboShortcutsMixin;
		_Width  = 0.01;
		_SetDelta = 60;
		_IgnoreNode = true;
		_Points = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
	})

	local combos = self:CreateScrollableColumn('Combinations', {
		_Mixin  = env.CombosMixin;
		_Width  = 0.01;
		_SetDelta = 60;
		_IgnoreNode = true;
		_Points = {
			{'TOPLEFT', comboShortcuts, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', comboShortcuts, 'BOTTOMRIGHT', 0, 0};
		};
	})

	local flexer = LibStub('Carpenter'):BuildFrame(self, {
		Flexer = {
			_Type = 'CheckButton';
			_Setup = 'BackdropTemplate';
			_Mixin = env.FlexibleMixin;
			_Width = 24;
			_Points = {
				{'TOPLEFT', 'parent.Combinations', 'TOPRIGHT', 0, 0};
				{'BOTTOMLEFT', 'parent.Combinations', 'BOTTOMRIGHT', 0, 0};
			};
			_Backdrop = CPAPI.Backdrops.Opaque;
			_SetBackdropBorderColor = {0.15, 0.15, 0.15, 1};
			_SetNormalTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
			_SetHighlightTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
			['state'] = false;
			_OnLoad = function(self)
				local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
				self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
				CPAPI.SetGradient(self.Center, 'HORIZONTAL', r*2, g*2, b*2, 1, r/1.25, g/1.25, b/1.25, 1)
				local normal = self:GetNormalTexture()
				local hilite = self:GetHighlightTexture()
				normal:ClearAllPoints()
				normal:SetPoint('CENTER', -1, 0)
				normal:SetSize(16, 32)
				hilite:ClearAllPoints()
				hilite:SetPoint('CENTER', -1, 0)
				hilite:SetSize(16, 32)
				self.FlyoutPopoutButtonSetReversed = FlyoutPopoutButtonSetReversed;
				self:FlyoutPopoutButtonSetReversed(false)
				self:SetFlexibleElement(combos, combos.Child)
			end;
			_OnClick = function(self)
				local enabled = self:GetChecked()
				if enabled then
					env.Bindings:NotifyBindingFocus(nil)
				end
				env.Bindings:SetState(enabled and env.Bindings.State.Loadout or env.Bindings.State.Categories)
			end;
		};
	}, false, true).Flexer;

	local control = LibStub:GetLibrary('Carpenter'):BuildFrame(self, {
		Control = {
			_Type = 'Frame';
			_Setup = 'BackdropTemplate';
			_Backdrop = CPAPI.Backdrops.Opaque;
			_Mixin = env.FlexibleMixin;
			_Width = LEFT_PANEL_WIDTH;
			_Points = {
				{'TOPLEFT', flexer, 'TOPRIGHT', 0, 0};
				{'BOTTOMLEFT', flexer, 'TOPRIGHT', 0, -CONTROL_HEIGHT};
			};
			_OnLoad = function(self)
				env.OpaqueMixin.OnLoad(self)
				self:SetFlexibleElement(self, LEFT_PANEL_WIDTH)
				self:SetClipsChildren(true)
			end;
			{
				Header = {
					_Type = 'Frame';
					_Setup = 'CPConfigIconHeaderTemplate';
					_Point = {'TOP', 0, -12};
				};
				Mode = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'TOPLEFT', 8, -64};
					_Size  = {40, 40};
					_Events = {'UPDATE_BINDINGS'};
					_SetDrawOutline = true;
					_SetNormalTexture = [[Interface\Buttons\UI-PAIDCHARACTERCUSTOMIZATION-BUTTON]];
					_SetHighlightTexture = [[Interface\Buttons\UI-PAIDCHARACTERCUSTOMIZATION-BUTTON]];
					TooltipHeader = CHARACTER_SPECIFIC_KEYBINDINGS;
					TooltipText = CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP;
					Update = function(self)
						self:SetChecked(GetCurrentBindingSet() == CHARACTER_BINDINGS)
						self:OnChecked(self:GetChecked())
						env.Bindings:RefreshHeader()
					end;
					_OnShow = function(self)
						self:Update()
					end;
					_OnEvent = function(self)
						self:Update()
					end;
					_OnClick = function(self)
						SaveBindings(GetCurrentBindingSet())
						env.Bindings:LoadBindings(self:GetChecked() and CHARACTER_BINDINGS or ACCOUNT_BINDINGS)
						self:Update()
					end;
					_OnLoad = function(self)
						local normal = self:GetNormalTexture()
						local hilite = self:GetHighlightTexture()
						normal:SetTexCoord(76/128, 116/128, 12/128, 52/128)
						hilite:SetTexCoord(76/128, 116/128, 12/128, 52/128)
						normal:ClearAllPoints()
						hilite:ClearAllPoints()
						normal:SetPoint('CENTER')
						hilite:SetPoint('CENTER')
						normal:SetSize(36, 36)
						hilite:SetSize(36, 36)
					end;
				};
				Import = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Size  = {40, 40};
					_Point = {'LEFT', '$parent.Mode', 'RIGHT', 0, 0};
					_SetDrawOutline = true;
					_SetNormalTexture = CPAPI.GetAsset[[Textures\Frame\Import]];
					_SetHighlightTexture = CPAPI.GetAsset[[Textures\Frame\Import]];
					TooltipHeader = L'Import';
					TooltipText = L'Import bindings from a preset or another character.';
					_OnLoad = function(self)
						local normal, hilite = self:GetNormalTexture(), self:GetHighlightTexture()
						normal:ClearAllPoints()
						hilite:ClearAllPoints()
						normal:SetPoint('CENTER')
						hilite:SetPoint('CENTER')
						normal:SetSize(32, 32)
						hilite:SetSize(32, 32)
						normal:SetVertexColor(105/255, 204/255, 240/255)
						hilite:SetVertexColor(105/255, 204/255, 240/255)
					end;
					_OnClick = function()
						local state = not self.Import:IsShown()
						self.Shortcuts:SetShown(not state)
						self.Import:SetShown(state)
						self.Control.Footer:SetText(state and L'Profiles' or CATEGORIES)
						self.Control.Footer:Play()
						flexer:SetEnabled(not state)
						flexer:GetNormalTexture():SetDesaturated(state)
					end;
				};
				Reset = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Import', 'RIGHT', 0, 0};
					_Size  = {40, 40};
					_SetDrawOutline = true;
					_SetNormalTexture = [[Interface\Buttons\UIFrameButtons]];
					_SetHighlightTexture = [[Interface\Buttons\UIFrameButtons]];
					TooltipHeader = DEFAULTS;
					TooltipText = L'Reset all bindings to defaults.';
					_OnLoad = function(self)
						local normal = self:GetNormalTexture()
						local hilite = self:GetHighlightTexture()
						CPAPI.SetAtlas(normal, 'reset-button')
						CPAPI.SetAtlas(hilite, 'reset-button')
						normal:ClearAllPoints()
						hilite:ClearAllPoints()
						normal:SetPoint('CENTER')
						hilite:SetPoint('CENTER')
						normal:SetSize(32, 32)
						hilite:SetSize(32, 32)
					end;
					_OnClick = function(self)
						CPAPI.Popup('ConsolePort_Reset_Keybindings', {
							text = CONFIRM_RESET_KEYBINDINGS;
							button1 = OKAY;
							button2 = CANCEL;
							timeout = 0;
							whileDead = 1;
							showAlert = 1;
							OnHide = function()
								self:SetChecked(false)
								self:OnChecked(self:GetChecked())
							end;
							OnAccept = function()
								db('Gamepad')
									:GetActiveDevice()
									:ApplyPresetBindings()
							end;
						})
					end;
				};
				Save = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Reset', 'RIGHT', 0, 0};
					_Text  = SAVE;
					_Size  = {CONTROL_BUTTON_WIDTH, 40};
					_SetDrawOutline = true;
					_OnClick = function(self)
						self:SetChecked(false)
						self:OnChecked(self:GetChecked())
						env.Bindings:SaveBindings()
					end;
				};
				Cancel = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Save', 'RIGHT', 0, 0};
					_Size  = {CONTROL_BUTTON_WIDTH, 40};
					_Text  = CANCEL;
					_SetDrawOutline = true;
					TooltipHeader = CANCEL;
					TooltipText = L'Discard any changes and revert to the previous configuration.';
					_OnClick = function(self)
						CPAPI.Popup('ConsolePort_Previous_Keybindings', {
							text = CONFIRM_RESET_TO_PREVIOUS_KEYBINDINGS or L'Do you want to reset all keybindings to their previous configurations?';
							button1 = OKAY;
							button2 = CANCEL;
							timeout = 0;
							whileDead = 1;
							showAlert = 1;
							OnHide = function()
								self:SetChecked(false)
								self:OnChecked(self:GetChecked())
							end;
							OnAccept = function()
								env.Bindings:ResetBindings()
							end;
						})
					end;
				};
				Footer = {
					_Type  = 'Frame';
					_Setup = 'CPAnimatedLootHeaderTemplate';
					_Width = LEFT_PANEL_WIDTH;
					_Point = {'BOTTOMLEFT', 24, 0};
					_Text  = CATEGORIES;
				};
			};
		};
	}).Control;

	shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = Shortcuts;
		_Width = LEFT_PANEL_WIDTH;
		_Points = {
			{'TOPRIGHT', self, 'TOPLEFT', LEFT_PANEL_WIDTH + 24, -CONTROL_HEIGHT};
			{'BOTTOMRIGHT', self, 'BOTTOMLEFT', LEFT_PANEL_WIDTH + 24, 0};
		};
		{
			Child = {
				_Width = LEFT_PANEL_WIDTH;
			};
		};
	})
	
	mapper = self:CreateScrollableColumn('Mapper', {
		_Mixin = env.BindingMapper;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 0.01;
		_SetDelta = 40;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_IgnoreNode = true;
		_Points = {
			{'TOPLEFT', flexer, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', flexer, 'BOTTOMRIGHT', 0, 0};
		};
		{
			Catch = {
				_Type = 'Button';
				_Setup = {CPAPI.IsRetailVersion and 'SharedButtonLargeTemplate' or 'UIPanelButtonTemplate', 'CPPopupBindingCatchButtonTemplate'};
				PopupText = ('\n|cFFFFFF00%s|r\n\n%s\n\n'):format(L'Set Binding', BIND_KEY_TO_COMMAND:gsub(' %->', ':\n'));
			};
			Child = {
				_Width = LEFT_PANEL_WIDTH;
				{
					Close = {
						_Type = 'Button';
						_Setup = 'UIPanelCloseButtonNoScripts';
						_Point = {'TOPRIGHT', -8, -8};
						_OnClick = function(self)
							env.Bindings:NotifyBindingFocus(nil)
						end;
					};
					Info = {
						_Type  = 'Frame';
						_Setup = 'CPConfigMapperHeaderTemplate';
						_Point = {'TOP', 0, 0};
					};
					Binding = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingActionTemplate';
						_Size  = {MAPPER_WIDTH, 40};
						_Point = {'TOP', 0, -60};
						_RegisterForClicks = {'LeftButtonUp', 'RightButtonUp'};
						_SetDrawOutline = true;
						_Text = KEY_BINDING ..':';
						_Mixin = MapperBindingButton;
					};
					IconMap = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = env.BindingIconMapper;
						_Size  = {MAPPER_WIDTH, 40};
						_Text  = L'Icon:';
						_Point = {'TOP', '$parent.Binding', 'BOTTOM', 0, -8};
						_Hide  = true;
						{
							CurrentIcon = {
								_Type  = 'IndexButton';
								_Setup = 'CPIndexButtonBindingActionButtonTemplate';
								_Point = {'TOPRIGHT', -4, -6};
								_Size  = {30, 30};
								_SetEnabled = false;
							};
							Content = {
								_Mixin = env.BindingIconMapper.Container;
								{
									PageSelector = {
										_Type = 'IndexButton';
										_Mixin = env.BindingIconMapper.PageSelector;
										_Height = 40;
										_Points = {
											{'TOPLEFT', 0, 0};
											{'TOPRIGHT', 0, 0};
										};
									};
								};
							};
						};
					};
					Option = {
						_Type  = 'Frame';
						_Setup = 'CPConfigBindingDisplayTemplate';
						_Point = {'TOP', '$parent.Binding', 'BOTTOM', 0, 0};
						_Size  = {MAPPER_WIDTH, 40};
						_SetText = function(self, ...)
							self.Label:SetText(...);
						end;
						_OnLoad = function(self)
							-- move the icon to line up with action tooltip
							self.ActionIcon:ClearAllPoints();
							self.ActionIcon:SetSize(40, 40)
							self.ActionIcon:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, 0);
							self:SetText(SETTINGS);
						end;
						{
							Action = {
								_Type  = 'IndexButton';
								_Setup = 'CPIndexButtonBindingHeaderTemplate';
								_Mixin = env.BindingActionMapper;
								_Size  = {MAPPER_WIDTH, 40};
								_Text  = SPELLBOOK_ABILITIES_BUTTON;
								-- OnLoad creates tooltip and sets point, because
								-- tooltip needs to be a globally named frame.
							};
						};
					};
					Desc = {
						_Type  = 'SimpleHTML';
						_Hide  = true;
						_Width = MAPPER_WIDTH;
						_Mixin = env.BindingHTML;
						_Points = {
							{'TOP', '$parent.IconMap', 'BOTTOM', 0, 0};
							{'BOTTOM', 0, 0};
						};
					};
				};
			};
		};
	})
	mapper.Shortcuts = shortcuts;

	local manager = self:CreateScrollableColumn('Manager', {
		_Mixin = env.BindingManager;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 600;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', LEFT_PANEL_WIDTH + 24, 0};
			{'BOTTOMRIGHT', 0, 0};
		};
	})
	manager.Shortcuts = shortcuts;
	shortcuts.List = manager;

	local import = self:CreateScrollableColumn('Import', {
		_Mixin = env.ImportManager;
		_Width = 600;
		_Hide  = true;
		_Level = 10;
		_Fill = shortcuts;
	})

	self:OnActiveDeviceChanged(db('Gamepad/Active'))
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

env.Bindings = ConsolePortConfig:CreatePanel({
	name  = KEY_BINDINGS_MAC;
	mixin = BindingsPanel;
	scaleToParent = true;
	forbidRecursiveScale = true;
})