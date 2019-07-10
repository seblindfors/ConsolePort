---------------------------------------------------------------
-- Advanced data browser for ConsolePort
---------------------------------------------------------------
-- This browser is an overengineered way of dealing with the ton
-- of functionality that CP has to offer, some of which shouldn't
-- necessarily be visible or part of a regular configuration window.

local db = ConsolePort:GetData() 
local mixin, spairs = db.table.mixin, db.table.spairs
local FramePool, Field, Active = {}, {}, 0
local WindowMixin, Browser, Adder = {}

local DisplayValue, GetField, ClearFields, RefreshBrowser, GetAffectedTablesString, merge
local LoadCurrentData, LoadDataFromTable, ImportData
local loadstring, pcall = loadstring, pcall

-- Coroutine thread (expecting large data sets, handle in chunks)
local ThreadManager = CreateFrame('Frame')
local threadYieldCount = 8 -- lower: frame drops, higher: longer load time
local thread

ThreadManager:Hide()
ThreadManager:SetScript('OnUpdate', function(self)
	if not thread then self:Hide() end
	if thread and coroutine.status(thread) ~= 'dead' then coroutine.resume(thread)
	else thread = nil end
end)

-- Global height, Base width
local _H, _W = 42, 550

-- Data type RGB
local colors = {
	number = {0.53, 1, 73},
	string = {1, 1, 0.47},
	table = {1, 0.6, 0},
	boolean = {0.98, 0.15, 0.45},
}

-- Data type compilers
local compilers = {
	string 	= [[return [=[%s]=] ]],
	boolean = [[return %s]],
	number 	= [[return tonumber(%s)]],
	table 	= [[return {%s}]],
	manual 	= [[return %s]],
}

-- Tables to show in the browser; label = global
local tables = {
	['Action Bar'] =  'ConsolePortBarSetup',
	['Action Bar Manifest'] =  'ConsolePortBarManifest',
	['Bindings'] =  'ConsolePortBindingSet',
	['General settings'] =  'ConsolePortSettings',
	['Mouse & camera'] =  'ConsolePortMouse',
	['Shared data'] =  'ConsolePortCharacterSettings',
	['UI Frames'] =  'ConsolePortUIFrames',
	['User interface'] =  'ConsolePortUIConfig',
	['Binding set'] = false,
}

-- Icon format (prefix to keys to clarify what a button ID translates to)
local iconFormat = ('|T%s:24:24:0:0|t ')
local modifierToIdentifier = {
	['CTRL-'] = iconFormat:format(db.ICONS.CP_M2 or '');
	['SHIFT-'] = iconFormat:format(db.ICONS.CP_M1 or '');
	['CTRL-SHIFT-'] = (iconFormat:trim() .. iconFormat):format(db.ICONS.CP_M1 or '', db.ICONS.CP_M2 or '');
}

function GetAffectedTablesString(data)
	local formatter = '|TInterface\\Scenarios\\ScenarioIcon-Check:0|t %s \n'
	local str = ''
	if type(data) == 'table' then
		for id, tbl in spairs(data) do
			str = str .. formatter:format(id)
		end
	end
	return str
end

function RefreshBrowser()
	Browser:UpdateHeight()
end

function ImportData(serialized)
	local data = ConsolePort:Deserialize(serialized or '')
	if type(data) == 'table' then
		for k, v in pairs(data) do
			if tables[k] == nil then
				return
			end
		end
		return data
	end
	return
end

function merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

function ClearFields(refresh)
	if thread then return end
	Active = 0
	wipe(Browser.Buttons)
	for _, frame in pairs(FramePool) do
		frame:ClearAllPoints()
		frame:SetParent(Browser)
		frame:Hide()
		frame.SavedVariable = nil
		frame.StaticWidth = nil
		if frame.Buttons then
			wipe(frame.Buttons)
		end
	end
	if refresh then
		RefreshBrowser()
	end
end

