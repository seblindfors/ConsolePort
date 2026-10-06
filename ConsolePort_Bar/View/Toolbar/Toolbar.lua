local _, env, db, L = ...; db = env.db; L = db.Locale;
local NOTCH_FADE_TIME = 0.2;
local MENU_PADDING    = 32;
local MENU_GAP        = -20;
local MENU_BLEED      = 60;
local MENU_ALPHA      = 0.65;
local NOTCH_ATLAS     = 'helptip-arrow';
local NOTCH_BACKING   = 'helptip-arrow-mask';
local NOTCH_MASK_FILE = [[Interface\HELPFRAME\HelptipArrowMask]];
local NOTCH_WIDTH, NOTCH_HEIGHT = 65, 28;
-- The art points down and rotates as a quad at its native size.
local Directions = {
	-- direction: menu anchor, toolbar anchor, rotation, notch size, menu offset
	UP    = { 'BOTTOM', 'TOP',    math.pi,       NOTCH_WIDTH,  NOTCH_HEIGHT,  0,  1 };
	DOWN  = { 'TOP',    'BOTTOM', 0,             NOTCH_WIDTH,  NOTCH_HEIGHT,  0, -1 };
	RIGHT = { 'LEFT',   'RIGHT',  math.pi * 0.5, NOTCH_HEIGHT, NOTCH_WIDTH,  -1,  0 };
	LEFT  = { 'RIGHT',  'LEFT',   math.pi * 1.5, NOTCH_HEIGHT, NOTCH_WIDTH,   1,  0 };
};

local function GetDirection(point)
	if ( point == 'LEFT' )  then return 'RIGHT' end;
	if ( point == 'RIGHT' ) then return 'LEFT'  end;
	if point:match('^TOP') then return 'DOWN' end;
	return 'UP';
end
local BAG_INDEX_START = 110;
local BAG_BUTTON_SIZE = 40;
local BAG_BUTTONS = {
	'MainMenuBarBackpackButton';
	'CharacterBag0Slot';
	'CharacterBag1Slot';
	'CharacterBag2Slot';
	'CharacterBag3Slot';
	'CharacterReagentBag0Slot';
	'KeyRingButton';
};
---------------------------------------------------------------
local TooltipButton = {};
---------------------------------------------------------------

function TooltipButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip_SetTitle(GameTooltip, self.title)
	if self.instruction then GameTooltip_AddInstructionLine(GameTooltip, self.instruction) end
	if self.error then GameTooltip_AddErrorLine(GameTooltip, self.error) end
	GameTooltip:Show()
	db.Alpha.Flash(self.FlashBorder, 1, 1, -1, false, 0, 0, 'microbutton')
end

function TooltipButton:OnLeave()
	db.Alpha.Stop(self.FlashBorder)
end

---------------------------------------------------------------
local Eye = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	instruction = L'Toggle visibility of all modifier flyouts.';
});

function Eye:OnLoad()
	env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
	self:OnShowAll(env('clusterShowAll'))
	self:RegisterForClicks('AnyDown', 'AnyUp')
	CPAPI.Start(self)
end

function Eye:OnShowAll(showAll)
	local icon = showAll and env.GetAsset([[Textures\Show]]) or env.GetAsset([[Textures\Hide]]);
	self.NormalTexture:SetTexture(icon)
	self.PushedTexture:SetTexture(icon)
	self.title = showAll and L'Hide Flyout Buttons' or L'Show Flyout Buttons';
end

function Eye:OnClick()
	env('Settings/clusterShowAll', not env('clusterShowAll'))
	self:OnEnter()
end

---------------------------------------------------------------
local Config = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	title       = L'Action Bar Configuration';
	instruction = L'Open the configuration menu for the action bar.';
});

function Config:OnLoad()
	self:RegisterForClicks('AnyDown', 'AnyUp')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	CPAPI.Start(self)
end

function Config:OnEvent()
	self:SetEnabled(not InCombatLockdown())
	self.error = InCombatLockdown() and L'Cannot open configuration menu in combat.' or nil;
end

function Config:OnClick()
	env:TriggerEvent('OnConfigToggle')
end

---------------------------------------------------------------
local ExitVehicle = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	title       = L'Exit Vehicle';
	onVehicle   = L'Exit the vehicle you are currently controlling.';
	onTaxi      = L'Request early landing from the taxi you are currently riding.';
	Events      = {
		'UPDATE_BONUS_ACTIONBAR';
		'UPDATE_MULTI_CAST_ACTIONBAR';
		'UNIT_ENTERED_VEHICLE';
		'UNIT_EXITED_VEHICLE';
		'VEHICLE_UPDATE';
	};
});

