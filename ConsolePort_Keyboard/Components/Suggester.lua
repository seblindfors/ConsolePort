local Suggester, _, env = ConsolePortKeyboard.WordSuggester, ...;
local widgetPool, suggestions = CreateFramePool('Button', Suggester, 'ConsolePortKeyboardWordButton'), {};
---------------------------------------------------------------
local MAX_DISPLAY_ENTRIES, WIDGET_HEIGHT = 8, 20;
---------------------------------------------------------------
-- Auto correct handling
---------------------------------------------------------------

local function OnSuggestionsUpdatedCallback(result, iterator)
	local widgets, i = wipe(suggestions), 1;
	for word, weight in iterator(result) do
		local widget, newObj = widgetPool:Acquire()
		widget.Text:SetText(word)
		widget:Show()
		widgets[i], i = widget, i + 1;
		if i > MAX_DISPLAY_ENTRIES then
			break
		end
	end

	Suggester:SetHeight(#widgets * WIDGET_HEIGHT)
	local prev;
	for i, widget in ipairs(widgets) do
		widget:SetPoint('TOP', prev or Suggester, prev and 'BOTTOM' or 'TOP', 0, 0)
		prev = widget;
	end

	Suggester:OnSuggestionsChanged(result, iterator)
end

function Suggester:OnWordChanged(word)
	widgetPool:ReleaseAll()
	env:GetSpellCorrectSuggestions(word, env.Dictionary, OnSuggestionsUpdatedCallback)
end

function Suggester:OnSuggestionsChanged(result, iterator)
	self.curIndex, self.maxIndex = 1, #suggestions;
	self:SetIndex(self.curIndex)
end

function Suggester:SetDelta(delta)
	if self.curIndex and self.maxIndex then
		self:SetIndex(Clamp(self.curIndex + delta, 1, self.maxIndex))
	end
end

function Suggester:SetIndex(index)
	self.selectedWord, self.curIndex = nil, index;
	for i, widget in ipairs(suggestions) do
		widget.Hilite:SetAlpha(0)
	end
	local widget = suggestions[index];
	if widget then
		widget.Hilite:SetAlpha(1)
		self.selectedWord = widget.Text:GetText()
	end
end

function Suggester:GetSuggestion()
	return self.selectedWord;
end