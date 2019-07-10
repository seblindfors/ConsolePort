---------------------------------------------------------------
-- Atlas.lua: Predefined textures, backdrops, widgets
---------------------------------------------------------------
-- A collection of widget constructors, backdrops, textures
-- and stuff that can be reused for various purposes.
---------------------------------------------------------------
local _, db = ...
local path = "Interface\\AddOns\\ConsolePort\\Textures\\"
local class = select(2, UnitClass("player"))
local cc = RAID_CLASS_COLORS[class]
---------------------------------------------------------------

local function CreateAtlasFrame(name, parent, templates, buttonTemplate)
	local frame
	if templates then
		frame = CreateFrame("Frame", name, parent or UIParent, templates)
	else
		frame = CreateFrame("Frame", name, parent or UIParent)
		frame.Close = CreateFrame("Button", nil, frame, buttonTemplate)
		frame.Close:SetScript("OnClick",  function() frame:Hide() end)
		frame.Close:HookScript("OnClick", function() PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE) end)
	end
	return frame
end

local function CreateAtlasButton(name, parent, secure, template)
	local templates
	if template then
		templates = template
	end
	if secure and template then
		templates = templates..", SecureActionButtonTemplate"
	elseif secure then
		templates = "SecureActionButtonTemplate"
	end
	return CreateFrame("Button", name, parent, templates)
