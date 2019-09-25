---- Storyline plugin by MunkDev
-- This is a reskin of Storyline that fixes the quirky interaction
-- between the two addons and replaces most graphical components to
-- fit the art style of ConsolePort, instead of Storyline. 

local _, db = ...
ConsolePort:AddPlugin('Storyline', function(self)
	-----------------------------------------
	local Frame = Storyline_NPCFrame
	-----------------------------------------
	local Fade = db.UIFrameFadeIn
	-----------------------------------------
	local region

	for k, v in pairs({Frame:GetRegions()}) do 
		if v:IsObjectType("Texture") then
			v:Hide()
			v:SetTexture(nil)
		end
	end

	-----------------------------------------------
	-- Corners
	-----------------------------------------------
	region = Frame.BorderTopLeft
		region:SetDrawLayer("OVERLAY", 7)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(132/1024, 198/1024, 16/1024, 84/1024)
		region:SetSize(66, 68)
		region:ClearAllPoints()
		region:SetPoint("TOPLEFT", 8, -10)
		region:Show()
	region = Frame.BorderTopRight
		region:SetDrawLayer("OVERLAY", 7)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(198/1024, 264/1024, 16/1024, 84/1024)
		region:SetSize(66, 68)
		region:ClearAllPoints()
		region:SetPoint("TOPRIGHT", -9, -10)
		region:Show()
	region = Frame.BorderBottomLeft
		region:SetDrawLayer("OVERLAY", 7)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(0/1024, 66/1024, 16/1024, 84/1024)
		region:SetSize(66, 68)
		region:ClearAllPoints()
		region:SetPoint("BOTTOMLEFT", 8, 10)
		region:Show()
	region = Frame.BorderBottomRight
		region:SetDrawLayer("OVERLAY", 7)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(66/1024, 132/1024, 16/1024, 84/1024)
		region:SetSize(66, 68)
		region:ClearAllPoints()
		region:SetPoint("BOTTOMRIGHT", -9, 10)
		region:Show()

	-----------------------------------------------
	-- Borders
	-----------------------------------------------
	region = Frame.BorderLeft
		region:Hide()
	region = Frame:CreateTexture(nil, "OVERLAY")
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(0, 16/1024, 420/1024, 16/1024, 0, 2/1024, 420/1024, 2/1024)
		region:SetSize(15, 420)
		region:ClearAllPoints()
		region:SetPoint("LEFT", 4, 0)
	region = Frame.BorderRight
		region:Hide()
	region = Frame:CreateTexture(nil, "OVERLAY")
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		region:SetTexCoord(0, 2/1024, 420/1024, 2/1024, 0/1024, 16/1024, 420/1024, 16/1024)
		region:SetSize(15, 420)
		region:ClearAllPoints()
		region:SetPoint("RIGHT", -4, 0)
	region = Frame.TopBorder
		region:SetTexture("Interface\\LevelUp\\MinorTalents")
		region:SetSize(418, 2)
		region:SetTexCoord(0, 418/512, 341/512, 342/512)
		region:ClearAllPoints()
		region:SetPoint("TOP", 0, -16)
	region = Frame.BottomBorder
		region:SetTexture("Interface\\LevelUp\\MinorTalents")
		region:SetSize(418, 2)
		region:SetTexCoord(0, 418/512, 341/512, 342/512)
		region:ClearAllPoints()
		region:SetPoint("BOTTOM", 0, 16)
	region = Frame:CreateTexture("$parentTint", "BACKGROUND", nil, 2)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\BoxTint")
		region:SetPoint("TOPLEFT", 16, -16)
		region:SetPoint("BOTTOMRIGHT", Frame, "RIGHT", -16, 0)
		region:SetBlendMode("ADD")
		region:SetAlpha(0.75)

	-----------------------------------------------
	-- Background
	-----------------------------------------------
	Frame:SetBackdrop(db.Atlas.Backdrops.Full)

	region = Storyline_NPCFrameBG
		region:SetTexture("Interface\\\QUESTFRAME\\QuestMapLogAtlas")
		region:SetTexCoord(291/1024, 576/1024, 0/1024, 200/1024)
		region:ClearAllPoints()
		region:SetPoint("TOPLEFT", 16, -16)
		region:SetPoint("BOTTOMRIGHT", -16, 16)
		region:SetBlendMode("ADD")
		region:SetAlpha(0.35)
		region:Show()

	region = Storyline_NPCFrameBanner
		region:SetTexture("Interface\\LevelUp\\MinorTalents.blp")
		region:SetTexCoord(0.001953125, 0.818359375, 0.6660, 0.794921875)
		region:SetPoint("TOP", 0, -64)
		region:SetHeight(46)
		region:Show()

	region = Storyline_NPCFrameTitle
		region:SetPoint("CENTER", Storyline_NPCFrameBanner, 0, 0)

	-----------------------------------------------
	-- Animated stage
	-----------------------------------------------
	region = Frame:CreateTexture(nil, "ARTWORK")
		Frame.LocBack = region
		region:SetPoint("LEFT", 16, 0)
		region:SetPoint("RIGHT", -16, 0)
		region:SetHeight(200)
		region:SetAtlas("_GarrMissionLocation-ShadowmoonValley-Back")
	region = Frame:CreateTexture(nil, "ARTWORK", nil, 1)
		Frame.LocMid = region
		region:SetAllPoints(Frame.LocBack)
		region:SetAtlas("_GarrMissionLocation-ShadowmoonValley-Mid")
	region = Frame:CreateTexture(nil, "ARTWORK", nil, 2)
		Frame.LocFore = region
		region:SetAllPoints(Frame.LocBack)
		region:SetAtlas("_GarrMissionLocation-ShadowmoonValley-Fore")

	region = Frame:CreateTexture(nil, "ARTWORK", nil, 3)
		region:SetAllPoints(Frame.LocBack)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient")
		region:SetAlpha(0.35)

	region = Frame:CreateTexture(nil, "ARTWORK", nil, 4)
		region:SetTexture("Interface\\LevelUp\\MinorTalents")
		region:SetTexCoord(0, 418/512, 341/512, 342/512)
		region:SetPoint("TOPLEFT", Frame.LocBack, "TOPLEFT", 0, 2)
		region:SetPoint("BOTTOMRIGHT", Frame.LocBack, "TOPRIGHT", 0, 0)
	region = Frame:CreateTexture(nil, "ARTWORK", nil, 4)
		region:SetTexture("Interface\\LevelUp\\MinorTalents")
		region:SetSize(418, 2)
		region:SetTexCoord(0, 418/512, 341/512, 342/512)
		region:SetPoint("BOTTOMLEFT", Frame.LocBack, "BOTTOMLEFT", 0, 0)
		region:SetPoint("BOTTOMRIGHT", Frame.LocBack, "BOTTOMRIGHT", 0, -2)

	--parallax rates in % texCoords per second
	local rateBack = 0.1 
	local rateMid = 0.3
	local rateFore = 0.8

	Frame:HookScript("OnUpdate", function(self, elapsed)
		local changeBack = rateBack/100 * elapsed
		local changeMid = rateMid/100 * elapsed
		local changeFore = rateFore/100 * elapsed
		
		local backL, _, _, _, backR = self.LocBack:GetTexCoord()
		local midL, _, _, _, midR = self.LocMid:GetTexCoord()
		local foreL, _, _, _, foreR = self.LocFore:GetTexCoord()
		
		backL = backL + changeBack
		backR = backR + changeBack
		midL = midL + changeMid
		midR = midR + changeMid
		foreL = foreL + changeFore
		foreR = foreR + changeFore
		
		if (backL >= 1) then
			backL = backL - 1
			backR = backR - 1
		end
		if (midL >= 1) then
			midL = midL - 1
			midR = midR - 1
		end
		if (foreL >= 1) then
			foreL = foreL - 1
			foreR = foreR - 1
		end
		
		self.LocBack:SetTexCoord(backL, backR, 0, 1)
		self.LocMid:SetTexCoord (midL, midR, 0, 1)
		self.LocFore:SetTexCoord(foreL, foreR, 0, 1)
	end)

	-----------------------------------------------
	-- Re-anchoring and re-styling existing
	-----------------------------------------------

	for i=1, 3 do
		local chatOption = _G["Storyline_NPCFrameChatOption"..i]
		if chatOption then
			local font = chatOption:GetFontString()
			-- stylize
			font:SetShadowOffset(2, -2)
			-- re-anchor the ChatOptionX buttons to fit within the BG stage
			hooksecurefunc(chatOption, "SetPoint", function(self, anchor, _, yOffset)
				if anchor == "TOP" and yOffset == -175 then
					self:SetPoint("TOP", Frame.LocBack, 0, -10)
				end
			end)
		end
	end

	-- remove obscuring graphics that are unreferenced

	hooksecurefunc(Frame, "SetSize", function(self, width, height)
		-- draw the main frame on even pixels to ensure crisp graphics
		if floor(width) % 2 == 1 then
			self:SetWidth(floor(width + 1))
		end
		if floor(height) % 2 == 1 then
			self:SetHeight(floor(height + 1))
		end

		-- graphics aspect ratio, try to maintain:	x="556" y="230"
		local width, height = self:GetSize()
		local maxHeight = height - 350
		local bgHeight = 230/556 * width

		self.LocBack:SetHeight(bgHeight < maxHeight and bgHeight or maxHeight)
	end)

	-- trigger the readjustment on load
	Frame:SetSize(Frame:GetSize())

	-- desature and adjust buttons to match the theme
	region = Storyline_NPCFrameClose
		region:SetPoint("TOPRIGHT", -20, -20)
		region:GetNormalTexture():SetDesaturated(true)

	region = Storyline_NPCFrameLock
		region:GetNormalTexture():SetDesaturated(true)

	region = Storyline_NPCFrameConfigButton
		region.Icon:SetDesaturated(true)
		region:ClearAllPoints()
		region:SetPoint("RIGHT", Storyline_NPCFrameLock, "LEFT", 8, 0)
		region:SetSize(28, 28)

	region = Storyline_NPCFrameResizeButton
		region:GetNormalTexture():SetDesaturated(true)
		region:SetPoint("BOTTOMRIGHT", -10, 10)

	local fadeFrames = {
		Storyline_NPCFrame,
		Storyline_NPCFrameGossipChoices,
		Storyline_NPCFrameChatOption1,
		Storyline_NPCFrameChatOption2,
		Storyline_NPCFrameChatOption3,
		Storyline_NPCFrameObjectivesContent,
		Storyline_NPCFrameRewards.Content,
	}

	for _, frame in pairs(fadeFrames) do
		frame:HookScript("OnShow", function(self)
			Fade(self, 0.2, self:GetAlpha() == 1 and 0 or self:GetAlpha(), 1)
		end)
	end

	-----------------------------------------------
	-- Glowbox (popup) styling
	-----------------------------------------------

	-- replace the glowbox BG on these frames.
	local rewardContentBG = Storyline_NPCFrameRewards.Content:GetRegions()
	local glowBoxBGs = {
		Storyline_NPCFrameGossipChoicesBg,
		Storyline_NPCFrameObjectivesContentBg,
		rewardContentBG,
	}

	-- replace glow box gradients
	for _, region in pairs(glowBoxBGs) do
		region:SetGradient("VERTICAL", 1, 1, 1, 1, 1, 1)
		region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient")
	end

	local glowBoxes = {
		Storyline_NPCFrameRewards.Content,
		Storyline_NPCFrameGossipChoices,
		Storyline_NPCFrameObjectivesContent,
	}

	for _, box in pairs(glowBoxes) do
		region = box.GlowTopLeft
			region:SetDrawLayer("OVERLAY", 7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(132/1024, 198/1024, 16/1024, 84/1024)
			region:SetSize(36, 38)
			region:ClearAllPoints()
			region:SetPoint("TOPLEFT", -4, 4)
		region = box.GlowTopRight
			region:SetDrawLayer("OVERLAY", 7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(198/1024, 264/1024, 16/1024, 84/1024)
			region:SetSize(36, 38)
			region:ClearAllPoints()
			region:SetPoint("TOPRIGHT", 4, 4)
		region = box.GlowBottomLeft
			region:SetDrawLayer("OVERLAY", 7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(0/1024, 66/1024, 16/1024, 84/1024)
			region:SetSize(36, 38)
			region:ClearAllPoints()
			region:SetPoint("BOTTOMLEFT", -4, -4)
		region = box.GlowBottomRight
			region:SetDrawLayer("OVERLAY", 7)
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(66/1024, 132/1024, 16/1024, 84/1024)
			region:SetSize(36, 38)
			region:ClearAllPoints()
			region:SetPoint("BOTTOMRIGHT", 4, -4)


		region = box.GlowLeft
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(0, 16/1024, 420/1024, 16/1024, 0, 2/1024, 420/1024, 2/1024)
			region:SetVertTile(false)
			region:SetWidth(16)
			region:ClearAllPoints()
			region:SetPoint("LEFT", -13, 0)
			region:SetHeight(100)
		region = box.GlowRight
			region:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
			region:SetTexCoord(0, 2/1024, 420/1024, 2/1024, 0/1024, 16/1024, 420/1024, 16/1024)
			region:SetVertTile(false)
			region:ClearAllPoints()
			region:SetPoint("RIGHT", 10, 0)
			region:SetHeight(100)
		region = box.GlowTop
			region:SetTexture("Interface\\LevelUp\\MinorTalents")
			region:SetHorizTile(false)
			region:SetSize(418, 2)
			region:SetTexCoord(0, 418/512, 341/512, 342/512)
			region:ClearAllPoints()
			region:SetPoint("TOP", 0, 0)
		region = box.GlowBottom
			region:SetTexture("Interface\\LevelUp\\MinorTalents")
			region:SetHorizTile(false)
			region:SetSize(418, 2)
			region:SetTexCoord(0, 418/512, 341/512, 342/512)
			region:ClearAllPoints()
			region:SetPoint("BOTTOM", 0, 0)

		for k, v in pairs(box) do
			if type(k) == "string" and k:match("Shadow") then
				v:SetAlpha(0.5)
			end
		end

		box:HookScript("OnShow", function(self)
			local width, height = self:GetSize()
			if width and height then
				self.GlowTop:SetWidth(width)
				self.GlowBottom:SetWidth(width)
				self.GlowLeft:SetHeight(height)
				self.GlowRight:SetHeight(height)
			end
		end)

		hooksecurefunc(box, "SetSize", function(self, width, height)
			self.GlowTop:SetWidth(width)
			self.GlowBottom:SetWidth(width)
			self.GlowLeft:SetHeight(height)
			self.GlowRight:SetHeight(height)
		end)

		hooksecurefunc(box, "SetHeight", function(self, height)
			self.GlowLeft:SetHeight(height)
			self.GlowRight:SetHeight(height)
		end)

		hooksecurefunc(box, "SetWidth", function(self, width)
			self.GlowTop:SetWidth(width)
			self.GlowBottom:SetWidth(width)
		end)
	end

	-----------------------------------------------
	-- Custom model lighting
	-----------------------------------------------
	Storyline_NPCFrameModelsMe:SetLight(true, false, -100, -300, -500, 0.25, 1, 1, 1, 100, 1,1,1)
	Storyline_NPCFrameModelsYou:SetLight(true, false, -300, -300, -500, 0.25, 1, 1, 1, 100, 1,1,1)

	-----------------------------------------------
	-- ConsolePort hooking
	-----------------------------------------------

	-- offset the anchor on the ChatNext button to stop it from obscuring text
	region = Storyline_NPCFrameChatNext
		region.customCursorAnchor = {"TOPLEFT", Storyline_NPCFrameChatNext, "BOTTOM", 0, 8}
		region:HookScript("OnShow", function(self)
			ConsolePort:SetCurrentNode(self)
		end)

	-- ignore the ChatNext button whenever the choice frame is visible
	region = Storyline_NPCFrameGossipChoices
		region:HookScript("OnShow", function(self)
			Storyline_NPCFrameChatNext.ignoreNode = true
			if Storyline_ChoiceString0 then
				ConsolePort:SetCurrentNode(Storyline_ChoiceString0)
			end
		end)

		region:HookScript("OnHide", function(self)
			Storyline_NPCFrameChatNext.ignoreNode = nil
		end)

	-- ignore all these nodes, user will have to use the mouse to press them.
	for _, node in pairs({
		Storyline_NPCFrameModelsMeScrollZone,
		Storyline_NPCFrameModelsYouScrollZone,
		Storyline_NPCFrameResizeButton,
		Storyline_NPCFrameClose,
		Storyline_NPCFrameConfigButton,
		Storyline_NPCFrameLock,
		-- also remove the standard frames from the stack
		GossipFrame,
		QuestFrame,
	}) do node.ignoreNode = true end

	-- remove obstructing keyboard shortcuts 
	Storyline_Data.config.useKeyboard = false

	-- add the frame to ConsolePort's frame stack.
	self:AddFrame(Frame:GetName())
end)