-- This was mostly stolen from Bartender4.
-- This code snippet hides and modifies the default action bars.

local addOn, ab = ...
local Bar = ab.bar
local red, green, blue = ab.data.Atlas.GetCC()

do
	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()
	Bar.UIHider = UIHider

	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarLeft:SetParent(UIHider)
	MultiBarRight:SetParent(UIHider)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)
	end

	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil

	MainMenuBar:EnableMouse(false)

	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	MainMenuExpBar:SetParent(Bar)
	MainMenuExpBar:ClearAllPoints()
	MainMenuExpBar:SetPoint("BOTTOM", 0, 3)

	hooksecurefunc(MainMenuExpBar, "SetStatusBarColor", function(self, r, g, b, a)
		if r ~= red or g ~= green or b ~= blue then
			self:SetStatusBarColor(red, green, blue)
		end
	end)

	MainMenuXPBarTextureMid:SetTexCoord(0, 1, 1, 0)
	MainMenuXPBarTextureLeftCap:SetTexCoord(0.18750000, 0.43750000, 0.26562500, 0.01562500)
	MainMenuXPBarTextureRightCap:SetTexCoord(0.18750000, 0.43750000, 0.54687500, 0.29687500)

	MainMenuXPBarTextureMid:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureLeftCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)
	MainMenuXPBarTextureRightCap:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.75)

	MainMenuBarPerformanceBar:SetParent(UIHider)
	MainMenuBarPerformanceBar:ClearAllPoints()

	MainMenuXPBarTextureMid:SetAlpha(0.5)
	MainMenuXPBarTextureLeftCap:SetAlpha(0.5)
	MainMenuXPBarTextureRightCap:SetAlpha(0.5)

	for i=1, 19 do
		_G["MainMenuXPBarDiv"..i]:SetAlpha(0.5)
	end

	MainMenuBarMaxLevelBar:Hide()
	MainMenuBarMaxLevelBar:SetParent(UIHider)

	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	for i=0, 3 do
		HonorWatchBar.StatusBar["WatchBarTexture"..i]:SetAlpha(0.5)
		HonorWatchBar.StatusBar["XPBarTexture"..i]:SetAlpha(0.5)
	end

	HonorWatchBar:SetParent(Bar)
	HonorWatchBar:ClearAllPoints()
	HonorWatchBar:SetPoint("BOTTOM", 0, 3)

	HonorWatchBar:HookScript("OnShow", function(self) MainMenuExpBar:Hide() end)
	HonorWatchBar:HookScript("OnHide", function(self) MainMenuExpBar:SetShown(UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled()) end)

	hooksecurefunc(HonorWatchBar, "SetPoint", function(self, anchor, xoffset, yoffset)
		if anchor ~= "BOTTOM" or xoffset ~= 0 or yoffset ~= 3 then
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", 0, 3)
		end
	end)

	ArtifactWatchBar:ClearAllPoints()
	ArtifactWatchBar:SetParent(Bar)
	ArtifactWatchBar:SetPoint("BOTTOM", 0, 16)

	for i=0, 3 do
		ArtifactWatchBar.StatusBar["WatchBarTexture"..i]:Hide()
		ArtifactWatchBar.StatusBar["WatchBarTexture"..i]:ClearAllPoints()
		ArtifactWatchBar.StatusBar["XPBarTexture"..i]:Hide()
		ArtifactWatchBar.StatusBar["XPBarTexture"..i]:ClearAllPoints()
	end

	hooksecurefunc(ArtifactWatchBar, "SetPoint", function(self, anchor, xoffset, yoffset)
		if anchor ~= "BOTTOM" or xoffset ~= 0 or yoffset ~= 16 then
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", 0, 16)
		end
	end)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	ObjectiveTrackerFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -100, -132)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	-- raid cursor fix to add the hidden action bars to the interface scan process
	ConsolePortRaidCursor:SetFrameRef("hiddenBars", UIHider)
	ConsolePortRaidCursor:Execute([[
		UpdateFrameStack = [=[
			local frames = newtable(self:GetParent():GetChildren())
			frames[#frames + 1] = self:GetFrameRef("hiddenBars")
			for i, frame in pairs(frames) do
				if frame:IsProtected() and not Cache[frame] then
					CurrentNode = frame
					self:Run(GetNodes)
				end
			end
			self:Run(RefreshActions)
			if IsEnabled then
				self:Run(SelectNode, 0)
			end
		]=]
	]])

end