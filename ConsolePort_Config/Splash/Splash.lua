local db, _, env = ConsolePort:DB(), ...; local L = db('Locale');
---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local WIZARD_WIDTH, FIXED_OFFSET = 900, 8;

local Content = {
	{	panel = 'Devices';
		name  = L'Device';
		help  = L'Select your device.';
		pred  = function()
			return not db('Gamepad/Active')
		end;
	};
	{	
		panel = 'Emulation';
		name  = L'Buttons';
		help  = L'Set your emulation buttons.';
		pred  = function()
			return (db('tutorialProgress') == 1);
		end;
	};
	{	panel = 'Handling';
		name  = L'Handling';
		help  = L'Customize your gamepad handling.';
		pred  = function()
			return (db('tutorialProgress') == 2);
		end;
	};
}

---------------------------------------------------------------
-- Content
---------------------------------------------------------------
local WizardContent = {};

function WizardContent:OnLoad()
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, WIZARD_WIDTH, FIXED_OFFSET * 5)
end

function WizardContent:UpdateVariables()
	self.Child.Variables:OnActiveDeviceChanged()
end

function WizardContent:OnShow()
--	self:UpdateVariables()
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Bottom nav bar
---------------------------------------------------------------
local NavBarMixin = {}

function NavBarMixin:OnLoad()
	env.OpaqueMixin.OnLoad(self)

	local function NavButtonOnClick(self)
		env.Splash:ShowPanel(self:GetID())
	end

	self.Buttons = {self.Home};
	for i, data in ipairs(Content) do
		local button = CreateFrame('Button', nil, self, 'CPConfigNavButtonTemplate')
		button:SetPoint('LEFT', self.Buttons[i], 'RIGHT', i == 1 and -16 or 4, 0)
		button:SetText(data.name)
		button:SetWidth(button.text:GetStringWidth() + 40)
		button:SetScript('OnClick', NavButtonOnClick)
		button:SetID(i)
		Content[i].button = button;
		self.Buttons[#self.Buttons + 1] = button;
	end

	local baseFrameLevel = self.Home:GetFrameLevel() * 2;
	for i, button in ripairs(self.Buttons) do
		button:SetFrameLevel(baseFrameLevel -i)
	end
end

---------------------------------------------------------------
-- Splash panel
---------------------------------------------------------------
local Splash = {};

function Splash:OnShow()
	db('Alpha/FadeIn')(self, 1)
end

function Splash:ShowPanel(i)
	local container, parent = self:ClearWizard()
	local data = Content[i];

	if data then
		parent:Show()
		container:Show()

		local panel = container[data.panel]
		panel:Show()
		data.button.selected:Show()
		db('Alpha/FadeIn')(container.Help, 1)

		container.Help:SetText(data.help)
		container.Continue:ClearAllPoints()
		container.Continue:SetPoint('TOP', panel, 'BOTTOM', 0, -FIXED_OFFSET * 3)
		self:SetID(i)

		if (db('Settings/tutorialProgress') ~= #Content) then
			self:SetProgress(i)
		end
	end
end

function Splash:SetProgress(step)
	db('Settings/tutorialProgress', step)
end

function Splash:AutoChoosePanel()
	for i, data in ipairs(Content) do
		if data.pred() then
			return self:ShowPanel(i)
		end
	end
end

function Splash:ClearWizard()
	local parent = self.Setup;
	local container = parent.Child;
	for i, data in ipairs(Content) do
		data.button.selected:Hide()
		data.button:SetEnabled(true)
		container[data.panel]:Hide()
	end
	parent:Hide()
	container:Hide()
	return container, parent;
end

function Splash:OnFirstShow()
	self:SetAllPoints()
	LibStub:GetLibrary('Carpenter'):BuildFrame(self, {
		NavBar = {
			_Type = 'Frame';
			_Setup = 'BackdropTemplate';
			_Mixin = NavBarMixin;
			_Backdrop = CPAPI.Backdrops.Opaque;
			_Points = {
				{'TOPLEFT', '$parent', 'BOTTOMLEFT', 0, 34};
				{'BOTTOMRIGHT', 0, 0};
			};
			{
				Home = {
					_Type = 'Button';
					_Size = {128, 30};
					_Point = {'LEFT', 0, 0};
					_SetNormalTexture = 'Interface\\HelpFrame\\CS_HelpTextures';
					_SetPushedTexture = 'Interface\\HelpFrame\\CS_HelpTextures';
					_SetHighlightTexture = 'Interface\\HelpFrame\\CS_HelpTextures';
					_OnLoad = function(self)
						self.xoffset = -15;
						self.Text:SetFont(GameFontNormal:GetFont())
						self.Text:SetText(START)

						local newWidth = min(128, self.Text:GetStringWidth()+50)
						local texCoordoffsetX = (newWidth/128)*0.25;
							
						self:GetNormalTexture():SetTexCoord(0.70312500-texCoordoffsetX, 0.70312500, 0.00781250, 0.24218750);
						self:GetPushedTexture():SetTexCoord(0.70312500-texCoordoffsetX, 0.70312500, 0.25781250, 0.49218750);
						self:GetHighlightTexture():SetTexCoord(0.70312500-texCoordoffsetX, 0.71312500, 0.50781250, 0.74218750);
						
						self:SetWidth(newWidth);
					end;
					{
						Shadow = {
							_Type = 'Texture';
							_Size = {30, 30};
							_Setup = {'OVERLAY'};
							_File = 'Interface\\Common\\ShadowOverlay-Left';
							_Point = {'LEFT', 0, 0};
						};
						Text = {
							_Type = 'FontString';
							_Size = {0, 12};
							_Points = {
								{'LEFT', 10, 0};
								{'RIGHT', -30, 0};
							};
						};
					};
				};
			};
		};
	})
	local setup = self:CreateScrollableColumn('Setup', {
		_Mixin = WizardContent;
		_Width = WIZARD_WIDTH;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOP', 0, 0};
			{'BOTTOM', '$parent.NavBar', 'TOP', 0, 0};
		};
		{
			Child = {
				_Width = WIZARD_WIDTH;
				{
					Logo = {
						_Type = 'Texture';
						_Size = {128, 128};
						_Point = {'TOP', 0, -100};
						_Texture = CPAPI.GetAsset('Textures\\Logo\\CP');
					};
					Help = {
						_Type = 'FontString';
						_Point = {'TOP', '$parent.Logo', 'BOTTOM', 0, -FIXED_OFFSET};
						_OnLoad = function(self)
							self:SetFontObject(CPHeaderFont);
							self:SetText(L'Select your device.');
						end;
					};
					Continue = {
						_Type = 'Button';
						_Setup = 'SharedButtonLargeTemplate';
						_Text = CONTINUE;
						_Size = {260, 50};
						_OnClick = function(self)
							local panelID = env.Splash:GetID()
							if panelID then
								env.Splash:ShowPanel(panelID + 1)
							end
						end;
						{
							NextPage = {
								_Type = 'Texture';
								_Size = {32, 32};
								_Point = {'RIGHT', -16, 0};
								_Texture = 'Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up';
							};
						}
					};
					Devices = {
						_Type = 'Frame';
						_Hide = true;
						_Mixin = env.DeviceSelector;
						_Point = {'TOP', '$parent.Help', 'BOTTOM', 0, -FIXED_OFFSET * 2};
					};
					Emulation = {
						_Type  = 'Frame';
						_Hide  = true;
						_Mixin = env.VariablesMixin;
						_Width = WIZARD_WIDTH;
						_Point = {'TOP', '$parent.Help', 'BOTTOM', 0, -FIXED_OFFSET * 2};
						dbPath = 'Console/Emulation';
					};
					Handling = {
						_Type  = 'Frame';
						_Hide  = true;
						_Mixin = env.VariablesMixin;
						_Width = WIZARD_WIDTH;
						_Point = {'TOP', '$parent.Help', 'BOTTOM', 0, -FIXED_OFFSET * 2};
						dbPath = 'Console/Handling';
					};
				};
			};
		};
	})
	self:AutoChoosePanel()
end

env.Splash = ConsolePortConfig:CreatePanel({
	name  = 'Splash';
	mixin = Splash;
	noHeader = true;
	scaleToParent = true;
	forbidRecursiveScale = true;
})

-- Set as default frame
ConsolePortConfig.DefaultFrame = env.Splash;
ConsolePortConfig:ShowDefaultFrame(true)