function GetField(parent, key, val)
	parent = parent or Browser
	Active = Active + 1

	local field = FramePool[Active]
	if not field then
		FramePool[Active] = CreateFrame('Button', nil, parent)
		field = FramePool[Active]
		field:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

		field.Label = field:CreateFontString(nil, 'ARTWORK','GameFontNormal')
		field.Label:SetPoint('TOPLEFT', _H, -12)
		field.Label:SetJustifyH('LEFT')
		field:SetFontString(field.Label)

		field.Value = CreateFrame('EditBox', nil, field, 'InputBoxTemplate')
		field.Value:SetPoint('TOPRIGHT', -32, -4)
		field.Value:SetJustifyH('LEFT')
		field.Value:SetAutoFocus(false)
		field.Value.ignore = true
		field.Value:SetSize(200, 32)
		field.Value:HookScript('OnEditFocusGained', function(self)
			self:SetTextColor(1, 1, 1)
		end)
		field.Value:HookScript('OnEditFocusLost', function(self)
			if field:CompileValue() then
				self:SetTextColor(1, 1, 1)
			else
				self:SetTextColor(1, 0.25, 0.25)
			end
		end)
		field.Value:SetScript('OnEnterPressed', EditBox_ClearFocus)

		field.Key = CreateFrame('EditBox', nil, field, 'InputBoxTemplate')
		field.Key:SetPoint('TOPLEFT', 42, -4)
		field.Key:SetJustifyH('LEFT')
		field.Key:SetAutoFocus(false)
		field.Key.ignore = true
		field.Key:SetSize(200, 32)
		field.Key:SetScript('OnShow', function(self) field.Label:Hide() end)
		field.Key:SetScript('OnHide', function(self) field.Label:Show() end)
		field.Key:HookScript('OnEditFocusGained', function(self)
			self.backup = field.key
			self:SetText(field.key)
			self:SetTextColor(1, 1, 1)
		end)
		field.Key:HookScript('OnEditFocusLost', function(self)
			field:SetValue(self.backup or self:GetText(), field.val)
			self:Hide()
			self.backup = nil
		end)
		field.Key:HookScript('OnEnterPressed', function(self)
			self.backup = nil
			EditBox_ClearFocus(self)
		end)
		field.Key:HookScript('OnEscapePressed', EditBox_ClearFocus)
		field.Key:Hide()

		field:SetBackdrop(db.Atlas.Backdrops.FullSmall)

		field.ExpOrColl = CreateFrame('Button', nil, field)
		field.ExpOrColl:SetSize(16, 16)
		field.ExpOrColl:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
		field.ExpOrColl:SetPoint('TOPLEFT', 12, -12)
		field.ExpOrColl.ignore = true
		field.ExpOrColl:Hide()

		field.ExpOrColl:SetNormalTexture([[Interface\Buttons\UI-MinusButton-Up]])
		field.ExpOrColl:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Down]])
		field.ExpOrColl:SetDisabledTexture([[Interface\Buttons\UI-PlusButton-Disabled]])

		field.Add = CreateFrame('Button', nil, field)
		field.Add:SetSize(10, 10)
		field.Add:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
		field.Add:SetPoint('TOPRIGHT', -32, -12)
		field.Add.ignore = true
		field.Add:Hide()

		field.Add:SetNormalTexture([[Interface\PaperDollInfoFrame\Character-Plus]])
		field.Add:SetPushedTexture([[Interface\PaperDollInfoFrame\Character-Plus]])

		field.Add:SetScript('OnClick', function(self)
			if Adder:IsVisible() and Adder:GetParent() == field then
				local compiled, errorVal = loadstring(compilers.manual:format(Adder.Value:GetText() or ''))
				local numKey = Adder.Key:GetNumber()
				local key = (numKey ~= nil and numKey ~= 0 and numKey) or Adder.Key:GetText():trim()
				if compiled then
					local returnval = compiled()
					if returnval ~= nil then
						DisplayValue(field, key, returnval)
					end
				end
			else
				Adder:SetParent(field)
				Adder:SetPoint('TOPRIGHT', -42, 0)
				Adder:Show()
			end
		end)

		field.Add:SetScript('OnEnter', function(self) 
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:SetText(ADD)
			GameTooltip:Show()
		end)
		field.Add:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)

		field.Remover = CreateFrame('Button', nil, field)
		field.Remover:SetSize(12, 12)
		field.Remover:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
		field.Remover:SetNormalTexture([[Interface\Buttons\UI-StopButton]])
		field.Remover:SetPoint('TOPRIGHT', -12, -12)
		field.Remover.ignore = true
		field.Remover:SetScript('OnEnter', function(self) 
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:SetText((field:IsEnabled() and (field.SavedVariable and 'Exclude' or 'Remove')) or 'Undo')
			GameTooltip:Show()
		end)
		field.Remover:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)

		field.Remover:SetScript('OnClick', function(self)
			field:Toggle(not field:IsEnabled())
		end)

		field.Line = field:CreateTexture()
		field.Line:SetColorTexture(0.25, 0.25, 0.25)
		field.Line:SetPoint('TOPLEFT', 6, -8)
		field.Line:SetPoint('BOTTOMLEFT', 6, 8)
		field.Line:SetWidth(1)
		field.Line:Hide()

		field.ExpOrColl:SetScript('OnClick', function(self, button)
			field:CollapseOrExpand()
		end)

		mixin(field, Field)
	end

	parent:AddChild(field)
	field:SetSize(_W, _H)
	field:Toggle(true)
	field:Show()

	field:SetValue(key, val)

	return field