function ExitVehicle:OnLoad()
	self:RegisterForClicks('AnyDown', 'AnyUp')
	self.NormalTexture:SetSize(24, 32)
	self.HighlightTexture:SetSize(24, 32)
	CPAPI.RegisterFrameForEvents(self, self.Events)
	CPAPI.Start(self)
	self:OnEvent()
end

function ExitVehicle:SetNormal()
	CPMicroButton.SetNormal(self)
	self.HighlightTexture:SetSize(24, 32)
end

function ExitVehicle:OnClick()
	if UnitOnTaxi('player') then
		TaxiRequestEarlyLanding()
		self:Disable()
		self:LockHighlight()
	else
		VehicleExit()
	end
end

function ExitVehicle:OnEvent()
	self.instruction = UnitOnTaxi('player') and self.onTaxi or self.onVehicle;
	self:SetShown(self:CanExitVehicle())
	if self:CanExitVehicle() then
		self:Enable()
	else
		self:UnlockHighlight()
	end
end

function ExitVehicle:CanExitVehicle()
	if not CanExitVehicle then
		return UnitOnTaxi('player')
	else
		return CanExitVehicle()
	end
end

---------------------------------------------------------------
CPMicroButton = {
---------------------------------------------------------------
	ValidateTextures = {
		Background       = false;
		PushedBackground = false;
		FlashBorder      = 'Flash';
	};
};

local LoadMicroButtonTextures, MovePortraitTextures, MovePerformanceBar = nop, nop, nop;
if not CPAPI.IsModernVersion then
	local TextureKit = {
		AchievementMicroButton = 'Achievements';
		CharacterMicroButton   = 'ButtonBG';
		CollectionsMicroButton = 'Collections';
		EJMicroButton          = 'AdventureGuide';
		GuildMicroButton       = 'GuildCommunities';
		HelpMicroButton        = 'Shop';
		LFGMicroButton         = 'Groupfinder';
		MainMenuMicroButton    = 'GameMenu';
		PVPMicroButton         = 'ButtonBG';
		QuestLogMicroButton    = 'Questlog';
		SocialsMicroButton     = 'GuildCommunities';
		SpellbookMicroButton   = 'SpellbookAbilities';
		StoreMicroButton       = 'Shop';
		TalentMicroButton      = 'SpecTalents';
		WorldMapMicroButton    = 'Groupfinder';
	};

	function LoadMicroButtonTextures(button)
		local kit = TextureKit[button:GetName()];
		local atlas = 'UI-HUD-MicroMenu-%s-%s';
		if kit then
			button.normalAtlas    = atlas:format(kit, 'Up');
			button.pushedAtlas    = atlas:format(kit, 'Down');
			button.disabledAtlas  = atlas:format(kit, 'Disabled');
			button.highlightAtlas = atlas:format(kit, 'Mouseover');
			button.SetNormalTexture    = nop; -- HACK: might taint?
			button.SetPushedTexture    = nop;
			button.SetDisabledTexture  = nop;
			button.SetHighlightTexture = nop;
		end
	end

	local PortraitTextures = {
		MicroButtonPortrait   = { 0.2000, 0.8000, 0.0666, 0.9000 };
		PVPMicroButtonTexture = { 0.1250, 0.5000, 0.0000, 0.6000 };
	};

	function MovePortraitTextures()
		for name, coords in pairs(PortraitTextures) do
			local portrait = _G[name];
			if portrait then
				portrait:ClearAllPoints()
				portrait:SetPoint('TOPLEFT', 7, -7)
				portrait:SetPoint('BOTTOMRIGHT', -7, 7)
				portrait:SetTexCoord(unpack(coords))
			end
		end
	end
end

if CPAPI.IsClassicEraVersion or CPAPI.IsAnniVersion then
	function MovePerformanceBar(self)
		local frame  = MainMenuBarPerformanceBarFrame;
		local status = MainMenuBarPerformanceBar;
		if not frame or not self.props.micromenu then return end;
		frame:Show()
		frame:SetParent(self)
		frame:SetAllPoints(self.Divider1)
		frame:SetFrameStrata(self.Divider1:GetFrameStrata())
		frame:SetFrameLevel(self.Divider1:GetFrameLevel() + 1)
		CPAPI.LockPoints(frame)
		frame.ignoreInLayout = true;
		if not status then return end;
		status:SetParent(frame)
		status:SetAllPoints(frame)
		CPAPI.LockPoints(status)
	end
end

