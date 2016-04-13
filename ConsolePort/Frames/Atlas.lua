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

local function CreateAtlasFrame(name, parent, secure, buttonTemplate)
	local frame
	if secure then
		frame = CreateFrame("Frame", name, parent or UIParent, "SecureHandlerBaseTemplate")
		frame.Close = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate"..(buttonTemplate and ", "..buttonTemplate or ""))
		frame:WrapScript(frame.Close, "OnClick", [[
			self:GetParent():Hide()
		]])
	else
		frame = CreateFrame("Frame", name, parent or UIParent)
		frame.Close = CreateFrame("Button", nil, frame, buttonTemplate)
		frame.Close:SetScript("OnClick",  function() frame:Hide() end)
	end
	frame.Close:HookScript("OnClick", function() PlaySound("SPELLBOOKCLOSE") end)
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
---------------------------------------------------------------
db.Atlas.Backdrops = {
	Full = {
		bgFile 		= path.."Window\\Gradient",
		edgeFile 	= path.."Window\\EdgefileBig",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	},
	FullSmall = {
		bgFile 		= path.."Window\\Gradient",
		edgeFile 	= path.."Window\\EdgefileBig",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Tooltip = {
		bgFile 		= "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile 	= path.."Window\\EdgefileBig",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Border = {
		edgeFile 	= path.."Window\\EdgefileBig",
		edgeSize 	= 32,
		insets 		= {left = 16, right = 16,	top = 16, bottom = 16}
	},
	BorderSmall = {
		edgeFile 	= path.."Window\\EdgefileBig",
		edgeSize 	= 16,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	BorderInset = {
		edgeFile 	= path.."Window\\EdgefileInset",
		edgeSize 	= 8,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	}
}
---------------------------------------------------------------
db.Atlas.Overlays = {
	MAGE 			= {[62]  = "bg-mage-arcane", 			[63]  = "bg-mage-fire", 		[64]  = "bg-mage-frost"},
	PALADIN 		= {[65]  = "bg-paladin-holy", 			[66]  = "bg-paladin-protection",[70]  = "bg-paladin-retribution"},
	WARRIOR 		= {[71]  = "bg-warrior-arms", 			[72]  = "bg-warrior-fury", 		[73]  = "bg-warrior-protection"},
	DRUID 			= {[102] = "bg-druid-balance", 			[103] = "bg-druid-cat",			[104] = "bg-druid-bear", [105] = "bg-druid-restoration"},
	DEATHKNIGHT 	= {[250] = "bg-deathknight-blood", 		[251] = "bg-deathknight-frost", [252] = "bg-deathknight-unholy"},
	HUNTER 			= {[253] = "bg-hunter-beastmaster",		[254] = "bg-hunter-marksman", 	[255] = "bg-hunter-survival"},
	PRIEST 			= {[256] = "bg-priest-discipline", 		[257] = "bg-priest-holy", 		[258] = "bg-priest-shadow"},
	ROGUE 			= {[259] = "bg-rogue-assassination", 	[260] = "bg-rogue-combat", 		[261] = "bg-rogue-subtlety"},
	SHAMAN 			= {[262] = "bg-shaman-elemental", 		[263] = "bg-shaman-enhancement",[264] = "bg-shaman-restoration"},
	WARLOCK 		= {[265] = "bg-warlock-affliction", 	[266] = "bg-warlock-demonology",[267] = "bg-warlock-destruction"},
	MONK 			= {[268] = "bg-monk-brewmaster", 		[269] = "bg-monk-battledancer", [270] = "bg-monk-mistweaver"},
	DEMONHUNTER		= {}--{[000] = "bg-demonhunter-", 			[000] = "bg-demonhunter-"},
}
---------------------------------------------------------------
db.Atlas.GetCC = function() return cc.r, cc.g, cc.b end
db.Atlas.GetOverlay = function() return GetSpecialization() and db.Atlas.Overlays[class][GetSpecializationInfo(GetSpecialization())] end
---------------------------------------------------------------
db.Atlas.Hex2RGB = function(hex, inPercent)
	if hex then
	    hex = hex:gsub("#","")
	    if inPercent then
	    	return 	tonumber("0x"..hex:sub(1,2)) / 255,
					tonumber("0x"..hex:sub(3,4)) / 255,
					tonumber("0x"..hex:sub(5,6)) / 255
		else
			return 	tonumber("0x"..hex:sub(1,2)),
					tonumber("0x"..hex:sub(3,4)),
					tonumber("0x"..hex:sub(5,6))
		end
	end
end
---------------------------------------------------------------
db.Atlas.SetGlassStyle = function(self, classColored, alpha)
	self:SetBackdrop(db.Atlas.Backdrops.Border)
	self.BG = self.BG or self:CreateTexture(nil, "BACKGROUND")
	self.BG:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8)
	self.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	self.BG:SetBlendMode("ADD")

	if classColored then
		self.BG:SetVertexColor(cc.r, cc.g, cc.b, alpha or 0.25)
	else
		self.BG:SetVertexColor(1, 1, 1, alpha or 0.25)
	end
end
---------------------------------------------------------------
db.Atlas.SetGlassInsetStyle = function(self, classColored, alpha)
	self:SetBackdrop(db.Atlas.Backdrops.Border)
	self.BG = self.BG or self:CreateTexture(nil, "BACKGROUND")
	self.BG:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8)
	self.BG:SetTexture(path.."Window\\Inset")
	self.BG:SetBlendMode("ADD")

	if classColored then
		self.BG:SetVertexColor(cc.r, cc.g, cc.b, alpha or 0.25)
	else
		self.BG:SetVertexColor(1, 1, 1, alpha or 0.25)
	end
