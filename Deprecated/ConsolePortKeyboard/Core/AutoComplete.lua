local addOn, Language = ...
local Keyboard = ConsolePortKeyboard
---------------------------------------------------------------
-- Local resources
---------------------------------------------------------------
local function Union(str)
	local out = ""
	for s in str:gmatch(".") do
		if not out:find(s) then out = out .. s end
	end
	return out, out:len()
end

local strlower = strlower
local strfind = strfind

local pairs = pairs
local wipe = wipe

local tonumber = tonumber
local abs = abs

local class = select(2, UnitClass("player"))
local cc = RAID_CLASS_COLORS[class]

local Fade = ConsolePort:GetData().UIFrameFadeIn

local suggestions = {}

---------------------------------------------------------------
-- EditBox Auto complete widget
---------------------------------------------------------------
local Auto = CreateFrame("EditBox", "$parentAuto", Keyboard)
Auto:Disable()
Auto:SetPoint("CENTER", Keyboard, "CENTER", 0, -90)
Auto:SetSize(1, 1)
Auto.Text = Auto:CreateFontString("$parentTextCurrent", "BACKGROUND")
Auto.Text:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 16)
Auto.Text:SetShadowColor(0, 0, 0, 1)
Auto.Text:SetTextColor(0.75, 0.75, 0.75, 1)
Auto.Text:SetShadowOffset(2, -2)
Auto.Text:SetPoint("CENTER", Auto, 0, 0)

Auto.Previous = Auto:CreateFontString("$parentTextPrevious", "BACKGROUND")
Auto.Previous:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 16)
Auto.Previous:SetShadowColor(0, 0, 0, 1)
Auto.Previous:SetTextColor(0.75, 0.75, 0.75, 0.75)
Auto.Previous:SetShadowOffset(1, -2)
Auto.Previous:SetPoint("CENTER", Auto, 0, 30)

Auto.Next = Auto:CreateFontString("$parentTextNext", "BACKGROUND")
Auto.Next:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 16)
Auto.Next:SetShadowColor(0, 0, 0, 1)
Auto.Next:SetTextColor(0.75, 0.75, 0.75, 0.75)
Auto.Next:SetShadowOffset(1, -2)
Auto.Next:SetPoint("CENTER", Auto, 0, -30)

Auto.Backdrop = Auto:CreateTexture(nil, "BACKGROUND")
Auto.Backdrop:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Auto.Backdrop:SetBlendMode("ADD")
Auto.Backdrop:SetVertexColor(cc.r, cc.g, cc.b, 0.25)
Auto.Backdrop:SetAlpha(0)
Auto.Backdrop:SetPoint("CENTER", Auto, 0, 0)
Auto.Backdrop:SetSize(300, 24)

Auto.Icon = Auto:CreateTexture(nil, "ARTWORK")
Auto.Icon:SetPoint("RIGHT", Auto.Text, "LEFT", 0, 0)
Auto.Icon:SetSize(32, 32)
Auto.Icon:SetTexture(ConsolePort:GetData().ICONS.CP_T2)

Keyboard.Complete = Auto
Keyboard.CompleteIndex = 1

function Auto:OnTextSet()
	local text = self:GetText()
	Fade(self.Backdrop, 0.2, self.Backdrop:GetAlpha(), text:trim() == "" and 0 or 0.25)
	self.Icon:SetAlpha(text:trim() == "" and 0 or 1)
	for pattern, replacement in pairs(Language.Markers) do
		text = text:gsub(pattern:gsub("%%", "%%%%"), replacement)
	end
	self.Text:SetText(text)
end

function Auto:Hide()
	wipe(suggestions)
	Keyboard:SetSuggestions(1)
end

Auto:SetScript("OnTextSet", Auto.OnTextSet)
Auto:SetScript("OnHide", Auto.Hide)