function CPMicroButton:OnLoad()
	self:SetSize(32, 40)

	self.NormalTexture    = self.NormalTexture or self:GetNormalTexture()
	self.PushedTexture    = self.PushedTexture or self:GetPushedTexture()
	self.HighlightTexture = self.HighlightTexture or self:GetHighlightTexture()
	self.DisabledTexture  = self.DisabledTexture or self:GetDisabledTexture()

	for texture, parentKey in pairs(self.ValidateTextures) do
		if not self[texture] then
			local object = parentKey and self[parentKey] or self:CreateTexture(nil, 'BACKGROUND')
			object:ClearAllPoints()
			object:SetSize(32, 41)
			object:SetPoint('CENTER')
			self[texture] = object;
		end
	end

	CPAPI.SetAtlas(self.Background, 'UI-HUD-MicroMenu-ButtonBG-Up', true)
	CPAPI.SetAtlas(self.PushedBackground, 'UI-HUD-MicroMenu-ButtonBG-Down', true)
	CPAPI.SetAtlas(self.FlashBorder, 'UI-HUD-MicroMenu-Highlightalert', false)

	for atlas, texture in pairs({
		normalAtlas    = self.NormalTexture;
		pushedAtlas    = self.PushedTexture;
		disabledAtlas  = self.DisabledTexture;
		highlightAtlas = self.HighlightTexture;
	}) do
		if self[atlas] then
			if not CPAPI.SetAtlas(texture, self[atlas], true) then
				texture:Hide()
			end
		end
	end
end

function CPMicroButton:OnEnter()
	if self.normalAtlas then
		self.NormalTexture:SetAlpha(0)
	end
end

function CPMicroButton:OnLeave()
	if self.normalAtlas then
		self.NormalTexture:SetAlpha(1)
	end
end

function CPMicroButton:SetPushed()
	self.Background:Hide()
	self.PushedBackground:Show()

	self:SetButtonState('PUSHED', true)
	if self.highlightAtlas then
		self.HighlightTexture:SetBlendMode('ADD')
		self.HighlightTexture:SetAlpha(0.5)
	end
end

function CPMicroButton:SetNormal()
	self:SetButtonState('NORMAL')
	if self.highlightAtlas then
		CPAPI.SetAtlas(self.HighlightTexture, self.highlightAtlas, true)
		self.HighlightTexture:SetBlendMode('BLEND')
		self.HighlightTexture:SetAlpha(1)
	end
	self.Background:Show()
	self.PushedBackground:Hide()
end

function CPMicroButton:OnShow()
	self:GetParent():Layout()
end

function CPMicroButton:OnHide()
	self:OnLeave()
	if self:IsEnabled() then
		self:SetNormal()
	end
	self:GetParent():Layout()
end

function CPMicroButton:OnMouseDown()
	if self:IsEnabled() then
		self:SetPushed()
	end
end

function CPMicroButton:OnMouseUp()
	if self:IsEnabled() then
		self:SetNormal()
	end
end

---------------------------------------------------------------
local Grid = {};
---------------------------------------------------------------
function Grid:Layout()
	local children = self:GetLayoutChildren();
	local layout = GridLayoutUtil.CreateStandardGridLayout(self.stride, self.childXPadding, self.childYPadding, 1, -1);
	GridLayoutUtil.ApplyGridLayout(children, AnchorUtil.CreateAnchor('TOPLEFT', self, 'TOPLEFT'), layout)
	local width, height, count = 0, 0, 0;
	for _, child in ipairs(children) do
		width, height, count = width + child:GetWidth(), max(height, child:GetHeight()), count + 1;
	end
	if ( count > 0 ) then
		self:SetSize(width + (count - 1) * self.childXPadding, height)
	end
end

function Grid:OnLoad()
	Mixin(self.Eye, Eye):OnLoad()
	Mixin(self.Config, Config):OnLoad()
	Mixin(self.ExitVehicle, ExitVehicle):OnLoad()
	self.MicroButtons, self.BagButtons, self.ownedBags = {}, {}, {};

	if OverrideMicroMenuPosition then
		hooksecurefunc('OverrideMicroMenuPosition', GenerateClosure(self.OnOverrideMicroMenuPosition, self))
	end
	if UpdateMicroButtonsParent then
		hooksecurefunc('UpdateMicroButtonsParent', GenerateClosure(self.OnUpdateMicroButtonsParent, self))
	end
	if UpdateMicroButtons then
		hooksecurefunc('UpdateMicroButtons', GenerateClosure(self.OnUpdateMicroButtonsParent, self))
	end
	if BagsBar and BagsBar.Layout then
		hooksecurefunc(BagsBar, 'Layout', GenerateClosure(self.OnBagsBarLayout, self))
	end
	if MainMenuBarBagManager and MainMenuBarBagManager.OnExpandBarChanged then
		hooksecurefunc(MainMenuBarBagManager, 'OnExpandBarChanged', GenerateClosure(self.OnBagsBarLayout, self))
	end