end
---------------------------------------------------------------
db.Atlas.SetFutureButtonStyle = function(button, width, height, classColored, buttonAtlas, oldLabel, oldIcon)
	assert(type(button) == "table" and (button:IsObjectType("Button") or button:IsObjectType("CheckButton")))

	button.Icon = button.icon or button.Icon or oldIcon or button:CreateTexture("$parentIcon", "BACKGROUND")
	button.Icon:SetPoint("CENTER")

	button.Cover = button.Cover or button:CreateTexture("$parentCover", "ARTWORK")
	button.Cover:SetAtlas("groupfinder-button-cover")
	button.Cover:SetAllPoints()

	button.SelectedTexture = button.SelectedTexture or button:CreateTexture("$parentSelectedTexture", "OVERLAY")
	button.SelectedTexture:Hide()
	button.SelectedTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
	button.SelectedTexture:SetPoint("CENTER")
	button.SelectedTexture:SetTexCoord(0.00195313, 0.63867188, 0.76953125, 0.83007813)

	button.HighlightTexture = button.HighlightTexture or button:CreateTexture("$parentHighlightTexture", "HIGHLIGHT")
	button.HighlightTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
	button.HighlightTexture:SetPoint("CENTER")
	button.HighlightTexture:SetTexCoord(0.00195313, 0.63867188, 0.70703125, 0.76757813)

	button:SetHighlightTexture(button.HighlightTexture)

	button.Label = button.Label or button:CreateFontString("$parentLabel", nil, "GameFontNormal")
	button.Label:SetJustifyH("CENTER")
	button.Label:SetPoint("CENTER")
	button.Label:SetText(button:GetText())
	button:SetFontString(button.Label)

	button:SetSize(width or 240, height or 46)
	button.Cover:SetSize(width or 240, height or 46)
	button.SelectedTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)
	button.HighlightTexture:SetSize(width or 240, height and height*0.7828 or 46*0.7828)
	button.Icon:SetSize(width or 240, height or 46)
	if buttonAtlas then
		local texture, left, right, top, bottom = unpack(buttonAtlas)
		button.Icon:SetTexture(texture)
		button.Icon:SetTexCoord(left, right, top, bottom)
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
end
---------------------------------------------------------------
db.Atlas.GetFutureButton = function(name, parent, secure, buttonAtlas, width, height, classColored)
	local button = CreateAtlasButton(name, parent, secure, "LFGListCategoryTemplate")
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
		local texture, left, right, top, bottom = unpack(buttonAtlas)
		button.Icon:SetTexture(texture)
		button.Icon:SetTexCoord(left, right, top, bottom)
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
db.Atlas.GetGlassWindow  = function(name, parent, secure, classColored, buttonTemplate)
	local self = CreateAtlasFrame(name, parent, secure, buttonTemplate)
	local assets = path.."Window\\Assets"

	self:SetBackdrop(db.Atlas.Backdrops.Border)

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
db.Atlas.GetFutureWindow = function(name, parent, secure, rainbow, buttonTemplate, artCorners)
	local self = CreateAtlasFrame(name, parent, secure, buttonTemplate)
	local assets = path.."Window\\Assets"

	self.Close.Texture = self.Close:CreateTexture(nil, "ARTWORK")
	self.Close.Texture:SetTexture(assets)
	self.Close.Texture:SetTexCoord(0, 0.40625, 0.5625, 1)
	self.Close.Texture:SetAllPoints(self.Close)
	self.Close:SetNormalTexture(self.Close.Texture)
	self.Close:SetSize(13, 14)
	self.Close:SetPoint("TOPRIGHT", -32, -32)

	self.TopLine = self:CreateTexture(nil, "BACKGROUND", nil, 7)
	self.TopLine:SetPoint("TOPLEFT", 16, -16)
	self.TopLine:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -16, -20)


	local gradient = {
		"HORIZONTAL",
	   cc.r, cc.g, cc.b, 1,
	   1, 1, 1, 0,
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

	self.TopLine:SetTexture(1,1,1)
	self.TopLine:SetGradientAlpha(unpack(gradient))

	self:SetBackdrop(db.Atlas.Backdrops.Full)

	self.Overlay = self:CreateTexture(nil, "ARTWORK", nil, 7)
	self.Overlay:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -16)
	self.Overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 16)
	self.Overlay:SetBlendMode("BLEND")
	self.Overlay:SetAlpha(0.1)

	self:HookScript("OnShow", function(self)
		local spec = GetSpecialization()
		local specInfo = spec and GetSpecializationInfo(spec)
		local specTexture = specInfo and db.Atlas.Overlays[class][specInfo]
		if specTexture then
			self.Overlay:SetTexture("Interface\\TALENTFRAME\\"..specTexture)
			self.Overlay:SetTexCoord(0, 1, 0, 0.64453125)
		end
	end)

	-- Eye candy!
	if rainbow then
		local interval, timer, cycle, rev, red, green, blue = 0.2, 0, 0
		local red2, green2, blue2
		gradient[5] = 0.75
		gradient[9] = 0.75
		self:SetScript("OnUpdate", function (self, elapsed)
			timer = timer + elapsed
			if timer > interval then
				red = (math.sin(0.05*cycle + 0) * 127 + 128)/255
				green = (math.sin(0.05*cycle + 2) * 127 + 128)/255
		   		blue = (math.sin(0.05*cycle + 4) * 127 + 128)/255


				red2 = (math.sin(0.05*cycle + 0) * 127 + 255)/255
				green2 = (math.sin(0.05*cycle + 2) * 127 + 255)/255
		   		blue2 = (math.sin(0.05*cycle + 4) * 127 + 255)/255

		   		gradient[2] = red
		   		gradient[3] = green
		   		gradient[4] = blue

		   		gradient[6] = red2
		   		gradient[7] = green2
		   		gradient[8] = blue2

		   		self.TopLine:SetGradientAlpha(unpack(gradient))

				if cycle == 1 then
					rev = false
				elseif cycle == 255 then
					rev = true
				end
				cycle = rev and cycle - 1 or cycle + 1
				timer = 0
			end
		end)
	end
	return self
end

db.Atlas.GetRoundActionButton = function(name, isCheck, parent, size, templates, notSecure)
	if InCombatLockdown() and not notSecure then
		error("GetRoundActionButton: SecureActionButtonTemplate cannot be inherited in combat!", 2)
	elseif not name or isCheck == nil or not parent then
		error("Usage: GetRoundActionButton(name, isCheck, parent[ [, size,] templates]): Buttons without name or parent not supported!", 2)
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
			error("Usage: GetRoundActionButton(name, isCheck, parent[ [, size,] templates]): Templates must be of string type!", 2)
		end

		local button = CreateFrame(isCheck and "CheckButton" or "Button", name, parent, template)

		button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

		button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.NormalTexture:SetAlpha(0.75)
		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint("CENTER", 0, 0)

		button.PushedTexture = button:GetPushedTexture()
		button.PushedTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")

		button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

		if isCheck then
			button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
		end

		button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")

		local size = size or 64
		local texSize = size * (74 / 64)

		button:SetSize(size, size)
		button.NormalTexture:SetSize(texSize, texSize)
		button.PushedTexture:SetSize(texSize, texSize)

		return button
	end
end