---------------------------------------------------------------
-- EditBox Auto complete operations
---------------------------------------------------------------
function Keyboard:GetCurrentWord()
	local text = self.Focus and self.Focus:GetText()
	if text then
		local position = self.Focus:GetUTF8CursorPosition()
		local length = text:len()+1

		local startPos, endPos
		for i=position, 1, -1 do
			if not text:sub(i, i):match("[%a']") then
				startPos = i + 1
				break
			elseif i == 1 then
				startPos = i
			end
		end
		for i=position, length do
			if not text:sub(i, i):match("[%a']") then
				endPos = i-1
				break
			elseif i == length then
				endPos = i
			end
		end
		if startPos and endPos then
			local word = text:sub(startPos, endPos):trim()
			if not tonumber(word) and word ~= "" then
				return word, startPos, endPos
			end
		end
	end
end

function Keyboard:GetSuggestions()
	local word = self:GetCurrentWord()
	wipe(suggestions)
	if word then
		local isCapitalLetter = word:sub(0, 1):upper() == word:sub(0, 1)
		word = strlower(word)
		local length = word:len()
		local dictionary = self.Dictionary
		local chars, numChars = Union(word)

		local this, priority, valid

		-- Iterate through dictionary and push valid words to suggestion list
		for thisWord, thisWeight in pairs(dictionary) do
			valid = true

			-- skip exact matches and matches that are vastly longer than the union of input characters
			if thisWord == word or numChars * 4 < thisWord:len() then
				valid = false
			end

			-- check if word contains all characters to elicit a match
			for c in chars:gmatch(".") do
				if not strfind(thisWord, c) then
					valid = false
					break
				end
			end

			if valid then
				priority = 1

				this = {
					word = (isCapitalLetter and thisWord:sub(0, 1):upper() .. thisWord:sub(2) ) or thisWord,
					weight = thisWeight,
					match = strfind( thisWord, word ),
					length = abs( length - thisWord:len() )
				}

				-- calculate priority in relevance to already suggested words
				for index, compare in pairs(suggestions) do

					-- don't calculate order beyond the 20th index, just push to list
					if ( index >= 20 ) then
						break
					end

					-- fix: if the best suggestion was pushed first, make sure its priority isn't nudged down
					priority = #suggestions > 1 and index or 2

					-- words with literal matches have higher priority 
					if  ( this.match and not compare.match ) then
						break
					-- if both have literal match and this word is more favorable, or neither have literal match
					elseif 	( this.match and compare.match and ( this.match <= compare.match ) ) or
							( not this.match and not compare.match ) then

						-- if the next word is shorter, or equally long but has a higher weight
						if 	( this.length < compare.length or
							( this.length == compare.length and this.weight > compare.weight ) ) then
							break
						end

					end
				end
				tinsert( suggestions, priority, this )
			end
		end
	end
	self:SetSuggestions(1)
end

function Keyboard:SetSuggestions(newIndex)
	self.CompleteIndex = newIndex or self.CompleteIndex

	local Prev, Current, Next = self.Complete.Previous, self.Complete, self.Complete.Next
	local guessWord = suggestions[self.CompleteIndex] and suggestions[self.CompleteIndex].word

	Prev:SetText( suggestions[self.CompleteIndex-1] and suggestions[self.CompleteIndex-1].word  or "" )
	Next:SetText( suggestions[self.CompleteIndex+1] and suggestions[self.CompleteIndex+1].word  or "" )

	Current:SetText( guessWord  or "" )
	self.GuessWord = guessWord
end

function Keyboard:AUTOCOMPLETE()
	local current, startPos, endPos = self:GetCurrentWord()
	if current and self.Complete:GetText():trim() ~= "" then
		local isCapitalLetter = current:sub(0, 1) == current:sub(0, 1):upper()
		local replacement = self.GuessWord
		local length = current:len()
		local text = self.Focus and self.Focus:GetText()

		if text and startPos and endPos and replacement then
			if isCapitalLetter then
				replacement = replacement:sub(0, 1):upper() .. replacement:sub(2)
			end
			local first, second = text:sub(0, startPos-1), text:sub(endPos+1)
			self.Focus:SetText(first..replacement..second)
			self.Focus:SetCursorPosition(startPos+replacement:len())
		end
	end

end

function Keyboard:UP()
	self:SetSuggestions(self.CompleteIndex-1 >= 1 and self.CompleteIndex-1 or nil)
end

function Keyboard:DOWN()
	self:SetSuggestions(self.CompleteIndex+1 <= #suggestions and self.CompleteIndex+1 or nil)
end