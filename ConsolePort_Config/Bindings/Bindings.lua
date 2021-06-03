local _, env = ...; local db, L = env.db, env.L;
local DEFAULT_BINDINGS, ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 0, 1, 2;
local BindingsMixin = {}
---------------------------------------------------------------
-- Main frame
---------------------------------------------------------------
function BindingsMixin:OnShow()
	self.container:OnContainerSizeChanged()
	self:SnapshotBindings()
end

function BindingsMixin:OnActiveDeviceChanged(device)
	self.device = device;
end

function BindingsMixin:Validate()
	if not self.snapshot then
		return true -- panel was never opened
	end
	if not db.table.compare(self.snapshot, db.Gamepad:GetBindings()) then
		self.snapshot = nil;
		return false, self.SaveBindings;
	end
	return true
end

function BindingsMixin:LoadBindings(set)
	LoadBindings(set)
	SaveBindings(set)
	return self:SnapshotBindings()
end

function BindingsMixin:SaveBindings()
	local set = GetCurrentBindingSet()
	SaveBindings(set)
	if (set == CHARACTER_BINDINGS) then
		CPAPI.Log('Your gamepad bindings for %s have been saved.', CPAPI.GetPlayerName(true))
	else
		CPAPI.Log('Your gamepad bindings have been saved.')
	end
	return set, self:SnapshotBindings();
end

function BindingsMixin:SnapshotBindings()
	self.snapshot = db.Gamepad:GetBindings()
	return self.snapshot;
end

function BindingsMixin:WipeSnapshot()
	self.snapshot = nil;
end

function BindingsMixin:NotifyComboFocus(id, name, fraction)
	local combo = self.Combinations:GetWidgetByID(id, name)
	if fraction then
		--self.Combinations:ToggleFlex(true) -- TODO: can't do this currently because of conflicting onupdate
		self.Combinations:ScrollToOffset(fraction)
	end
end

function BindingsMixin:NotifyBindingFocus(widget, show, hideShortcuts)
	if show and hideShortcuts and self.Shortcuts.Flexer:GetChecked() then
		self.Shortcuts.Flexer:Click()
	end
	self.Combinations:ToggleFlex(not show)
	self.Mapper:ToggleWidget(widget, show)
end