end

function DisplayValue(parent, key, val)
	local field = GetField(parent, key, val)
	if type(val) == 'table' then
		field.ExpOrColl:Show()
		local counter, yieldAt = 0, (threadYieldCount - 1)
		for k, v in spairs(val) do
			DisplayValue(field, k, v)
			counter = (counter + 1) % threadYieldCount
			if yieldAt == counter then
				coroutine.yield() -- yield in recursive settings
			end
		end
		field.Value:Hide()
		field:Collapse()
	else
		field.Value:Show()
		field.ExpOrColl:Hide()
	end
	return field
end

function LoadCurrentData()
	if thread then return end
	thread = coroutine.create(function()
		local first
		for key, ref in spairs(tables) do
			local val = _G[ref]
			if val then
				local global = DisplayValue(nil, key, db.table.copy(val))
				global.SavedVariable = ref
				global.StaticWidth = 870
				global:SetWidth(870)
				if not first then first = global
					first:ClearAllPoints()
					first:SetPoint('TOPLEFT', 16, -16)
				end
			end
		end
	end)
	ThreadManager:Show()
end

function LoadDataFromTable(tbl)
	if thread then return end
	thread = coroutine.create(function()
		local first
		for key, sub in spairs(tbl) do
			if type(sub) == 'table' then
				local global = DisplayValue(nil, key, sub)
				global.SavedVariable = tables[key]
				global.StaticWidth = 870
				global:SetWidth(870)
				if not first then first = global 
					first:ClearAllPoints()
					first:SetPoint('TOPLEFT', 16, -16)
					
				end
			end
		end
	end)
	ThreadManager:Show()
end

function Field:Toggle(enable)
	if enable then
		self.Value:Enable()
		self.ExpOrColl:Enable()
		self:Enable()
		self.Value:SetTextColor(1, 1, 1)
		self.Label:SetTextColor(unpack(colors[self.type] or {1, 1, 1}))
		self.Remover:SetNormalTexture([[Interface\Buttons\UI-StopButton]])
	else
		self.Remover:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
		self.Value:Disable()
		self.ExpOrColl:Disable()
		self:Disable()
		self.Value:SetTextColor(0.25, 0.25, 0.25)
		self.Label:SetTextColor(0.25, 0.25, 0.25)
		if self.type == 'table' then
			self:Collapse()
		end
	end
end

function Field:SetValue(key, val)
	local vt = type(val)
	local kt = type(key)
	self.key = key
	self.val = val
	self.type = vt
	self.ktype = kt

	if key then
		local modifierIcon = modifierToIdentifier[key]
		local icon = db.ICONS[key]
		if modifierIcon then
			self:SetText(modifierIcon..key)
		elseif icon then
			self:SetText(iconFormat:format(icon)..key)
		else
			self:SetText(key == '' and '|cff757575<nomod>|r' or key)
		end
	end

	self.Label:SetTextColor(unpack(colors[vt]))

	if val ~= nil and ( vt ~= 'table' ) then
		self.Value:SetText(tostring(val))
	else
		self.Value:SetText('')
	end
end

