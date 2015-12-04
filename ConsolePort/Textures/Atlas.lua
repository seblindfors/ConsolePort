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
		edgeFile 	= path.."Window\\Edgefile",
		edgeSize 	= 8,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Tooltip = {
		bgFile 		= "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile 	= path.."Window\\Edgefile",
		edgeSize 	= 8,
		insets 		= {left = 8, right = 8,	top = 8, bottom = 8}
	},
	Border = {
		edgeFile 	= path.."Window\\Edgefile",
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
db.Atlas.GetGlassWindow  = function(name, parent, secure, classColored)
	local self = CreateAtlasFrame(name, parent, secure)
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
	self.BG:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8)
	self.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	self.BG:SetBlendMode("ADD")

	if classColored then
		self.BG:SetVertexColor(cc.r, cc.g, cc.b, 0.25)
	else
		self.BG:SetVertexColor(1, 1, 1, 0.25)
	end

	return self
end

db.Atlas.GetFutureWindow = function(name, parent, secure, rainbow)
	local self = CreateAtlasFrame(name, parent, secure)
	local assets = path.."Window\\Assets"

	self.Close.Texture = self.Close:CreateTexture(nil, "ARTWORK")
	self.Close.Texture:SetTexture(assets)
	self.Close.Texture:SetTexCoord(0, 0.40625, 0.5625, 1)
	self.Close.Texture:SetAllPoints(self.Close)
	self.Close:SetNormalTexture(self.Close.Texture)
	self.Close:SetSize(13, 14)
	self.Close:SetPoint("TOPRIGHT", -20, -20)

	self.TopLine = self:CreateTexture(nil, "BACKGROUND")
	self.TopMid = self:CreateTexture(nil, "OVERLAY")
	self.TopLeft = self:CreateTexture(nil, "OVERLAY")
	self.TopRight = self:CreateTexture(nil, "OVERLAY")

	self.TopLine:SetPoint("TOPLEFT", self.TopLeft, "TOPLEFT", 1, 1)
	self.TopLine:SetPoint("TOPRIGHT", self.TopRight, "TOPRIGHT", -1, 1)
	self.TopLine:SetPoint("BOTTOMLEFT", self.TopLeft, "TOPLEFT", 0, 0)
	self.TopLine:SetPoint("BOTTOMRIGHT", self.TopRight, "TOPRIGHT", 0, 0)

	self.TopLeft:SetPoint("TOPLEFT", self, "TOPLEFT", 145, -4)
	self.TopLeft:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 160, -24)

	self.TopRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", -145, -4)
	self.TopRight:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -160, -24)

	self.TopMid:SetPoint("TOPLEFT", self.TopLeft, "TOPRIGHT", 0, 0)
	self.TopMid:SetPoint("BOTTOMRIGHT", self.TopRight, "BOTTOMLEFT", 0, 0)

	self.TopLine:SetTexture(0.05,0.05,0.05)
	self.TopMid:SetTexture(assets)
	self.TopLeft:SetTexture(assets)
	self.TopRight:SetTexture(assets)

	self.TopMid:SetTexCoord(0.34375, 0.40625, 0.0, 0.40625)
	self.TopLeft:SetTexCoord(0.0, 0.34375, 0.0, 0.40625)
	self.TopRight:SetTexCoord(0.40625, 0.75, 0.0, 0.40625)

	local gradient = {
		"VERTICAL",
	   cc.r, cc.g, cc.b, 1,
	   cc.r*0.85, cc.g*0.85, cc.b*0.85, 1,
	}

	self.TopMid:SetGradientAlpha(unpack(gradient))
	self.TopLeft:SetGradientAlpha(unpack(gradient))
	self.TopRight:SetGradientAlpha(unpack(gradient))

	self:SetBackdrop(db.Atlas.Backdrops.Full)

	self.Overlay = self:CreateTexture(nil, "ARTWORK", nil, 7)
	self.Overlay:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.Overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8)
	self.Overlay:SetBlendMode("BLEND")
	self.Overlay:SetAlpha(0.1)

	self:HookScript("OnShow", function(self)
		local specTexture = db.Atlas.Overlays[class][GetSpecializationInfo(GetSpecialization())]
		if specTexture then
			self.Overlay:SetTexture("Interface\\TALENTFRAME\\"..specTexture)
			self.Overlay:SetTexCoord(0, 1, 0, 0.64453125)
		end
	end)

	-- Eye candy!
	if rainbow then
		local interval, timer, cycle, rev, red, green, blue = 0.2, 0, 0
		self:SetScript("OnUpdate", function (self, elapsed)
			timer = timer + elapsed
			while timer > 0.2 do
				red = (math.sin(0.05*cycle + 0) * 127 + 128)/255
				green = (math.sin(0.05*cycle + 2) * 127 + 128)/255
		   		blue = (math.sin(0.05*cycle + 4) * 127 + 128)/255

		   		gradient[2] = red
		   		gradient[3] = green
		   		gradient[4] = blue

		   		gradient[6] = red*0.85
		   		gradient[7] = green*0.85
		   		gradient[8] = blue*0.85

		   		self.TopMid:SetGradientAlpha(unpack(gradient))
				self.TopLeft:SetGradientAlpha(unpack(gradient))
				self.TopRight:SetGradientAlpha(unpack(gradient))

				if cycle == 1 then
					rev = false
				elseif cycle == 255 then
					rev = true
				end
				cycle = rev and cycle - 1 or cycle + 1
				timer = 0
			end
		end)
	else
		local timer, glow, red, green, blue, fadeAway = 0, 1
		self:SetScript("OnUpdate", function(self, elapsed)
			timer = timer + elapsed
			while timer > 0.1 do
				glow = fadeAway and glow - 0.01 or glow + 0.01

				red 	= cc.r * glow
				green 	= cc.g * glow
				blue 	= cc.b * glow

				gradient[2] = red
				gradient[3] = green
				gradient[4] = blue

				gradient[6] = red	* glow
				gradient[7] = green * glow
				gradient[8] = blue 	* glow

				if glow > 1 then
					fadeAway = true
				elseif glow < 0.80 then
					fadeAway = false
				end

				self.TopMid:SetGradientAlpha(unpack(gradient))
				self.TopLeft:SetGradientAlpha(unpack(gradient))
				self.TopRight:SetGradientAlpha(unpack(gradient))

				timer = 0
			end
		end)
	end
	return self
