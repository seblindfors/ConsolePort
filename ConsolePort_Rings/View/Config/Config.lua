local env, _, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Search = {};
---------------------------------------------------------------

function Search:OnLoad()
	env.SharedConfig.Env.Search.OnLoad(self)
	env:RegisterCallback('OnTabSelected', self.OnTabSelected, self)
	self.registry = env;
end

function Search:OnTabSelected(tabIndex, panels)
	self:SetText('')
	self:SetEnabled(tabIndex ~= panels.Rings)
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin, CPCombatHideMixin);
---------------------------------------------------------------
CPAPI.Props(Config)
	.Prop('DefaultTitle', L'Ring Manager')
	.Bool('Embedded',     false)

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)

	CPAPI.SpecializeOnce(self.Display, env.SharedConfig.Display)
	CPAPI.SpecializeOnce(self.Sets, env.SharedConfig.Sets)
	CPAPI.Specialize(self.Loadout, CPLoadoutContainerMixin, env.SharedConfig.Loadout)
	CPAPI.Specialize(self.Search, env.SharedConfig.Env.Search, Search)

	self.Panels = EnumUtil.MakeEnum('Rings', 'Loadout', 'Options');
	self.Tabs:AddTabs({
		[self.Panels.Rings]   = { text = L'Rings'   },
		[self.Panels.Loadout] = { text = L'Loadout' },
		[self.Panels.Options] = { text = OPTIONS,   },
	})
	self.Tabs:RegisterCallback(self.Tabs.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(self.Panels.Rings)

	env:RegisterCallback('OnBindSet',   self.OnBindSet, self)
	env:RegisterCallback('OnClearSet',  self.OnClearSet, self)
	env:RegisterCallback('OnDeleteSet', self.OnDeleteSet, self)
	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnAddNewSet', self.OnAddNewSet, self)
	env:RegisterCallback('OnSelectTab', self.OnSelectTab, self)
	env:RegisterCallback('OnSetUpdate', self.OnSetUpdate, self)
	env:RegisterCallback('OnRequestWipe', self.OnRequestWipe, self)
	env:RegisterCallback('OnAcquireControlButton', self.CatchButton, self)
	env:RegisterCallback('OnReleaseControlButton', self.FreeButton, self)

	local BindingCatcher = env.SharedConfig.Env.Mixin.BindingCatcher;
	self.Catcher = CreateFrame('Button', nil, self, BindingCatcher.Template)
	CPAPI.Specialize(self.Catcher, BindingCatcher)

	CPAPI.Start(self)
	tinsert(UISpecialFrames, self:GetName())
end

function Config:OnShow()
	if self:IsEmbedded() then
		self:SetScale(1)
	else
		FrameUtil.UpdateScaleForFit(self, 40, 80)
	end
	self:SetDefaultClosures()
	env:TriggerEvent('OnConfigShown', true)
	CPCombatHideMixin.OnShow(self)
end

function Config:OnHide()
	self:ReleaseClosures()
	env:TriggerEvent('OnConfigShown', false)
	CPCombatHideMixin.OnHide(self)
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
	self:CatchButton('PADLSHOULDER', self.OnTabDecrement, self)
	self:CatchButton('PADRSHOULDER', self.OnTabIncrement, self)
end

function Config:OnTabDecrement()
	if self.Tabs:Decrement() then return end;
	if self:IsEmbedded() then
		return env:TriggerEvent('OnHideEmbedded', -1)
	end
end

function Config:OnTabIncrement()
	if self.Tabs:Increment() then return end;
	local noSetSelected = self.Tabs:GetActiveTabIndex() == self.Panels.Rings;
	if noSetSelected then
		return env:TriggerEvent('OnFlashSets')
	end
	if self:IsEmbedded() then
		return env:TriggerEvent('OnHideEmbedded', 1)
	end
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
function Config:OnTabSelected(button, tabIndex)
	self.Sets:SetShown(tabIndex ~= self.Panels.Loadout)
	self.Loadout:SetShown(tabIndex == self.Panels.Loadout)
	env:TriggerEvent('OnTabSelected', tabIndex, self.Panels)
end

function Config:OnSelectTab(tabIndex)
	self.Tabs:SelectAtIndex(tabIndex)
end

function Config:OnSelectSet(elementData, setID, isSelected)
	self.currentSetID = isSelected and setID or nil;
	self:OnSetUpdate(setID, isSelected)
	self.Tabs:SetEnabled(self.Panels.Loadout, isSelected)
	self.Tabs:SetEnabled(self.Panels.Options, isSelected)
	self.Tabs:SetEnabled(self.Panels.Rings, true)
	if not isSelected then
		self.Tabs:SelectAtIndex(self.Panels.Rings)
	end
end

function Config:OnSetUpdate(setID, isSelected)
	self.Portrait.Icon:SetTexture(env:GetSetIcon(isSelected and setID))
	self.Portrait:Play()
	self.Name:SetText(
		isSelected and Container:GetBindingDisplayNameForSetID(setID)
		or self:GetDefaultTitle()
	);
end

function Config:SelectSet(setID, isSelected)
	self.Sets:SetData(env:GetData(), env:GetShared(), setID)
	env:TriggerEvent('OnSelectSet', nil, setID, isSelected)
end

---------------------------------------------------------------
-- Popups
---------------------------------------------------------------
function Config:OnAddNewSet(elementData, container, isAdding)
	if not isAdding then return end;
	local this = self;

	local function OnButtonReset()
		-- Skip passing the elementData so the add button resets
		env:TriggerEvent('OnAddNewSet', nil, container, false)
	end

	return CPAPI.Popup('ConsolePort_Rings_Add_Ring', {
		text = GEARSETS_POPUP_TEXT;
		button1 = BATTLETAG_CREATE;
		button2 = CANCEL;
		hasEditBox = 1;
		maxLetters = 16;
		OnShow = function(self)
			local editBox = self.editBox or self:GetEditBox();
			editBox:SetText(env:GetRingNameSuggestion())
			editBox:SetFocus()
		end;
		OnAccept = function(self)
			local editBox = self.editBox or self:GetEditBox();
			local setID   = env:CreateSet(editBox:GetText(), container)
			if not setID then
				return CPAPI.Log('Failed to add new ring with name %s, because it already exists.', setID)
			end
			OnButtonReset()
			this:SelectSet(setID, true)
		end;
		OnCancel = function(self)
			OnButtonReset()
			if this.currentSetID then
				this:SelectSet(this.currentSetID, true)
			end
		end;
		EditBoxOnTextChanged = function(self)
			local setID   = env:ValidateSetID(self:GetText())
			local parent  = self:GetParent()
			local button1 = parent.button1 or parent:GetButton1();
			if setID then
				self:SetText(setID)
				button1:Enable();
			else
				button1:Disable();
			end
		end;
		EditBoxOnEnterPressed = function(self)
			local parent  = self:GetParent()
			local button1 = parent.button1 or parent:GetButton1();
			if button1:IsEnabled() then
				StaticPopup_OnClick(parent, 1) -- accept
			end
		end;
	})
end

function Config:OnRequestWipe(setID, set, container, forceClear, forceDelete)
	local canDelete  = setID ~= CPAPI.DefaultRingSetID;
	local showClear  = forceClear or #set > 0;
	local showDelete = canDelete and (forceDelete or not showClear);

	local function DeleteSet()
		container[setID] = nil;
		self:SelectSet(nil, false)
		Container:RefreshAll()
	end

	local function ClearSet()
		wipe(set)
		self:SelectSet(setID, true)
		Container:RefreshAll()
	end

	if showDelete then
		return CPAPI.Popup('ConsolePort_Rings_Delete_Ring', {
			text     = L.REMOVE_RING_TEXT;
			button1  = REMOVE;
			button2  = CANCEL;
			OnAccept = DeleteSet;
		}, Container:GetBindingDisplayNameForSetID(setID))
	elseif showClear then
		return CPAPI.Popup('ConsolePort_Rings_Clear_Ring', {
			text     = L.CLEAR_RING_TEXT;
			button1  = RESET;
			button2  = CANCEL;
			button3  = canDelete and REMOVE or nil;
			OnAccept = ClearSet;
			OnAlt    = canDelete and DeleteSet or nil;
		}, Container:GetBindingDisplayNameForSetID(setID))
	end
end

function Config:OnBindSet(owner, setID, clearBinding)
	local bindingID = Container:GetBindingForSet(setID)

	if clearBinding then
		self.Catcher:ClearBindingsForID(bindingID)
		return SaveBindings(GetCurrentBindingSet())
	end

	self.Catcher:TryCatchBinding({
		text = L.SLOT_SET_BINDING;
		OnShow = function()
			self:PauseCatcher()
			ConsolePort:SetCursorNodeIfActive(owner)
		end;
		OnHide = function()
			self:ResumeCatcher()
		end;
	}, Container:GetBindingDisplayNameForSetID(setID), nil, {
		bindingID = bindingID;
	})
end

function Config:OnClearSet(_, setID)
	local set, container = env:GetSetContainers(setID)
	env:TriggerEvent('OnRequestWipe', setID, set, container, true, false)
end

function Config:OnDeleteSet(_, setID)
	local set, container = env:GetSetContainers(setID)
	env:TriggerEvent('OnRequestWipe', setID, set, container, false, true)
end

---------------------------------------------------------------
-- Trigger
---------------------------------------------------------------
env:RegisterCallback('ToggleConfig', function(self, setID, embed)
	if not self.Config then
		self.Config, env.SharedConfig.Env = CPAPI.CreateConfigFrame(
			Config, 'Frame', 'ConsolePortRingsConfig', UIParent, 'CPRingsConfig');
			Mixin(env.SharedConfig, env.SharedConfig.Env.Elements)
		self.Config:OnLoad()
	end
	self.Config:SetEmbedded(embed)
	self.Config:Show()
	self.Config:SelectSet(setID, not not setID)
end, env)