end
---------------------------------------------------------------
db.Atlas = {}
local Atlas = db.Atlas
---------------------------------------------------------------
Atlas.Backdrops = {
	Full = {
		bgFile 		= path.."Window\\Gradient",
		edgeFile 	= path.."Window\\EdgefileBig.blp",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	},
	FullSmall = {
		bgFile 		= path.."Window\\Gradient",
		edgeFile 	= path.."Window\\EdgefileBig.blp",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	TooltipBorder = {
		bgFile 		= path.."Window\\Gradient",
		edgeFile 	= "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize 	= 16,
		insets 		= {left = 4, right = 4,	top = 4, bottom = 4}
	},
	Tooltip = {
		bgFile 		= "Interface\\Tooltips\\UI-Tooltip-Background.blp",
		edgeFile 	= path.."Window\\EdgefileBig.blp",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Border = {
		edgeFile 	= path.."Window\\EdgefileBig.blp",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	},
	BorderSmall = {
		edgeFile 	= path.."Window\\EdgefileBig.blp",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	BorderInset = {
		edgeFile 	= path.."Window\\EdgefileInset.blp",
		edgeSize 	= 8,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Talkbox = {
		bgFile 		= path.."Window\\TalkboxBG.blp",
		edgeFile 	= path.."Window\\EdgefileTalkbox.blp",
		edgeSize 	= 32,
		insets 		= { left = 32, right = 32, top = 32, bottom = 32 }
	},
}
---------------------------------------------------------------
Atlas.Overlays = {
	MAGE 			= "Artifacts-MageArcane-BG",
	PALADIN 		= "Artifacts-Paladin-BG",
	WARRIOR 		= "Artifacts-Warrior-BG",
	DRUID 			= "Artifacts-Druid-BG",
	DEATHKNIGHT 	= "Artifacts-DeathKnightFrost-BG",
	HUNTER 			= "Artifacts-Hunter-BG",
	PRIEST 			= "Artifacts-Priest-BG",
	ROGUE 			= "Artifacts-Rogue-BG",
	SHAMAN 			= "Artifacts-Shaman-BG",
	WARLOCK 		= "Artifacts-Warlock-BG",
	MONK 			= "Artifacts-Monk-BG",
	DEMONHUNTER		= "Artifacts-DemonHunter-BG",
}
---------------------------------------------------------------
Atlas.GetCC = function() return cc.r, cc.g, cc.b end
Atlas.GetOverlay = function(otherClass) return Atlas.Overlays[otherClass or class] end
---------------------------------------------------------------
Atlas.GetNormalizedCC = function()
	local col = {cc.r, cc.g, cc.b}
	local high = 0
	for _, c in pairs(col) do
		if c > high then
			high = c
		end
	end
	local diff = ( 1 - high )
	for i=1, 3 do
		col[i] = col[i] + diff
	end
	return unpack(col)
end
---------------------------------------------------------------
Atlas.SetFutureButtonStyle = function(button, width, height, classColored)
	assert(type(button) == "table" and (button:IsObjectType("Button") or button:IsObjectType("CheckButton")))

	button.Cover = button.Cover or button:CreateTexture("$parentCover", "ARTWORK")
	button.Cover:SetAtlas("groupfinder-button-cover")
	button.Cover:SetAllPoints()

	button.SelectedTexture = button.SelectedTexture or button:CreateTexture("$parentSelectedTexture", "OVERLAY")
	button.SelectedTexture:Hide()
	button.SelectedTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
	button.SelectedTexture:SetPoint("CENTER")
	button.SelectedTexture:SetTexCoord(0.00195313, 0.63867188, 0.76953125, 0.83007813)
	button.SelectedTexture:SetBlendMode("ADD")

	button.HighlightTexture = button.HighlightTexture or button:CreateTexture("$parentHighlightTexture", "HIGHLIGHT")
	button.HighlightTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
	button.HighlightTexture:SetPoint("CENTER")
	button.HighlightTexture:SetTexCoord(0.00195313, 0.63867188, 0.70703125, 0.76757813)

	button:SetHighlightTexture(button.HighlightTexture)

	button.Label = button.Label or button:GetFontString() or button:CreateFontString("$parentLabel", nil, "GameFontNormal")
	button.Label:SetJustifyH("CENTER")
	button.Label:SetPoint("CENTER")
	button.Label:SetText(button:GetText())
	button:SetFontString(button.Label)

	button:SetSize(width or 240, height or 46)
	button.Cover:SetSize(width or 240, height or 46)
	button.SelectedTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)
	button.HighlightTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)

	if classColored then
		local highlight = path.."Window\\Highlight"
		button.SelectedTexture:SetTexCoord(0, 0.640625, 0, 1)
		button.SelectedTexture:SetTexture(highlight)
		button.SelectedTexture:SetVertexColor(cc.r, cc.g, cc.b, 1)
	end
end
---------------------------------------------------------------
Atlas.GetArtOverlay = function(self)
	local overlay = Atlas.GetOverlay()
	local texture = GetAtlasInfo(overlay)
	local maxWidth, maxHeight, texSize = 722, 617, 1024
	local maxCoordX, maxCoordY, centerCoordX, centerCoordY = 
			maxWidth / texSize, maxHeight / texSize,
			( maxWidth / 2 ) / texSize, ( maxHeight / 2) / texSize

	self.Overlay = self:CreateTexture(nil, "ARTWORK", nil, 7)
	self.Overlay:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -16)
	self.Overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 16)
	self.Overlay:SetBlendMode("BLEND")
	self.Overlay:SetAlpha(.1)
	self.Overlay:SetAtlas(Atlas.GetOverlay())

	local function FixAspectRatio(self)
		local width, height = self:GetSize()
		local left, right, top, bottom
		if width > height then
			local newHeight = ( height / width ) * maxWidth
			left, right = 0, maxCoordX
			top = centerCoordY - ( (newHeight / 2) / texSize )
			bottom = centerCoordY + ( (newHeight / 2 ) / texSize )
		else
			local newWidth = ( width / height ) * maxHeight
			top, bottom = 0, maxCoordY
			left = centerCoordX - ( ( newWidth / 2 ) / texSize )
			right = centerCoordX + ( ( newWidth / 2 ) / texSize )
		end
		self.Overlay:SetAtlas(nil)
		self.Overlay:SetTexture(texture)
		self.Overlay:SetTexCoord(left, right, top, bottom)
	end

	self:HookScript("OnShow", FixAspectRatio)
	self:HookScript("OnSizeChanged", FixAspectRatio)
	
	return self.Overlay