end
---------------------------------------------------------------
db.Atlas.GetSetupWindow = function(name, parent, secure)
	local self = CreateAtlasFrame(name, parent, secure, "UIPanelCloseButtonNoScripts")
	-- Regions
	-- Corner
	self.BottomLeftCorner 	= self:CreateTexture(nil, "BORDER")
	self.BottomRightCorner 	= self:CreateTexture(nil, "BORDER")
	self.TopLeftCorner 		= self:CreateTexture(nil, "BORDER")
	self.TopRightCorner 	= self:CreateTexture(nil, "BORDER")
	-- Border
	self.BottomBorder		= self:CreateTexture(nil, "BORDER")	
	self.TopBorder			= self:CreateTexture(nil, "BORDER")
	self.LeftBorder			= self:CreateTexture(nil, "BORDER")
	self.RightBorder		= self:CreateTexture(nil, "BORDER")
	-- BG
	self.BG					= self:CreateTexture(nil, "BACKGROUND")
	self.TopRight			= self:CreateTexture(nil, "OVERLAY")
	self.TopLeft			= self:CreateTexture(nil, "OVERLAY")
	self.TopMiddle			= self:CreateTexture(nil, "OVERLAY")
	-- Header
	self.Header 			= self:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium", 1)

	-- Size
	self.BottomLeftCorner:SetSize(209,158)
	self.BottomRightCorner:SetSize(209,158)
	self.TopLeftCorner:SetSize(209,158)
	self.TopRightCorner:SetSize(208,158)

	self.BottomBorder:SetSize(256,86)
	self.TopBorder:SetSize(256,91)
	self.LeftBorder:SetSize(93,256)
	self.RightBorder:SetSize(94,256)	

	self.TopRight:SetSize(220,85)
	self.TopLeft:SetSize(219,85)
	self.TopMiddle:SetSize(256,85)

	-- Texture coords
	self.BottomLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.30468750, 0.61328125)
	self.BottomRightCorner:SetTexCoord(0.41406250, 0.82226563, 0.30468750, 0.61328125)
	self.TopLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.61718750, 0.92578125)
	self.TopRightCorner:SetTexCoord(0.41406250, 0.82031250, 0.61718750, 0.92578125)

	self.BottomBorder:SetTexCoord(0.00000000, 1.00000000, 0.17187500, 0.33984375)
	self.TopBorder:SetTexCoord(0.00000000, 1.00000000, 0.34375000, 0.52148438)
	self.LeftBorder:SetTexCoord(0.00390625, 0.36718750, 0.00000000, 1.00000000)
	self.RightBorder:SetTexCoord(0.37500000, 0.74218750, 0.00000000, 1.00000000)

	self.TopRight:SetTexCoord(0.00195313, 0.43164063, 0.13476563, 0.30078125)
	self.TopLeft:SetTexCoord(0.43554688, 0.86328125, 0.13476563, 0.30078125)
	self.TopMiddle:SetTexCoord(0.00000000, 1.00000000, 0.00195313, 0.16796875)

		-- Points
	self.BottomLeftCorner:SetPoint("BOTTOMLEFT")
	self.BottomRightCorner:SetPoint("BOTTOMRIGHT")
	self.TopLeftCorner:SetPoint("TOPLEFT")
	self.TopRightCorner:SetPoint("TOPRIGHT")

	self.BottomBorder:SetPoint("BOTTOMLEFT", self.BottomLeftCorner, "BOTTOMRIGHT", 0, 2)
	self.BottomBorder:SetPoint("BOTTOMRIGHT", self.BottomRightCorner, "BOTTOMLEFT", 0, 2)
	self.TopBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "TOPRIGHT", 0, -1)
	self.TopBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "TOPLEFT", 0, -1)
	self.LeftBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "BOTTOMLEFT", 2, 0)
	self.LeftBorder:SetPoint("BOTTOMLEFT", self.BottomLeftCorner, "TOPLEFT", 2, 0)
	self.RightBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "BOTTOMRIGHT", 0, 0)
	self.RightBorder:SetPoint("BOTTOMRIGHT", self.BottomRightCorner, "TOPRIGHT", 0, 0)

	self.BG:SetPoint("TOPLEFT", 20, -20)
	self.BG:SetPoint("BOTTOMRIGHT", -20, 20)
	self.TopRight:SetPoint("TOPRIGHT", -42, -44)
	self.TopLeft:SetPoint("TOPLEFT", 42, -44)
	self.TopMiddle:SetPoint("TOPLEFT", self.TopLeft, "TOPRIGHT")
	self.TopMiddle:SetPoint("TOPRIGHT", self.TopRight, "TOPLEFT")

	self.Header:SetPoint("LEFT", self.TopLeft, "LEFT")
	self.Header:SetPoint("RIGHT", self.TopRight, "RIGHT")
	self.Close:SetPoint("TOPRIGHT", -10, -10)

	-- File
	local prefix = "Interface\\QuestionFrame\\Question-"
	self.BottomLeftCorner:SetTexture(prefix.."Main")
	self.BottomRightCorner:SetTexture(prefix.."Main")
	self.TopLeftCorner:SetTexture(prefix.."Main")
	self.TopRightCorner:SetTexture(prefix.."Main")

	self.BottomBorder:SetTexture(prefix.."HTile")
	self.TopBorder:SetTexture(prefix.."HTile")
	self.LeftBorder:SetTexture(prefix.."VTile")
	self.RightBorder:SetTexture(prefix.."VTile")	

	self.BG:SetTexture(prefix.."Background")
	self.TopRight:SetTexture(prefix.."Main")
	self.TopLeft:SetTexture(prefix.."Main")
	self.TopMiddle:SetTexture(prefix.."HTile")
	return self
end