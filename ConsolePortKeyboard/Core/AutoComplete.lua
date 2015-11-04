local addOn, Language = ...
local Keyboard = ConsolePortKeyboard
---------------------------------------------------------------
-- Local resources
---------------------------------------------------------------
local function Copy(src)
	local copy
	if type(src) == "table" then
		copy = {}
		for key, value in next, src, nil do
			copy[Copy(key)] = Copy(value)
		end
		setmetatable(copy, Copy(getmetatable(src)))
	else
		copy = src
	end
	return copy
end

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

local Fade = ConsolePort:DB().UIFrameFadeIn

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
Auto.Text:SetShadowOffset(1, -2)
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

Keyboard.Complete = Auto
Keyboard.CompleteIndex = 1

function Auto:OnTextSet()
	local text = self:GetText()
	Fade(self.Backdrop, 0.2, self.Backdrop:GetAlpha(), text:trim() == "" and 0 or 0.25)
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
		local position = self.Focus:GetCursorPosition()
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

-- function Keyboard:GetSuggestions()
-- 	local word = self:GetCurrentWord()
-- 	wipe(suggestions)
-- 	if word then
-- 		word = strlower(word)
-- 		-- copy the dictionary and remove redundant suggestions
-- 		local dictionary = Copy(self.Dictionary)
-- 		for c in word:gmatch(".") do
-- 			for currentWord, weight in pairs(dictionary) do
-- 				-- if the current character does not exist or word is exact match
-- 				if not strfind(currentWord, c) or currentWord == word then
-- 					dictionary[currentWord] = nil
-- 				end
-- 			end
-- 		end

-- 		local length = word:len()
-- 		local pWord, pWeight, pMatch, nMatch, pLen, nLen, priority = "", 0, false, false, 100, 0, 1
		
-- 		for nWord, nWeight in pairs(dictionary) do
-- 			priority = 1
-- 			-- prioritize literal matches
-- 			nMatch = strfind(nWord, word) and true or false
-- 			-- prioritize strings with similar length
-- 			nLen = abs(length - nWord:len()) 

-- 			-- 1. if the literal string exists in this iteration but not in the previous iteration
-- 			-- 2. if this iteration and the previous iteration both have literal match, check weight
-- 			-- 3. if there's no literal match yet, check weight
-- 			if 	( nMatch and not pMatch ) or
-- 				( nMatch and pMatch and ( nLen < pLen or nWeight > pWeight )) or 
-- 				( not nMatch and not pMatch and ( nLen < pLen or nWeight > pWeight )) then

-- 				pLen = nLen
-- 				pWord = nWord
-- 				pMatch = nMatch
-- 				pWeight = nWeight
-- 				tinsert(suggestions, 1, nWord)

-- 			end
-- 		end

-- 		Auto:SetText(pWord)
-- 		self.GuessWord = pWord
-- 	end
-- 	self:SetSuggestions(1)
-- end

function Keyboard:GetSuggestions()
	local word = self:GetCurrentWord()
	wipe(suggestions)
	if word then
		word = strlower(word)
		-- copy the dictionary and remove redundant suggestions
		local length = word:len()
		local dictionary = Copy(self.Dictionary)
		local chars, numChars = Union(word)

		for c in chars:gmatch(".") do

			for currentWord, weight in pairs(dictionary) do
				-- if the current character does not exist or word is exact match
				if not strfind(currentWord, c) or currentWord == word or numChars * 4 < currentWord:len() then
					dictionary[currentWord] = nil
				end

			end
		end

		local nextMatch, nextLength
		local priority

		for nextWord, nextWeight in pairs(dictionary) do
			priority = nil

			nextMatch = strfind( nextWord, word )
			nextLength = abs( length - nextWord:len() )

			for index, check in pairs(suggestions) do

				-- not worth the overhead to sort beyond 20 matches
				if ( index >= 20 ) then
					break
				end

				priority = index

				if  ( nextMatch and not check.match ) then
					break
				elseif ( nextMatch and check.match and ( nextMatch <= check.match ) ) or ( not nextMatch and not check.match ) then
					if ( nextLength < check.length or ( nextLength == check.length and nextWeight > check.weight ) ) then
						break
					end
				end
			end

			if priority then
				tinsert( suggestions, priority, { word = nextWord, weight = nextWeight, match = nextMatch, length = nextLength} )
			else
				tinsert( suggestions, { word = nextWord, weight = nextWeight, match = nextMatch, length = nextLength} )
			end
		end

	end
	self:SetSuggestions(1)
end

function Keyboard:SetSuggestions(newIndex)
	local first, second, third = self.Complete.Previous, self.Complete, self.Complete.Next

	self.CompleteIndex = newIndex or self.CompleteIndex

	first:SetText( suggestions[self.CompleteIndex-1] and suggestions[self.CompleteIndex-1].word  or "" )
	second:SetText( suggestions[self.CompleteIndex] and suggestions[self.CompleteIndex].word  or "" )
	third:SetText( suggestions[self.CompleteIndex+1] and suggestions[self.CompleteIndex+1].word  or "" )

	self.GuessWord = suggestions[self.CompleteIndex] and suggestions[self.CompleteIndex].word
end

function Keyboard:AUTOCOMPLETE()
	local current, startPos, endPos = self:GetCurrentWord()
	if current and self.Complete:GetText():trim() ~= "" then
		local replacement = self.GuessWord
		local length = current:len()
		local text = self.Focus and self.Focus:GetText()

		if text and startPos and endPos and replacement then
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