---------------------------------------------------------------
-- Setting up
---------------------------------------------------------------
function BindingsMixin:OnFirstShow()
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

	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin  = env.ShortcutsMixin;
		_Width  = 0.01;
		_SetDelta = 60;
		_Points = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
		{
			Flexer = {
				_Type = 'CheckButton';
				_Setup = 'BackdropTemplate';
				_Mixin = env.FlexibleMixin;
				_Width = 24;
				_Points = {
					{'TOPLEFT', 'parent', 'TOPRIGHT', 0, 0};
					{'BOTTOMLEFT', 'parent', 'BOTTOMRIGHT', 0, 0};
				};
				_Backdrop = CPAPI.Backdrops.Opaque;
				_SetBackdropBorderColor = {0.15, 0.15, 0.15, 1};
				_SetNormalTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				_SetHighlightTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['state'] = false;
				_OnLoad = function(self)
					local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
					self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
					self.Center:SetGradientAlpha('HORIZONTAL', r*2, g*2, b*2, 1, r/1.25, g/1.25, b/1.25, 1)
					local normal = self:GetNormalTexture()
					local hilite = self:GetHighlightTexture()
					normal:ClearAllPoints()
					normal:SetPoint('CENTER', -1, 0)
					normal:SetSize(16, 32)
					hilite:ClearAllPoints()
					hilite:SetPoint('CENTER', -1, 0)
					hilite:SetSize(16, 32)
					FlyoutPopoutButtonSetReversed(self, false)
					self:SetFlexibleElement(self:GetParent(), self:GetParent().Child)
				end;
				_OnClick = function(self)
					local enabled = self:GetChecked()
					FlyoutPopoutButtonSetReversed(self, self:GetChecked())
					self:ToggleFlex(enabled)
				end;
			};
		}
	})
	local combos = self:CreateScrollableColumn('Combinations', {
		_Mixin  = env.CombosMixin;
		_Width  = 300;
		_SetDelta = 60;
		_Points = {
			{'TOPLEFT', shortcuts.Flexer, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', shortcuts.Flexer, 'BOTTOMRIGHT', 0, 0};
		};
		_Hooks = {
			['OnMouseWheel'] = function(self)
				if not shortcuts.Flexer:GetChecked() then
					shortcuts.Flexer:Click()
				end
			end;
		};
	})
	local manager = self:CreateScrollableColumn('Manager', {
		_Mixin = env.BindingManager;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 600;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', combos, 'TOPRIGHT', 0, 1};
			{'BOTTOMLEFT', combos, 'BOTTOMRIGHT', 0, 60};
		};
	})
	local import = self:CreateScrollableColumn('Import', {
		_Mixin = env.ImportManager;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 600;
		_Hide  = true;
		_Level = 10;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', combos, 'TOPRIGHT', 0, 1};
			{'BOTTOMLEFT', combos, 'BOTTOMRIGHT', 0, 60};
		};
	})
	local control = LibStub:GetLibrary('Carpenter'):BuildFrame(self, {
		Control = {
			_Type = 'Frame';
			_Setup = 'BackdropTemplate';
			_Backdrop = CPAPI.Backdrops.Opaque;
			_OnLoad = env.OpaqueMixin.OnLoad;
			_Points = {
				{'TOPLEFT', manager, 'BOTTOMLEFT', 0, 1};
				{'BOTTOMRIGHT', manager, 'BOTTOMRIGHT', 0, -60};
			};
			{
				Reset = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', 16, 0};
					_Size  = {40, 40};
					_SetDrawOutline = true;
					_SetNormalTexture = [[Interface\Buttons\UIFrameButtons]];
					_SetHighlightTexture = [[Interface\Buttons\UIFrameButtons]];
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
				Import = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Reset', 'RIGHT', 0, 0};
					_Text  = L'Import';
					_Size  = {162, 40};
					_SetDrawOutline = true;
					_OnClick = function()
						self.Manager:SetShown(not self.Manager:IsShown())
						self.Import:SetShown(not self.Import:IsShown())
					end;
				};
				Save = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Import', 'RIGHT', 0, 0};
					_Text  = SAVE;
					_Size  = {162, 40};
					_SetDrawOutline = true;
					_OnClick = function(self)
						self:SetChecked(false)
						self:OnChecked(self:GetChecked())
						env.Bindings:SaveBindings()
					end;
				};
				Revert = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Save', 'RIGHT', 0, 0};
					_Size  = {162, 40};
					_Text  = CANCEL;
					_SetDrawOutline = true;
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
								env.Bindings:LoadBindings(GetCurrentBindingSet())
							end;
						})
					end;
				};
				Mode = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'LEFT', '$parent.Revert', 'RIGHT', 0, 0};
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
						manager:RefreshHeader()
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
			};
		};
	}).Control;

	local mapper = self:CreateScrollableColumn('Mapper', {
		_Mixin = env.BindingMapper;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 0.01;
		_SetDelta = 40;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_IgnoreNode = true;
		_Points = {
			{'TOPLEFT', manager, 'TOPRIGHT', -1, 0};
			{'BOTTOMLEFT', manager, 'BOTTOMRIGHT', -1, -61};
		};
		{
			Child = {
				_Width = 360;
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
					Help = {
						_Type = 'FontString';
						_Setup = {'ARTWORK', 'GameFontNormal'};
						_Width = 360;
						_Point = {'TOP', 0, -60};
						['tutorialText'] = BIND_KEY_TO_COMMAND:gsub(' %->', ':\n');
						['defaultText'] = ('%s%s | %s%s'):format(
							'{Atlas|NPE_LeftClick:32}', CHOOSE,
							REMOVE, '{Atlas|NPE_RightClick:32}'
						);
						_OnLoad = function(self)
							self:SetFont(GameFontNormal:GetFont());
							self:SetDefaultHelp()
						end;
						_SetBindingHelp = function(self, text)
							if text then
								self:SetFormattedText(self.tutorialText, text);
							else
								self:SetText(self.defaultText);
							end
						end;
						_SetDefaultHelp = function(self)
							self:SetText(self.defaultText:gsub('{Atlas|([%w_-]+):?(%d*)}', function(atlasName, size)
								size = tonumber(size) or 0;
								return CreateAtlasMarkup(atlasName, size, size);
							end));
						end;
					};
					Change = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingActionTemplate';
						_Size  = {340, 40};
						_Point = {'TOP', 0, -100};
						_RegisterForClicks = {'LeftButtonUp', 'RightButtonUp'};
						_SetDrawOutline = true;
						_Text = KEY_BINDING ..':';
						_OnLoad = function(self)
							local label = self:GetFontString()
							local font, _, outline = label:GetFont()
							label:SetFont(font, 14, outline)
						end;
						_OnHide = CPIndexButtonMixin.Uncheck;
						_OnClick = function(self, button)
							local mapper = self:GetParent():GetParent();
							if (button == 'LeftButton') then
								mapper:SetCatchButton(true);
							elseif (button == 'RightButton') then
								mapper:ClearBinding();
							end
						end;
					};
					Catch = {
						_Type = 'Button';
						_Setup = CPAPI.IsRetailVersion and 'SharedButtonLargeTemplate' or 'UIPanelButtonTemplate';
						_Point = {'CENTER', '$parent.Change', 'CENTER', 0, 0};
						_Level = 100;
						_Size = {260, 50};
						_Hide = true;
						_OnShow = function(self)
							env.Config:PauseCatcher()
							self:EnableGamePadButton(true)
							self:GetParent().Change:Hide()
							self.timeUntilCancel = 5;
						end;
						_OnHide = function(self)
							env.Config:ResumeCatcher()
							self:EnableGamePadButton(false)
							self:GetParent().Change:Show()
							self:GetParent().Help:SetDefaultHelp()
							self.timeUntilCancel = 5;
						end;
						_OnUpdate = function(self, elapsed)
							self.timeUntilCancel = self.timeUntilCancel - elapsed;
							self:SetText(('%s (%d)'):format(CANCEL, ceil(self.timeUntilCancel)))
							if self.timeUntilCancel <= 0 then
								self.timeUntilCancel = 5;
								self:Hide()
							end
						end;
						_OnGamePadButtonUp = function(self, ...)
							if self:GetParent():GetParent():OnButtonCaught(...) then
								self:Hide()
							end
						end;
						_OnClick = function(self) self:Hide() end;
					};
					Option = {
						_Type  = 'Frame';
						_Setup = 'CPConfigBindingDisplayTemplate';
						_Point = {'TOP', '$parent.Change', 'BOTTOM', 0, 0};
						_Size  = {340, 40};
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
								_Size  = {340, 40};
								_Text  = SPELLBOOK_ABILITIES_BUTTON;
								-- OnLoad creates tooltip and sets point, because
								-- tooltip needs to be a globally named frame.
							};
						};
					};
					Desc = {
						_Type  = 'SimpleHTML';
						_Hide  = true;
						_Width = 340;
						_Mixin = env.BindingHTML;
						_Points = {
							{'TOP', '$parent.Change', 'BOTTOM', 0, 0};
							{'BOTTOM', 0, 0};
						};
					};
				};
			};
		};
	})

	self:OnActiveDeviceChanged(db('Gamepad/Active'))
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

env.Bindings = ConsolePortConfig:CreatePanel({
	name  = KEY_BINDINGS_MAC;
	mixin = BindingsMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})