function Field:OnEnter()
	local key = strlen(self.key) == 0 and '<empty string key>' or self.key
	local color = colors[self.type] or {1, 1, 1}
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:AddLine(key, unpack(color))
	GameTooltip:AddLine('|cffffffffValue type:|r ' .. self.type)
	if self.type == 'table' then
		if not self.SavedVariable then
			GameTooltip:AddLine('|cffffffffKey type:|r ' .. self.ktype)
		else
			GameTooltip:AddLine('|cffffffffValue:|r ' .. self.SavedVariable)
		end
		GameTooltip:AddLine('<Left click to expand/collapse>', .5, .5, .5)
	else
		GameTooltip:AddLine('|cffffffffValue:|r ' .. tostring(self.val))
		GameTooltip:AddLine('|cffffffffKey type:|r ' .. self.ktype)
		GameTooltip:AddLine('<Left click to modify value>', .5, .5, .5)
	end
	if not self.SavedVariable then
		GameTooltip:AddLine('<Right click to modify key>', .5, .5, .5)
	end
	GameTooltip:Show()
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint('BOTTOMRIGHT', Browser:GetParent(), 'BOTTOMRIGHT', 16, 0)
end

function Field:OnLeave()
	GameTooltip:Hide()
end

function Field:OnClick(button)
	if button == 'LeftButton' then
		if self.type == 'table' then 
			self:CollapseOrExpand()
		elseif self.Value:HasFocus() then
			self.Value:ClearFocus()
		else
			self.Value:SetFocus()
		end
	elseif button == 'RightButton' and not self.SavedVariable then
		self.Key:Show()
		self.Key:SetFocus()
	end
end

function Field:CompileValue()
	local compiled, errorMsg = loadstring(compilers[self.type]:format(self.Value:GetText() or ''))
	if compiled then
		local pcallOK, returnVal = pcall(compiled)
		if pcallOK then
			return returnVal
		else
			print('Error in execution:', self.key, self.val)
			print(returnVal)
			return
		end
	end
	print('Error compiling:', self.key, self.val)
	print(errorMsg or returnVal)
end

function Field:Compile()
	if not self:IsEnabled() then 
		return
	elseif self.Buttons and #self.Buttons > 0 then
		local t = {}
		for _, field in self:GetButtons() do
			local key, val = field:Compile()
			if key and val ~= nil then
				t[key] = val
			end
		end
		return self.key, t
	else
		return self.key, self:CompileValue()
	end
end

function Field:Collapse()
	self.collapsed = true
	self:SetWidth(self.StaticWidth or _W)
	self.Line:Hide()
	self.Add:Hide()
	self.ExpOrColl:SetNormalTexture([[Interface\Buttons\UI-PlusButton-Up]])
	self.ExpOrColl:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
	for _, button in self:GetButtons() do
		button:Hide()
	end
	RefreshBrowser()
end

function Field:Expand()
	self.collapsed = false
	self:SetWidth(self.StaticWidth or (_W + _H + 16) )
	self.Line:Show()
	self.Add:Show()
	self.ExpOrColl:SetNormalTexture([[Interface\Buttons\UI-MinusButton-Up]])
	self.ExpOrColl:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Down]])
	for _, button in self:GetButtons() do
		button:Show()
	end
	RefreshBrowser()
end

function Field:CollapseOrExpand()
	if self:IsCollapsed() then
		self:Expand()
	else
		self:Collapse()
	end
end

function Field:IsCollapsed() return self.collapsed end

function Field:AddChild(child)
	if not self.Buttons then self.Buttons = {} end
	local numEntries = #self.Buttons
	self.Buttons[numEntries + 1] = child
	child:SetParent(self)
	child:ClearAllPoints()

	local prev = self.Buttons[numEntries]
	if prev then
		child:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, 0)
	else
		child:SetPoint('TOPLEFT', self, 'TOPLEFT', _H, -_H)
	end
	RefreshBrowser()
end

function Field:UpdateHeight(recursive)
	if not recursive then
		Adder:Hide()
	end
	local height = 0
	for _, button in self:GetButtons() do
		height = height + button:UpdateHeight(true)
	end
	if self:IsCollapsed() then
		self:SetHeight(_H)
		return _H
	else
		self:SetHeight(height + _H)
		return height + _H
	end
end

function Field:GetButtons() return pairs(self.Buttons or {}) end

function WindowMixin:OnHide()
	ClearFields()
end

function WindowMixin:OnShow()
	ClearFields()
	LoadCurrentData()
end