end
---------------------------------------------------------------
Atlas.GetFutureButton = function(name, parent, secure, buttonAtlas, width, height, classColored)
	local button = CreateAtlasButton(name, parent, secure, "CPUIListButtonTemplate") -- "LFGListCategoryTemplate"
	button.Label:ClearAllPoints()
	button.Label:SetJustifyH("CENTER")
	button.Label:SetPoint("CENTER", 0, 0)
	button:SetScript("OnClick", nil)
	button:ClearAllPoints()
	button:SetSize(width or 240, height or 46)
	button.Cover:SetSize(width or 240, height or 46)
	button.SelectedTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)
	button.HighlightTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)
	button.Icon:SetSize(width or 240, height or 46)
	if buttonAtlas then
		button.Icon:SetTexture(buttonAtlas[1])
		button.Icon:SetTexCoord(unpack(buttonAtlas, 2))
		button.Icon:SetAlpha(0.25)
	else
		button.Icon:SetTexture(nil)
	end
	if classColored then
		local highlight = path.."Window\\Highlight"
		button.SelectedTexture:SetTexCoord(0, 0.640625, 0, 1)
		button.SelectedTexture:SetTexture(highlight)
		button.SelectedTexture:SetVertexColor(cc.r, cc.g, cc.b, 1)
	end
	return button
end
---------------------------------------------------------------
Atlas.GetGlassWindow  = function(name, parent, templates, classColored, buttonTemplate)
	local self = CreateAtlasFrame(name, parent, templates, buttonTemplate)
	local assets = path.."Window\\Assets"

	self:SetBackdrop(Atlas.Backdrops.Border)

	self.Close.Texture = self.Close:CreateTexture(nil, "ARTWORK")
	self.Close.Texture:SetTexture(assets)
	self.Close.Texture:SetTexCoord(0, 0.40625, 0.5625, 1)
	self.Close.Texture:SetAllPoints(self.Close)
	self.Close:SetNormalTexture(self.Close.Texture)
	self.Close:SetSize(13, 14)
	self.Close:SetPoint("TOPRIGHT", -20, -20)

	self.BG = self:CreateTexture(nil, "BACKGROUND")
	self.BG:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -16)
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 16)
	self.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	self.BG:SetBlendMode("ADD")

	self.Tint = self:CreateTexture(nil, "BACKGROUND", nil, 2)
	self.Tint:SetTexture(path.."Window\\BoxTint")
	self.Tint:SetPoint("TOPLEFT", 16, -16)
	self.Tint:SetPoint("BOTTOMRIGHT", self, "RIGHT", -16, 0)
	self.Tint:SetBlendMode("ADD")
	self.Tint:SetAlpha(0.75)

	if classColored then
		self.BG:SetVertexColor(cc.r, cc.g, cc.b, 0.25)
	else
		self.BG:SetVertexColor(1, 1, 1, 0.25)
	end

	return self
