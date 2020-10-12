local db, _, env = ConsolePort:DB(), ...;
local BindingsMixin = {}

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
function BindingsMixin:GetActiveDeviceAndMap()
	-- using ID to get the buttons in WinRT API order (NOTE: zero-indexed)
	return db('Gamepad/Active'), db('Gamepad/Index/Button/ID')
end

function BindingsMixin:GetActiveModifiers()
	return db('Gamepad/Index/Modifier/Active')
end

function BindingsMixin:GetHotkeyData(btnID, modID, styleMain, styleMod)
	return db('Hotkeys'):GetHotkeyData(db('Gamepad/Active'), btnID, modID, styleMain, styleMod)
end

function BindingsMixin:GetBindings()
	return db('Gamepad'):GetBindings()
end

---------------------------------------------------------------
-- Main frame
---------------------------------------------------------------
function BindingsMixin:OnShow()
	self.container:OnContainerSizeChanged()
end

function BindingsMixin:OnActiveDeviceChanged(device)
	self.device = device;
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
function BindingsMixin:OnLoad()
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
					EquipmentFlyoutPopoutButton_SetReversed(self, false)
					self:SetFlexibleElement(self:GetParent(), self:GetParent().Child)
				end;
				_OnClick = function(self)
					local enabled = self:GetChecked()
					EquipmentFlyoutPopoutButton_SetReversed(self, self:GetChecked())
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
	local control = LibStub:GetLibrary('LibDynamite'):BuildFrame(self, {
		Control = {
			_Type = 'Frame';
			_Size = {600, 50};
			{
				Save = {
					_Type  = 'Button';
					_Setup = 'SharedButtonLargeTemplate';
					_Point = {'TOPLEFT', 0, 0};
					_Text  = SAVE_CHANGES;
					_Size  = {200, 50};
				};
				Reset = {
					_Type  = 'Button';
					_Setup = 'BigRedRefreshButtonTemplate';
					_Point = {'LEFT', '$parent.Save', 'RIGHT', 0, 0};
					_Size  = {50, 50};
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
		_Points = {
			{'TOPLEFT', manager, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', manager, 'BOTTOMRIGHT', 0, 0};
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
						_OnHide = function(self)
							self:SetChecked(false)
							self:OnChecked(false)
						end;
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
						_Setup = 'SharedButtonLargeTemplate';
						_Point = {'CENTER', '$parent.Change', 'CENTER', 0, 0};
						_Level = 100;
						_Text = 'Enter World';
						_Size = {260, 50};
						_Hide = true;
						_OnShow = function(self)
							self:EnableGamePadButton(true)
							self:GetParent().Change:Hide()
							self.timeUntilCancel = 5;
						end;
						_OnHide = function(self)
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
							self:Hide()
							self:GetParent():GetParent():OnButtonCaught(...)
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
							self.ActionIcon:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 6, 0);
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
				}
			}
		}
	})

	self:OnActiveDeviceChanged(db('Gamepad/Active'))
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

env.Bindings = ConsolePortConfig:CreatePanel({
	name  = 'Bindings';
	mixin = BindingsMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})