ConsolePortOldConfig:AddPanel({
	name = 'Advanced',
	header = ADVANCED_LABEL, 
	mixin = WindowMixin,
	noDefault = true,
	onLoad = function(self, core)
		self.Browser = db.Atlas.GetScrollFrame('$parentBrowser', self, {
			childKey = 'List',
			childWidth = 900,
			stepSize = _H,
		})
		self.Browser:SetPoint('TOPLEFT', 32, -32)
		self.Browser:SetPoint('BOTTOMRIGHT', -52, 82)

		Browser = self.Browser.Child
		Browser.IsEnabled = function() return true end
		Browser.CompileValue = function() return end
		Browser.Compile = Field.Compile
		Browser.AddChild = Field.AddChild
		Browser.SetValue = Field.SetValue
		Browser.GetButtons = Field.GetButtons
		Browser.UpdateHeight = Field.UpdateHeight
		Browser.IsCollapsed = Field.IsCollapsed

		Adder = CreateFrame('Frame', nil, Browser)
		Adder:SetSize(350, _H)
		Adder:SetBackdrop(db.Atlas.Backdrops.FullSmall)

		Adder:SetScript('OnHide', function(self)
			self.Key:SetText('')
			self.Value:SetText('')
		end)

		Adder.Close = CreateFrame('Button', nil, Adder, 'UIPanelCloseButton')
		Adder.Close:SetPoint('RIGHT', -2, 0)

		Adder.Value = CreateFrame('EditBox', nil, Adder, 'InputBoxTemplate')
		Adder.Value:SetPoint('TOPRIGHT', -32, -4)
		Adder.Value:SetJustifyH('LEFT')
		Adder.Value:SetAutoFocus(false)
		Adder.Value.ignore = true
		Adder.Value:SetSize(100, 32)

		Adder.Value.Label = Adder.Value:CreateFontString(nil, 'ARTWORK', 'GameFontDisable')
		Adder.Value.Label:SetPoint('RIGHT', Adder.Value, 'LEFT', -12, 0)
		Adder.Value.Label:SetText('Value')

		Adder.Key = CreateFrame('EditBox', nil, Adder, 'InputBoxTemplate')
		Adder.Key:SetPoint('RIGHT', Adder.Value, 'LEFT', -50, 0)
		Adder.Key:SetJustifyH('LEFT')
		Adder.Key:SetAutoFocus(false)
		Adder.Key.ignore = true
		Adder.Key:SetSize(100, 32)

		Adder.Key.Label = Adder.Key:CreateFontString(nil, 'ARTWORK', 'GameFontDisable')
		Adder.Key.Label:SetPoint('RIGHT', Adder.Key, 'LEFT', -12, 0)
		Adder.Key.Label:SetText('Key')

		local bW, bH = 187, 36

		local function OnEnter(self) GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT') GameTooltip:SetText(self.tooltipText) end
		local function OnLeave(self) GameTooltip:Hide() end

		self.Load = db.Atlas.GetFutureButton('$parentLoad', self, nil, nil, bW, bH)
		self.Load:SetPoint('BOTTOMLEFT', 24, 24)
		self.Load:SetText('Load profile data')
		self.Load.tooltipText = 'Load your complete profile data into the browser.'
		self.Load:SetScript('OnEnter', OnEnter)
		self.Load:SetScript('OnLeave', OnLeave)
		self.Load:SetScript('OnClick', function(self) 
			ClearFields()
			LoadCurrentData()
		end)

		self.Compile = db.Atlas.GetFutureButton('$parentCompile', self, nil, nil, bW, bH)
		self.Compile:SetPoint('LEFT', self.Load, 'RIGHT', 0, 0)
		self.Compile:SetText('Recompile')
		self.Compile.tooltipText = 'Reorganizes your loaded data; excluded values are removed and remaining values are sorted.'
		self.Compile:SetScript('OnEnter', OnEnter)
		self.Compile:SetScript('OnLeave', OnLeave)
		self.Compile:SetScript('OnClick', function(self)
			local _, data = Browser:Compile()
			if data then
				ClearFields()
				LoadDataFromTable(data)
			end
		end)

		self.Apply = db.Atlas.GetFutureButton('$parentApply', self, nil, nil, bW, bH)
		self.Apply:SetPoint('LEFT', self.Compile, 'RIGHT', 0, 0)
		self.Apply:SetText('Apply changes')
		self.Apply.tooltipText = 'Apply your loaded data. Use Merge if you only want to change specific values.'
		self.Apply:SetScript('OnEnter', OnEnter)
		self.Apply:SetScript('OnLeave', OnLeave)
		self.Apply:SetScript('OnClick', function()
			local _, data = Browser:Compile()
			if data then
				StaticPopupDialogs['CONSOLEPORT_ADVANCED'] = {
					text = db.TUTORIAL.SLASH.ADVANCED_DATA:format(GetAffectedTablesString(data)),
					button1 = ACCEPT,
					button2 = CANCEL,
					button3 = 'Merge',
					showAlert = true,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
					enterClicksFirstButton = true,
					exclusive = true,
					OnAlt = function(_, data)
						for id, tbl in pairs(data) do
							local gID = tables[id]
							if gID then
								local gTbl = _G[gID]
								if gTbl then
									_G[gID] = merge(gTbl, tbl)
								end
							end
						end
						ReloadUI()
					end,
					OnAccept = function(_, data)
						for id, tbl in pairs(data) do
							local gID = tables[id]
							if gID then
								_G[gID] = tbl
							end
						end
						ReloadUI()
					end,
					OnCancel = core.ClearPopup,
				}
				core:ShowPopup('CONSOLEPORT_ADVANCED', nil, nil, data)
			end
		end)

		self.Import = db.Atlas.GetFutureButton('$parentImport', self, nil, nil, bW, bH)
		self.Import:SetPoint('LEFT', self.Apply, 'RIGHT', 0, 0)
		self.Import:SetText('Import')
		self.Import.tooltipText = 'Import serialized data from an external source.'
		self.Import:SetScript('OnEnter', OnEnter)
		self.Import:SetScript('OnLeave', OnLeave)
		self.Import:SetScript('OnClick', function()
			core:Import(function(data)
				ClearFields()
				if data then
					LoadDataFromTable(data)
				end
			end)
		end)

		self.Export = db.Atlas.GetFutureButton('$parentExport', self, nil, nil, bW, bH)
		self.Export:SetPoint('LEFT', self.Import, 'RIGHT', 0, 0)
		self.Export:SetText('Export selected')
		self.Export.tooltipText = 'Export serialized data so that it can be imported on another client.'
		self.Export:SetScript('OnEnter', OnEnter)
		self.Export:SetScript('OnLeave', OnLeave)
		self.Export:SetScript('OnClick', function()
			local _, data = Browser:Compile()
			if data then
				core:Export(data)
			end
		end)
	end
})

