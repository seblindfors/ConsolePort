local env = CPAPI.GetEnv(...);
---------------------------------------------------------------
local IconSelector = {}; env.IconSelector = IconSelector;
---------------------------------------------------------------
IconSelector.Template = 'CPConfigIconSelector';

---@class ConsolePortIconSelectInfo
---@field name        string  The name of the popup.
---@field owner       any     The owner of the popup, used in the callback.
---@field button1     string  The text for the first button (default: ACCEPT).
---@field button2     string  The text for the second button (default: CANCEL).
---@field hasEditBox  boolean If true, an edit box will be shown in the popup.
---@field initialText string  The initial text for the edit box.
---@field call fun(owner: any, icon: fileID, saveResult: boolean, editBoxText?: string)

function IconSelector:OnLoad()
	self.activeIconFilter = IconSelectorPopupFrameIconFilterTypes.All;
	self.IconHeader.Text:ClearAllPoints()
	self.IconHeader.Text:SetPoint('LEFT', 40, 0)
	self.IconHeader.Text:SetFontObject(GameFontNormalMed1)
	self:SetSize(508, 500)
	self:Update()
end

function IconSelector:GetFrame()
    return env.Frame;
end

function IconSelector:Update()
	local function IconFilterToIconTypes(filter)
		if ( filter == IconSelectorPopupFrameIconFilterTypes.All ) then
			return IconDataProvider_GetAllIconTypes();
		elseif (filter == IconSelectorPopupFrameIconFilterTypes.Spell) then
			return { IconDataProviderIconType.Spell };
		elseif (filter == IconSelectorPopupFrameIconFilterTypes.Item) then
			return { IconDataProviderIconType.Item };
		end
		return nil;
	end

	local function IsSelected(filterType)
		return self.activeIconFilter == filterType;
	end

	local function SetSelected(filterType)
		self.activeIconFilter = filterType;
		self.IconSelector.iconDataProvider:SetIconTypes(IconFilterToIconTypes(filterType));
		self.IconSelector:UpdateSelections()
		self:Update()
	end

	self.IconType.Dropdown:SetupMenu(function(dropdown, rootDescription)
		for key, filterType in pairs(IconSelectorPopupFrameIconFilterTypes) do
			local text = _G['ICON_FILTER_' .. strupper(key)];
			rootDescription:CreateRadio(text, IsSelected, SetSelected, filterType);
		end
	end)

	self.IconSelector:SetSelectedCallback(function(index)
		-- HACK: If we're clicking with the interface cursor,
		-- skip the need to hit accept and just set the icon.
		RunNextFrame(function()
			if not self.popup then return end;
			local button1 = self.popup.button1 or self.popup:GetButton1();
			local editBox = self.popup.editBox or self.popup:GetEditBox();
			button1:Enable();
			if editBox:IsShown() then return end;
			local cursorNode = ConsolePort:GetCursorNode()
			if ( cursorNode and cursorNode.selectionIndex == index ) then
				StaticPopup_OnClick(self.popup, 1) -- accept
			end
		end)
	end)
end

--- Shows a popup to select an icon from the icon selector.
---@param info ConsolePortIconSelectInfo The information for the icon selector popup.
---@return Frame popup The popup object.
function IconSelector:SetDataAndShow(info)
	local selector  = self.IconSelector;
	self:Show()
	local popup = CPAPI.Popup('ConsolePort_IconSelector', {
		text         = ''; -- HACK: text is required for the popup.
		button1      = info.button1 or ACCEPT;
		button2      = info.button2 or CANCEL;
		hasEditBox   = info.hasEditBox;
		hideOnEscape = true;
		enterClicksFirstButton = true;
		selectCallbackByIndex = true;
		OnShow = function(popup, data)
			local index = selector.iconDataProvider:GetIndexOfIcon(data.icon);
			selector:SetSelectedIndex(index);
			selector:ScrollToSelectedIndex();
			self.popup = popup;
			ConsolePort:RemoveInterfaceCursorFrame(self:GetFrame())

			local button1 = popup.button1 or popup:GetButton1();
			button1:SetEnabled(not not index)
			if info.hasEditBox and data.initialText then
				local editBox = popup.editBox or popup:GetEditBox();
				editBox:SetText(data.initialText)
			end
		end;
		OnAccept = function(popup, data)
			local index = selector:GetSelectedIndex()
			local icon = index and selector.iconDataProvider:GetIconByIndex(index);
			if icon then
				local editBox = popup.editBox or popup:GetEditBox();
				data.call(data.owner, icon, true, info.hasEditBox and editBox:GetText() or nil)
			end
		end;
		OnCancel = nop;
		OnHide = function(_, data)
			ConsolePort:AddInterfaceCursorFrame(self:GetFrame())
			ConsolePort:SetCursorNodeIfActive(data.owner)
			self.popup = nil;
		end;
	}, nil, nil, info, self)
	self.IconHeader.Text:SetText(info.name)
	return popup;
end