end

function Grid:OnBagsBarLayout()
	if self.bags and self.bags.enabled and self:Owns(self.BagButtons) then
		CPAPI.Next(self.Layout, self)
	end
end

function Grid:RefreshMicroButtons()
	local microButtons = {};
	if MicroMenu then
		for _, button in ipairs({MicroMenu:GetChildren()}) do
			if button.layoutIndex then
				microButtons[button] = button.layoutIndex;
			end
		end
	end
	if not next(microButtons) and MICRO_BUTTONS then
		for i, name in ipairs(MICRO_BUTTONS) do
			local button = _G[name];
			if button then
				microButtons[button] = button.layoutIndex or i;
			end
		end
	end
	self.MicroButtons = microButtons;
end

function Grid:RefreshBagButtons()
	local bagButtons = {};
	for i, name in ipairs(BAG_BUTTONS) do
		local button = _G[name];
		if button then
			bagButtons[button] = BAG_INDEX_START + i;
		end
	end
	self.BagButtons = bagButtons;
end

-- A micro button that hides mid-move makes Blizzard's container lay
-- out the buttons still under it, and one that was never placed has
-- no centre to read. Moving into a shown parent hides nothing.
function Grid:WhileShown(func, ...)
	if self.moving then return end;
	self.moving = true;
	local menu = self:GetParent();
	local wasShown = menu:IsShown();
	if not wasShown then menu:Show() end;
	func(self, ...)
	if not wasShown then menu:Hide() end;
	self.moving = nil;
end

function Grid:Owns(buttons)
	for button in pairs(buttons) do
		if ( button:GetParent() ~= self ) then
			return false;
		end
	end
	return true;
end

function Grid:MoveMicroButtons()
	self:RefreshMicroButtons()
	if self:Owns(self.MicroButtons) then
		return self:MoveMicroButtonsNow();
	end
	self:WhileShown(self.MoveMicroButtonsNow)
end

function Grid:MoveBagButtons()
	self:RefreshBagButtons()
	if self:Owns(self.BagButtons) then
		return self:MoveBagButtonsNow();
	end
	self:WhileShown(self.MoveBagButtonsNow)
end

function Grid:MoveMicroButtonsNow()
	self.Divider1:SetShown(self.props.micromenu)
	if not self.props.micromenu then return end;
	self:RefreshMicroButtons()
	for button, index in pairs(self.MicroButtons) do
		if ( button:GetParent() ~= self ) then
			button:SetParent(self)
			button:ClearAllPoints()
		end
		if ( button.layoutIndex ~= index ) then
			button.layoutIndex = index;
		end
		if not CPAPI.IsModernVersion and not button.ValidateTextures then
			LoadMicroButtonTextures(button)
			button:SetHitRectInsets(0, 0, 0, 0)
			Mixin(button, CPMicroButton):OnLoad()
		end
	end
	MovePerformanceBar(self)
	MovePortraitTextures()
end

function Grid:MoveBagButtonsNow()
	self.Divider2:SetShown(self.bags.enabled)
	if not self.bags.enabled then return end;
	self:RefreshBagButtons()
	if BagBarExpandToggle and ( BagBarExpandToggle:GetParent() ~= self ) then
		BagBarExpandToggle:SetParent(self)
		BagBarExpandToggle:Hide()
	end
	for button, index in pairs(self.BagButtons) do
		if ( button:GetParent() ~= self ) then
			button:SetParent(self)
			button:ClearAllPoints()
		end
		button:SetSize(BAG_BUTTON_SIZE, BAG_BUTTON_SIZE)
		button.layoutIndex = index;
		if not self.ownedBags[button] then
			self.ownedBags[button] = true;
			if button.SetBarExpanded then
				hooksecurefunc(button, 'SetBarExpanded', GenerateClosure(self.OnBagExpansionChanged, self))
			end
		end
		button:Show()
	end
end

function Grid:OnBagExpansionChanged(button)
	if self.bags and self.bags.enabled and self.ownedBags[button] then
		button:Show()
	end
end

function Grid:SetProps(menu, bags)
	self.props = menu;
	self.bags  = bags;
	self:SetScale(menu.scale or 1.5)
	self.Eye:SetShown(menu.eye)
	self:MoveMicroButtons()
	self:MoveBagButtons()
	self:Layout()
end

