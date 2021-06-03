local _, env = ...;
local Splash = CreateFromMixins(CPButtonMixin); env.SplashButtonMixin = Splash;
local Grid, Combo, configEnv = {}, {};

---------------------------------------------------------------
-- Splash handler
---------------------------------------------------------------
function Splash:Initialize(menu)
	self.ringWidth = 116 * 0.8;
	self.ringHeight = 117 * 0.8;
	self.checkedTextureSize = 99 * 0.8;
	CPButtonMixin.OnLoad(self)
	self:HookScript('PreClick', self.PreClick)

	local mask = self.CircleMask;
	mask:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64_Reverse]]), 'CLAMPTOWHITE')
	menu.Background:AddMaskTexture(mask)
	menu.Rollover:AddMaskTexture(mask)
	menu.BG:AddMaskTexture(mask)
end

function Splash:OnClear()
	self:SetChecked(false)
	self:StopFlash()
	self.BackgroundFrame:Hide()
	self.OverviewFrame:Hide()
	self.GridFrame:Hide()

	env.db.Alpha.FadeOut(self.OverviewFrame, 0.1, self.OverviewFrame:GetAlpha(), 0, {
		finishedFunc = self.OverviewFrame.Hide;
		finishedArg1 = self.OverviewFrame;
	})
end

function Splash:PreClick()
	if self.OverviewFrame:IsShown() then
		self.showGridOnFocus = true;
	elseif self.GridFrame:IsShown() then
		self.clearOnFocus = true;
	end
end

function Splash:OnFocus()
	if self.clearOnFocus then
		self.clearOnFocus = nil;
		return self:OnClear()
	end
	
	self:SetChecked(true)
	self:StartFlash()
	self.BackgroundFrame:Show()

	if not self.contentFrameLoaded then
		local configLoaded = IsAddOnLoaded('ConsolePort_Config');
		if not configLoaded then
			configLoaded = LoadAddOn('ConsolePort_Config')
		end

		if configLoaded then
			configEnv = ConsolePortConfig:GetEnvironment()
			self.contentFrameLoaded = true;

			-- Initialize splash
			env.db.table.mixin(self.OverviewFrame, configEnv.Overview)
			self.OverviewFrame:OnLoad()

			-- Initialize grid
			env.db.table.mixin(self.GridFrame, CreateFromMixins(configEnv.CombosMixin, Grid))
			self.GridFrame:OnLoad(CreateFromMixins(configEnv.ComboMixin, Combo))
			env.db.Stack:AddFrame(self.GridFrame)
			env.db.Stack:AddFrame(self.EscapeButton)
		end
	end

	if self.showGridOnFocus then
		self.showGridOnFocus = nil;
		return self.GridFrame:Show()
	end

	self.GridFrame:Hide()
	self.OverviewFrame:Show()
end

---------------------------------------------------------------
-- Grid view
---------------------------------------------------------------
function Grid:OnLoad(mixin)
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingComboTemplate', mixin, nil, self.Child)
end

function Grid:OnHide()
	self:GetParent().EscapeButton:Hide()
end

function Grid:OnShow()
	local device, map = configEnv:GetActiveDeviceAndMap()
	local mods = configEnv:GetActiveModifiers()
	if not device or not map or not mods then
		return
	end

	local numMods = 0; for _ in pairs(mods) do numMods = numMods + 1; end;
	if (numMods % 4 ~= 0) then
		-- don't even bother with this if not using 2+ modifiers
		local parent = self:GetParent()
		parent:PreClick()
		parent:OnFocus()
		return
	end

	local rowOffset = (numMods / 4) * -60;

	local id, height, prev = 1, 0;
	for i=0, #map do
		local button = map[i].Binding;
		if ( device:IsButtonValidForBinding(button) ) then
			local modID = 1;
			for mod, keys in env.db.table.mpairs(mods) do
				local widget, newObj = self:Acquire(mod..button)
				if newObj then
					widget:SetSiblings(self.Registry)
					widget:SetDrawOutline(true)
					widget:RegisterForDrag('LeftButton')
					CPAPI.Start(widget)
				end

				local data = configEnv:GetHotkeyData(button, mod, 64, 32)
				local modstring = '';

				for i, mod in env.db.table.ripairs(data.modifier) do
					modstring = modstring .. ('|T%s:0:0:0:0:32:32:8:24:8:24|t'):format(mod)
				end

				widget.Modifier:SetText(modstring)
				widget:SetIcon(data.button)
				widget:SetID(id)
				widget:SetAttribute('combo', mod..button)
				widget:Show()
				if not prev then
					widget:SetPoint('TOPLEFT', 0, ((id-1) * rowOffset) -4)
					height = height + widget:GetHeight()
				elseif (modID == 5) then
					widget:SetPoint('TOPLEFT', 0, ((id) * rowOffset) -4 + 60)
				else
					widget:SetPoint('LEFT', prev, 'RIGHT', 0, 0)
				end

				prev, modID = widget, modID + 1;
			end

			id, prev = id + 1, nil;
		end
	end
	self:GetParent().EscapeButton:Show()
	self.Child:SetSize(self:GetWidth(), height)
end

---------------------------------------------------------------
-- Combo
---------------------------------------------------------------
local cachedAction, originalOwner;

function Combo:PlaceAction()
	PlaceAction(self:GetAttribute('action'))
	self:SetScript('OnEvent', self.OnEvent)
	cachedAction = nil;
	if originalOwner then
		originalOwner:Uncheck()
		originalOwner = nil;
	end
end

function Combo:OnReceiveDrag()
	if GetCursorInfo() and self:GetAttribute('action') then
		self:PlaceAction()
		if GetCursorInfo() then
			originalOwner = self;
			self:Check()
		else
			self:Uncheck()
		end
		return true;
	end
end

function Combo:OnDragStart()
	local actionID = self:GetAttribute('action')
	if not InCombatLockdown() and actionID then
		cachedAction, originalOwner = actionID, self;
		PickupAction(actionID)
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		self:SetScript('OnEvent', self.OnCombatHandle)
		self:Check()
		return true;
	end
end

function Combo:OnCombatHandle(event, ...)
	if (event == 'PLAYER_REGEN_DISABLED') and GetCursorInfo() then
		if originalOwner then
			originalOwner:PlaceAction()
		elseif cachedAction and not GetActionInfo(cachedAction) then
			PlaceAction(cachedAction)
			cachedAction = nil;
		end
	else
		self:OnEvent(event, ...)
	end
end

function Combo:OnClick()
	if not self:OnReceiveDrag() then
		if not self:OnDragStart() then
			self:Uncheck()
		end
	end

	if not self:GetAttribute('action') then
		self:Uncheck()
	end

	-- disable cursor if using interface cursor
	if env.db.Cursor:IsCurrentNode(self) and IsGamePadFreelookEnabled() then
		SetGamePadCursorControl(false)
	end
end