function ConsolePort:Export(data)
	local serialized = self:Serialize(data)
	if serialized then
		StaticPopupDialogs['CONSOLEPORT_EXPORTADV'] = {
			text = db.TUTORIAL.SLASH.ADVANCED_EXPORT,
			button1 = CLOSE,
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			hasEditBox = 1,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAccept = self.ClearPopup,
			OnCancel = self.ClearPopup,
			OnShow = function(self)
				self.editBox:SetText(serialized)
			end,
		}
		self:ShowPopup('CONSOLEPORT_EXPORTADV', GetAffectedTablesString(data))
	end
end

function ConsolePort:Import(acceptCallback, onChangeCallback)
	StaticPopupDialogs['CONSOLEPORT_IMPORTADV'] = {
		text = db.TUTORIAL.SLASH.ADVANCED_IMPORT_A,
		button1 = ACCEPT,
		button2 = CANCEL,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		hasEditBox = 1,
		enterClicksFirstButton = true,
		exclusive = true,
		OnShow = function(self)
			self.button1:Disable()
		end,
		OnAccept = function(self)
			local data = ImportData(self.editBox:GetText())
			if data and acceptCallback then
				acceptCallback(data)
			end
		end,
		OnCancel = self.ClearPopup,	
		EditBoxOnTextChanged = onChangeCallback or function(self)
			local data = ImportData(self:GetText())
			local parent = self:GetParent()
			if data then
				parent.button1:Enable()
				parent.text:SetText(db.TUTORIAL.SLASH.ADVANCED_IMPORT_B:format(GetAffectedTablesString(data)))
				StaticPopup_Resize(parent, 'CONSOLEPORT_IMPORTADV')
				return
			end
			parent.button1:Disable()
			parent.text:SetText(db.TUTORIAL.SLASH.ADVANCED_IMPORT_A)
			StaticPopup_Resize(parent, 'CONSOLEPORT_IMPORTADV')
		end,
	}
	self:ShowPopup('CONSOLEPORT_IMPORTADV')
end