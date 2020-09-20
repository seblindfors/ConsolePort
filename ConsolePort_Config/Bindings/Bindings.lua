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
		['<Mixin>']  = env.ShortcutsMixin;
		['<Width>']  = 0.01;
		['<SetDelta>'] = 60;
		['<Points>'] = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
		{
			Flexer = {
				['<Type>'] = 'CheckButton';
				['<Setup>'] = 'BackdropTemplate';
				['<Mixin>'] = env.FlexibleMixin;
				['<Width>'] = 24;
				['<Points>'] = {
					{'TOPLEFT', 'parent', 'TOPRIGHT', 0, 0};
					{'BOTTOMLEFT', 'parent', 'BOTTOMRIGHT', 0, 0};
				};
				['<Backdrop>'] = CPAPI.Backdrops.Opaque;
				['<SetBackdropBorderColor>'] = {0.15, 0.15, 0.15, 1};
				['<SetNormalTexture>'] = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['<SetHighlightTexture>'] = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['state'] = false;
				['<OnLoad>'] = function(self)
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
				['<OnClick>'] = function(self)
					local enabled = self:GetChecked()
					EquipmentFlyoutPopoutButton_SetReversed(self, self:GetChecked())
					self:ToggleFlex(enabled)
				end;
			};
		}
	})
	local combos = self:CreateScrollableColumn('Combinations', {
		['<Mixin>']  = env.CombosMixin;
		['<Width>']  = 300;
		['<SetDelta>'] = 60;
		['<Points>'] = {
			{'TOPLEFT', shortcuts.Flexer, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', shortcuts.Flexer, 'BOTTOMRIGHT', 0, 0};
		};
		['<Hooks>'] = {
			['OnMouseWheel'] = function(self)
				if not shortcuts.Flexer:GetChecked() then
					shortcuts.Flexer:Click()
				end
			end;
		};
	})
	local mapper = self:CreateScrollableColumn('Mapper', {
		['<Mixin>'] = env.BindingMapper;
		['<Setup>'] = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		['<Width>'] = 0.01;
		['<SetDelta>'] = 40;
		['<Backdrop>'] = CPAPI.Backdrops.Opaque;
		['<Points>'] = {
			{'TOPLEFT', combos, 'TOPRIGHT', 0, 1};
			{'BOTTOMLEFT', combos, 'BOTTOMRIGHT', 0, -1};
		};
		{
			Child = {
				['<Width>'] = 360;
				{
					Close = {
						['<Type>'] = 'Button';
						['<Setup>'] = 'UIPanelCloseButtonNoScripts';
						['<Point>'] = {'TOPRIGHT', -8, -8};
						['<OnClick>'] = function(self)
							env.Bindings:NotifyBindingFocus(nil)
						end;
					};
					Info = {
						['<Type>']  = 'Frame';
						['<Setup>'] = 'CPConfigBindingDisplayTemplate';
						['<Point>'] = {'TOP', 0, 0};
					};
					Help = {
						['<Type>'] = 'FontString';
						['<Setup>'] = {'ARTWORK', 'GameFontNormal'};
						['<Width>'] = 360;
						['<Point>'] = {'TOP', 0, -60};
						['tutorialText'] = BIND_KEY_TO_COMMAND:gsub(' %->', ':\n');
						['defaultText'] = ('%s%s | %s%s'):format(
							'{Atlas|NPE_LeftClick:32}', CHOOSE,
							REMOVE, '{Atlas|NPE_RightClick:32}'
						);
						['<OnLoad>'] = function(self)
							self:SetFont(GameFontNormal:GetFont());
							self:SetDefaultHelp()
						end;
						['<SetBindingHelp>'] = function(self, text)
							if text then
								self:SetFormattedText(self.tutorialText, text);
							else
								self:SetText(self.defaultText);
							end
						end;
						['<SetDefaultHelp>'] = function(self)
							self:SetText(self.defaultText:gsub('{Atlas|([%w_-]+):?(%d*)}', function(atlasName, size)
								size = tonumber(size) or 0;
								return CreateAtlasMarkup(atlasName, size, size);
							end));
						end;
					};
					Change = {
						['<Type>']  = 'IndexButton';
						['<Setup>'] = 'CPIndexButtonBindingActionTemplate';
						['<Size>']  = {340, 40};
						['<Point>'] = {'TOP', 0, -100};
						['<RegisterForClicks>'] = {'LeftButtonUp', 'RightButtonUp'};
						['<SetDrawOutline>'] = true;
						['<Text>'] = KEY_BINDING ..':';
						['<OnLoad>'] = function(self)
							local label = self:GetFontString()
							local font, _, outline = label:GetFont()
							label:SetFont(font, 14, outline)
						end;
						['<OnHide>'] = function(self)
							self:SetChecked(false)
							self:OnChecked(false)
						end;
						['<OnClick>'] = function(self, button)
							local mapper = self:GetParent():GetParent();
							if (button == 'LeftButton') then
								mapper:SetCatchButton(true);
							elseif (button == 'RightButton') then
								mapper:ClearBinding();
							end
						end;
					};
					Catch = {
						['<Type>'] = 'Button';
						['<Setup>'] = 'SharedButtonLargeTemplate';
						['<Point>'] = {'CENTER', '$parent.Change', 'CENTER', 0, 0};
						['<Level>'] = 100;
						['<Text>'] = 'Enter World';
						['<Size>'] = {260, 50};
						['<Hide>'] = true;
						['<OnShow>'] = function(self)
							self:EnableGamePadButton(true)
							self:GetParent().Change:Hide()
							self.timeUntilCancel = 5;
						end;
						['<OnHide>'] = function(self)
							self:EnableGamePadButton(false)
							self:GetParent().Change:Show()
							self:GetParent().Help:SetDefaultHelp()
							self.timeUntilCancel = 5;
						end;
						['<OnUpdate>'] = function(self, elapsed)
							self.timeUntilCancel = self.timeUntilCancel - elapsed;
							self:SetText(('%s (%d)'):format(CANCEL, ceil(self.timeUntilCancel)))
							if self.timeUntilCancel <= 0 then
								self.timeUntilCancel = 5;
								self:Hide()
							end
						end;
						['<OnGamePadButtonUp>'] = function(self, ...)
							self:Hide()
							self:GetParent():GetParent():OnButtonCaught(...)
						end;
						['<OnClick>'] = function(self) self:Hide() end;
					};
				}
			}
		}
	})
	local manager = self:CreateScrollableColumn('Manager', {
		['<Mixin>'] = env.BindingManager;
		['<Setup>'] = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		['<Width>'] = 600;
		['<Backdrop>'] = CPAPI.Backdrops.Opaque;
		['<Points>'] = {
			{'TOPLEFT', mapper, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', mapper, 'BOTTOMRIGHT', 0, 0};
		};
	})
	self:OnActiveDeviceChanged(db('Gamepad/Active'))
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

env.Bindings = ConsolePortConfig:CreatePanel({
	name  = 'Bindings';
	mixin = BindingsMixin;
	scaleToParent = true;
})