end
---------------------------------------------------------------
Atlas.CreateFrame = function(name, parent, templates, buttonTemplate, artCorners, noOverlay)
	local self = CreateAtlasFrame(name, parent, templates, buttonTemplate)
	local assets = path.."Window\\Assets"

	if self.Close then
		self.Close.Texture = self.Close:CreateTexture(nil, "ARTWORK")
		self.Close.Texture:SetTexture(assets)
		self.Close.Texture:SetTexCoord(0, 0.40625, 0.5625, 1)
		self.Close.Texture:SetAllPoints(self.Close)
		self.Close:SetNormalTexture(self.Close.Texture)
		self.Close:SetSize(13, 14)
		self.Close:SetPoint("TOPRIGHT", -32, -32)
	end

	self.TopLine = self:CreateTexture(nil, "BACKGROUND", nil, 7)
	self.TopLine:SetPoint("TOPLEFT", 16, -16)
	self.TopLine:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -16, -20)


	local gradient = {
		"HORIZONTAL",
	   cc.r, cc.g, cc.b, 1,
	   1, 1, 1, 0,
	}

	local gBase = 0.3
	local gMulti = 1.1

	local classGradient = {
		"HORIZONTAL",
		(cc.r + gBase) * gMulti, (cc.g + gBase) * gMulti, (cc.b + gBase) * gMulti, 1,
		1 - (cc.r - gBase) * gMulti, 1 - (cc.g - gBase) * gMulti, 1 - (cc.b - gBase) * gMulti, 1,
	}

	if artCorners then
		local region
		region = self:CreateTexture(nil, "ARTWORK", nil, -7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(132/1024, 198/1024, 16/1024, 84/1024)
			region:SetSize(66, 68)
			region:SetPoint("TOPLEFT", 8, -10)
		region = self:CreateTexture(nil, "ARTWORK", nil, -7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(198/1024, 264/1024, 16/1024, 84/1024)
			region:SetSize(66, 68)
			region:SetPoint("TOPRIGHT", -9, -10)
		region = self:CreateTexture(nil, "ARTWORK", nil, -7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(0/1024, 66/1024, 16/1024, 84/1024)
			region:SetSize(66, 68)
			region:SetPoint("BOTTOMLEFT", 8, 10)
		region = self:CreateTexture(nil, "ARTWORK", nil, -7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(66/1024, 132/1024, 16/1024, 84/1024)
			region:SetSize(66, 68)
			region:SetPoint("BOTTOMRIGHT", -9, 10)
	end

	self.Tint = self:CreateTexture(nil, "BACKGROUND", nil, 2)
	self.Tint:SetTexture(path.."Window\\BoxTint")
	self.Tint:SetPoint("TOPLEFT", 16, -16)
	self.Tint:SetPoint("BOTTOMRIGHT", self, "RIGHT", -16, 0)
	self.Tint:SetBlendMode("ADD")
	self.Tint:SetAlpha(0.75)

	self.BG = self:CreateTexture(nil, "BACKGROUND", nil, 0)
	self.BG:SetTexture(path.."Window\\Gradient")
	self.BG:SetGradientAlpha(unpack(classGradient))
	self.BG:SetPoint("TOPLEFT", 16, -16)
	self.BG:SetPoint("BOTTOMRIGHT", -16, 16)

	self.TopLine:SetColorTexture(1,1,1)
	self.TopLine:SetGradientAlpha(unpack(gradient))

	self:SetBackdrop(Atlas.Backdrops.Border)

	if not noOverlay then
		Atlas.GetArtOverlay(self)
	end

	return self
end
---------------------------------------------------------------
Atlas.ScrollMeta = {}

function Atlas.ScrollMeta:Refresh(numVisible)
	numVisible = numVisible or #self.Buttons
	if self.Child then
		for i, button in pairs(self.Buttons) do
			button:SetShown(i <= numVisible)
		end
		local newHeight = numVisible * self.stepSize
		self.Child:SetHeight(newHeight)
		return newHeight
	else
		return self:GetParent():Refresh(numVisible)
	end
end

function Atlas.ScrollMeta:AddButton(button, xOffset, yOffset)
	if not self.Child then
		self:GetParent():AddButton(button, xOffset, yOffset)
	elseif button then
		button:SetParent(self.Child)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", xOffset or 0, - #self.Buttons * self.stepSize + (yOffset or 0))
		self.Buttons[#self.Buttons + 1] = button
		return true
	end
end

Atlas.GetScrollFrame = function(name, parent, config)
	local self = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
	assert(config, "Atlas.GetScrollFrame: No config provided.")
	---------------------------------
	local 	parentKey, size, noMeta, 
			childKey, childWidth, existingChild,
			stepSize, scrollStep,
			customBackdrop, noBackdrop =
			--------------------------------
			config.parentKey, config.size, config.noMeta,
			config.childKey, config.childWidth, config.existingChild,
			config.stepSize, config.scrollStep, 
			config.backdrop, config.noBackdrop
			---------------------------------

	local child = existingChild or CreateFrame("Frame", "$parent"..(childKey or "ScrollChild"), self)
	local bar = self.ScrollBar
	local thumb = bar:GetThumbTexture()

	if not noBackdrop then
		local backdrop = CreateFrame("Frame", self:GetName().."Backdrop", parent)
		backdrop:SetBackdrop(customBackdrop or Atlas.Backdrops.Border)
		backdrop:SetPoint("TOPLEFT", self, 'TOPLEFT', -16, 16)
		backdrop:SetPoint("BOTTOMRIGHT", self, 'BOTTOMRIGHT', 38, -16)
		backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
		backdrop:SetShown(self:IsVisible())
		self.Backdrop = backdrop
		self:HookScript("OnShow", function(self)
			self.Backdrop:Show()
		end)
		self:HookScript("OnHide", function(self)
			self.Backdrop:Hide()
		end)
	end

	if parentKey then parent[parentKey] = self end
	if childKey then self[childKey] = child end

	self.Child = child
	self.Child:SetParent(self)
	self:SetScrollChild(child)
	self:SetToplevel(true)

	child:SetWidth(childWidth or 0)

	self.stepSize = stepSize or 32

	bar.Thumb = thumb
	thumb = bar:GetThumbTexture()
	thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	thumb:SetTexCoord(0, 1, 0, 1)
	thumb:SetSize(18, 34)

	bar.scrollStep = scrollStep or self.stepSize
	bar:ClearAllPoints()
	bar.ignoreNode = true
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
	bar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, 0)
	bar.ScrollUpButton:SetAlpha(0)
	bar.ScrollUpButton:ClearAllPoints()
	bar.ScrollDownButton:SetAlpha(0)
	bar.ScrollDownButton:ClearAllPoints()

	if not noMeta then
		self.Buttons = {}
		child.Buttons = self.Buttons

		self.AddButton = Atlas.ScrollMeta.AddButton
		child.AddButton = self.AddButton

		self.Refresh = Atlas.ScrollMeta.Refresh
		child.Refresh = self.Refresh
	end

	return self
end
---------------------------------------------------------------
Atlas.BindingMeta = {
	Bindings = {},
	Headers = {},
}

local bindPrefix = "BINDING_NAME_" -- this prefix is used for actual bindings
local sortPrefix = "BINDING_" -- this prefix is used for headers inside categories
local bindFormat = "%s\n|cFF757575%s|r"
local bindingCounter = 0

function Atlas.BindingMeta:GetBindingInfo()
	if self.reserved then
		return self.reserved
	else
		local binding = self.binding
		if binding then
			local bindingText = binding and _G[bindPrefix..binding]
			local header, name = not self.omitHeader and binding and self.Headers[binding]

			local id = ConsolePort:GetActionID(binding)
			-- this binding has an action ID
			if id then
				-- re-calculate an action ID based on the current action page
				local loc = db.TUTORIAL.BIND
				local actionpage = MainMenuBarArtFrame:GetAttribute("actionpage") or 1
				id = id <= 12 and id + ( ( actionpage - 1 ) * 12 ) or id

				local texture = GetActionTexture(id)

				local actionType, actionID, subType = GetActionInfo(id)
				
				if actionType == "spell" and actionID then
					name = GetSpellInfo(actionID) or loc.SPELL
				elseif actionType == "item" and actionID then
					name = GetItemInfo(actionID) or loc.ITEM
				elseif actionType == "macro" then
					name = GetActionText(id) and GetActionText(id)..loc.MACRO
				elseif actionType == "companion" then
					name = loc[subType]
				elseif actionType == "summonmount" then
					name = loc.MOUNT
				elseif actionType == "equipmentset" then
					name = actionID..loc.EQSET
				end

				-- if the action has a name, suffix the binding and omit the header
				name = name and format(bindFormat, name, bindingText)

				if name then
					-- at this point there's a name and texture for the action ID
					return name, texture
				elseif texture then
					if bindingText then
						name = header and _G[header]
						name = name and format(bindFormat, bindingText, name) or bindingText 
					end
					return name, texture
				else
					name = header and _G[header]
					return name and format(bindFormat, bindingText, name) or bindingText
				end
			-- this binding does not have an action ID, just return the binding and header names
			elseif bindingText then
				name = header and _G[header]
				return name and format(bindFormat, bindingText, name) or bindingText
			-- at this point, this is not an usual binding. this is most likely a click binding.
			else
				name = gsub(binding, "(.* ([^:]+).*)", "%2")
				return name
			end
		else
			return self.default
		end
	end
end

function Atlas.BindingMeta:Refresh()
	if bindingCounter ~= GetNumBindings() then
		self:RefreshBindings()
	end

	local name, texture = self:GetBindingInfo()
	
	if name and texture then
		self.Mask:Show()
		self:SetText(name)
		self.SetIcon(self.Icon, texture)
	elseif texture then
		self.Mask:Show()
		self:SetText(self.default)
		self.SetIcon(self.Icon, texture)
	elseif name then
		self.Mask:Hide()
		self.Icon:SetTexture()
		self:SetText(name)
	end
end

function Atlas.BindingMeta:RefreshBindings()
	local numBindings = GetNumBindings()
	-- check if the bindings have been updated since the last run (bindings can be added, but not removed)
	if numBindings ~= bindingCounter then
		local bindings = self.Bindings
		local headers = self.Headers

		-- wipe all current bindings, since indices may have changed
		wipe(bindings)
		wipe(headers)

		for i=1, numBindings do
			local id, header = GetBinding(i)

			-- link bindings to their respective header, so reverse lookup can be performed
			headers[id] = header

			local binding = _G[bindPrefix..id]
			local name = binding or _G[sortPrefix..id]
			-- if the binding has a designated header
			if header then
				-- use the header title if there is one.
				local hTitle = _G[header] or header
				local category = bindings[hTitle]
				if not category then
					category = {}
					bindings[hTitle] = category
				end
				-- add binding to its designated category table, omit binding index if not an actual binding
				category[#category + 1] = {name = name, binding = id}
			-- else check that this isn't (1) a header which isn't blank and is not a controller header or (2) just a header
			elseif ( id:match("^HEADER") and not id:match("^HEADER_BLANK") and not id:match("^CP_") ) or ( not id:match("^HEADER") ) then
				-- at this point, the binding definitely belongs in the "Other" category
				local otherCategory = bindings[BINDING_HEADER_OTHER]
				if not otherCategory then
					otherCategory = {}
					bindings[BINDING_HEADER_OTHER] = otherCategory
				end
				-- add binding to the "Other" table, omit binding index if not an actual binding
				otherCategory[#otherCategory + 1] = {name = name, binding = id}
			end
		end
		-- scrub base controller bindings, since they're not relevant.
		bindings["ConsolePort "] = nil
		-- include hidden bindings
		bindings[db.TUTORIAL.BIND.MAINCATEGORY] = ConsolePort:GetCustomBindings()
		-- update/add the counter
		bindingCounter = numBindings
	end
	return self.Bindings, self.Headers
end

Atlas.GetBindingMetaButton = function(name, parent, config)
	assert(config, "Atlas.GetBindingMetaButton: No config provided.")
	---------------------------------
	local 	width, height, templates, hitRects,
			justifyH, textWidth, textPoint,
			iconPoint, iconSpaceX, iconSpaceY,
			useButton, buttonTexture, buttonPoint,
			binding, default, anchor = 
	---------------------------------
			config.width, config.height, config.templates, config.hitRects,
			config.justifyH, config.textWidth, config.textPoint,
			config.iconPoint, config.iconSpaceX, config.iconSpaceY,
			config.useButton, config.buttonTexture, config.buttonPoint,
			config.binding, config.default, config.anchor
	---------------------------------
	local self = CreateFrame("Button", name, parent, templates)
	local text = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local icon = self:CreateTexture(nil, "ARTWORK", nil, 7)
	local mask = self:CreateTexture(nil, "OVERLAY", nil, 7)

	self.Icon = icon
	self.Text = text
	self.Mask = mask

	self:SetSize(width or 200, height or 30)

	self.default = default or db.TUTORIAL.BIND.NOTASSIGNED
	self.omitHeader = config.omitHeader

	self:SetFontString(text)
	self:SetText(self.default)

	text:SetWidth(textWidth or width or 200)
	text:SetTextHeight(12)
	text:SetSpacing(2)
	text:SetWordWrap(true)
	text:SetJustifyH(justifyH or "LEFT")

	icon:SetSize(30, 30)

	self.SetIcon = SetPortraitToTexture

	if hitRects then
		self:SetHitRectInsets(unpack(hitRects))
	end

	if useButton then
		local button = self:CreateTexture(nil, "OVERLAY")
		button:SetSize(30, 30)
		button:SetTexture(buttonTexture)
		if buttonPoint then
			local point, relativePoint, xOffset, yOffset = unpack(buttonPoint)
			button:SetPoint(point, self, relativePoint, xOffset, yOffset)
		end
		self.ButtonTexture = button
	end
	if iconPoint then
		local point, relativePoint, xOffset, yOffset = unpack(iconPoint)
		icon:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end	
	if textPoint then
		local point, relativePoint, xOffset, yOffset = unpack(textPoint)
		text:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end
	if anchor then
		local point, relativePoint, xOffset, yOffset = unpack(anchor)
		self.customCursorAnchor = {point, self, relativePoint, xOffset, yOffset}
	end

	mask:SetPoint("CENTER", icon, "CENTER", 0, 0)
	mask:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
	mask:SetSize(32, 32)
	mask:Hide()

	for k, v in pairs(Atlas.BindingMeta) do
		self[k] = v
	end
	
	return self
end

---------------------------------------------------------------

Atlas.GetRoundActionButton = function(name, isCheck, parent, size, templates, notSecure)
	if InCombatLockdown() and not notSecure then
		error("Atlas.GetRoundActionButton: SecureActionButtonTemplate cannot be inherited in combat!", 2)
	elseif not name or isCheck == nil or not parent then
		error("Usage: Atlas.GetRoundActionButton(name, isCheck, parent[ [, size,] templates]): Buttons without name or parent not supported!", 2)
	else
		local template

		if notSecure then
			template = "ActionButtonTemplate"
		else
			template = "ActionButtonTemplate, SecureActionButtonTemplate"
		end
		
		if templates and type(templates) == "string" then
			template = template..", "..templates
		elseif templates then
			error("Usage: Atlas.GetRoundActionButton(name, isCheck, parent[ [, size,] templates]): Templates must be of string type!", 2)
		end

		local button = CreateFrame(isCheck and "CheckButton" or "Button", name, parent, template)

		button.icon:SetMask("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Mask")
		button.PushedTexture = button:GetPushedTexture()


		button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.PushedTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")

		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint("CENTER", 0, 0)


		button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

		if isCheck then
			button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
		end

		button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")

		local size = size or 64

		button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
		button.cooldown:ClearAllPoints()
		button.cooldown:SetPoint("CENTER")
		button.cooldown:SetSize(size, size)
		button.cooldown:SetDrawEdge(false)

		button:SetSize(size, size)
		button.NormalTexture:SetSize(size, size)
		button.PushedTexture:SetSize(size, size)

		button.ShadowTexture = button:CreateTexture(nil, "BACKGROUND")
		button.ShadowTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\NormalShadow")
		button.ShadowTexture:SetSize(size * (82 / 64), size * (82 / 64))
		button.ShadowTexture:SetPoint("CENTER", 0, -6)
		button.ShadowTexture:SetAlpha(0.75)

		return button
	end
end
