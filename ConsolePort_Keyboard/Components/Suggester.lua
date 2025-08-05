local Suggester, _, env = ConsolePortKeyboard.WordSuggester, ...;
local widgetPool, suggestions = CreateFramePool('Frame', Suggester, 'CPKeyboardWordButton'), {};
---------------------------------------------------------------
local MAX_DISPLAY_ENTRIES, WIDGET_HEIGHT = 8, 20;
---------------------------------------------------------------
-- Auto correct handling
---------------------------------------------------------------

local function OnSuggestionsUpdatedCallback(result, iterator)
	local self = Suggester;

	local widgets, i = wipe(suggestions), 1;
	for word in iterator(result) do
		local widget, newObj = widgetPool:Acquire()
		if newObj then
			widget.Hilite:AddMaskTexture(self.Background.FillMask)
		end
		widget.Text:SetText(word)
		widget:Show()
		widgets[i], i = widget, i + 1;
		if i > MAX_DISPLAY_ENTRIES then
			break
		end
	end

	local mimeHeight = self.Mime:GetHeight();
	self:SetHeight(Clamp((#widgets + 1) * WIDGET_HEIGHT + mimeHeight, 100, 200))
	local prev = self.Mime;
	for row, widget in ipairs(widgets) do
		widget:SetPoint('TOP', prev, 'BOTTOM', 0, row == 1 and -8 or 0)
		prev = widget;
	end

	self:OnSuggestionsChanged()
end

function Suggester:OnWordChanged(word, focus)
	widgetPool:ReleaseAll()
	env:GetAutoCorrectSuggestions(word, OnSuggestionsUpdatedCallback, MAX_DISPLAY_ENTRIES)
	self.Mime:SetFocus(focus)
end

function Suggester:OnSuggestionsChanged()
	self.curIndex, self.maxIndex = 1, #suggestions;
	self:SetIndex(self.curIndex)
end

function Suggester:SetDelta(delta)
	if self.curIndex and self.maxIndex then
		local newIndex = self.curIndex + delta;
		if newIndex < 1 then return self:SetIndex(self.maxIndex) end;
		if newIndex > self.maxIndex then return self:SetIndex(1) end;
		self:SetIndex(Clamp(newIndex, 1, self.maxIndex))
	end
end

function Suggester:SetIndex(index)
	self.selectedWord, self.curIndex = nil, index;
	for i, widget in ipairs(suggestions) do
		widget.Hilite:Hide()
	end
	local widget = suggestions[index];
	if widget then
		widget.Hilite:Show()
		self.selectedWord = widget.Text:GetText()
	end
end

function Suggester:GetSuggestion()
	return self.selectedWord;
end

function Suggester:OnUpdate()
	self.Caret:Show()
end

---------------------------------------------------------------
local Mime = Suggester.Mime;
---------------------------------------------------------------

function Mime:SetFocus(focus)
	local isNewFocus = self.focus ~= focus;
	self.focus = focus;
	if not focus or not isNewFocus then return end;

	self.focusText, self.focusCursor = (function(editBox)
		local regions, text, cursor = { editBox:GetRegions() };
		for i = 1, 2 do -- text and cursor should be the first two.
			local region = regions[i];
			if region:IsObjectType('FontString') then
				text = region;
			elseif region:IsObjectType('Texture') then
				cursor = region;
			end
			if text and cursor then
				return text, cursor;
			end
		end
	end)(focus)

	local isValid = not not (self.focusText and self.focusCursor);
	if not isValid then return self:SetScript('OnUpdate', nil) end;

	self.Text:SetFontObject(self.focusText:GetFontObject())
	self.Cursor:SetSize(self.focusCursor:GetSize())
	self:SetHeight(Clamp(select(2, self.Text:GetFont()) + 4, 20, 40))

	self.throttle = 0;
	self:SetScript('OnUpdate', self.OnUpdate)
end

function Mime:OnUpdate(elapsed)
	self.throttle = self.throttle + elapsed;
	if self.throttle < 0.05 then return end;
	self.throttle = 0;

	if not (self.focusText and self.focusCursor) then return end
	self.Text:SetText(self.focusText:GetText())
	self.Text:SetSize(self.focusText:GetSize())

	-- Get the center positions of the focus text and cursor
	local tx, ty = self.focusText:GetCenter()
	local cx, cy = self.focusCursor:GetCenter()

	if tx and cx then
		-- Calculate the offset
		local dx, dy = cx - tx, cy - ty;

		-- Move the mimed text so its center matches the cursor's center
		self.Text:ClearAllPoints()
		self.Text:SetPoint("CENTER", self.Cursor, "CENTER", -dx, -dy)
	end
end

---------------------------------------------------------------
-- Init
---------------------------------------------------------------
Suggester.Fill:SetVertexColor(0.12, 0.12, 0.12, .75)