function Grid:OnOverrideMicroMenuPosition(...)
	if not self.props or not self.props.micromenu then return end;
	if not MicroMenu then return end;
	for button in pairs(self.MicroButtons) do
		button:SetParent(MicroMenu)
	end
	MicroMenu:Layout()
end

function Grid:OnUpdateMicroButtonsParent(...)
	if not self.props or not self.props.micromenu or self.moving then return end;
	self:RefreshMicroButtons()
	if self:Owns(self.MicroButtons) then return end;
	self:MoveMicroButtons()
	CPAPI.Next(self.Layout, self)
end

---------------------------------------------------------------
CPToolbarNotch = {};
---------------------------------------------------------------
local Notch = CPToolbarNotch;

function Notch:OnLoad()
	CPAPI.SetAtlas(self.NormalTexture, NOTCH_ATLAS, false)
	CPAPI.SetAtlas(self.HighlightTexture, NOTCH_ATLAS, false)
	CPAPI.SetAtlas(self.Backing, NOTCH_BACKING, false)
	self.Mask:SetTexture(NOTCH_MASK_FILE)
	self.NormalTexture:AddMaskTexture(self.Mask)
	self.HighlightTexture:AddMaskTexture(self.Mask)
end

function Notch:OnClick()
	self:GetParent():Toggle()
end

function Notch:OnEnter()
	db.Alpha.FadeIn(self, NOTCH_FADE_TIME, self:GetAlpha(), 1)
end

function Notch:OnLeave()
	if self.alwaysShow then return end;
	db.Alpha.FadeOut(self, NOTCH_FADE_TIME, self:GetAlpha(), 0)
end

function Notch:SetAlwaysShown(alwaysShow)
	self.alwaysShow = alwaysShow;
	self:SetAlpha(alwaysShow and 1 or 0)
end

function Notch:SetDirection(direction)
	local _, _, rotation, width, height = unpack(Directions[direction]);
	for _, texture in ipairs({self.NormalTexture, self.HighlightTexture, self.Backing, self.Mask}) do
		texture:SetRotation(rotation)
	end
	local sideways = ( width < height );
	local padX, padY = sideways and 8 or 16, sideways and 16 or 8;
	self:SetSize(width, height)
	self:GetParent():SetSize(width + padX, height + padY)
end

---------------------------------------------------------------
CPToolbar = CreateFromMixins(env.ConfigurableWidgetMixin);
---------------------------------------------------------------

function CPToolbar:OnLoad()
	self.snapToPixels = 8;
	CPAPI.ApplyNineSlice(self.Menu.Border, CPAPI.Backdrops.Dropdown)
	self.Menu.Border:SetAlpha(MENU_ALPHA)
	Mixin(self.Menu.Grid, Grid):OnLoad()
	self.Menu:HookScript('OnShow', GenerateClosure(self.OnMenuShow, self))
	self.Menu.Grid:HookScript('OnSizeChanged', GenerateClosure(self.OnGridSizeChanged, self))
end

function CPToolbar:Toggle()
	self.Menu:SetShown(not self.Menu:IsShown())
end

function CPToolbar:OnMenuShow()
	self.Menu.Grid:MoveMicroButtons()
	self.Menu.Grid:MoveBagButtons()
	self.Menu.Grid:Layout()
end

function CPToolbar:OnGridSizeChanged()
	local grid, scale = self.Menu.Grid, self.Menu.Grid:GetScale();
	self.Menu:SetSize(grid:GetWidth() * scale + MENU_PADDING, grid:GetHeight() * scale + MENU_PADDING)
	FrameUtil.UpdateScaleForFit(self.Menu, MENU_BLEED, MENU_BLEED)
end

function CPToolbar:UpdateDirection(props)
	local direction = GetDirection(props.pos.point);
	local menuAnchor, toolbarAnchor, _, _, _, dx, dy = unpack(Directions[direction]);
	self.Menu:ClearAllPoints()
	self.Menu:SetPoint(menuAnchor, self, toolbarAnchor, dx * -MENU_GAP, dy * -MENU_GAP)
	self.Notch:SetDirection(direction)
end

function CPToolbar:SetProps(props)
	self:SetDynamicProps(props)
	self:UpdateDirection(props)
	self.Notch:SetAlwaysShown(props.notch.show)
	self.Menu.Grid:SetProps(props.menu, props.bags)
	self:OnGridSizeChanged()
	self:Show()
end

function CPToolbar:OnPropsUpdated()
	self:SetProps(self.props)
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Toolbar', function()
	if not ConsolePortToolbar then
		ConsolePortToolbar = CreateFrame('Frame', 'ConsolePortToolbar', env.Manager, 'CPToolbar')
	end
	return ConsolePortToolbar;
end, env.Interface.Toolbar)
