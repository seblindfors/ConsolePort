--[[
This library is a rewrite of LibButtonGlow-1.0, originally by
Hendrik 'nevcairiel' Leppkes (h.leppkes@gmail.com), used in Bartender4. 
https://www.curseforge.com/wow/addons/libbuttonglow-1-0

This version is heavily modified for ConsolePort.
Do not copy or use this library for anything else.
]]

local MAJOR_VERSION = 'CPButtonGlow'
local MINOR_VERSION = 2

if not LibStub then error(MAJOR_VERSION .. ' requires LibStub.') end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.unusedOverlays = lib.unusedOverlays or {}
lib.numOverlays = lib.numOverlays or 0

local tinsert, tremove, tostring = table.insert, table.remove, tostring
local AnimateTexCoords = AnimateTexCoords

local function OverlayGlowAnimOutFinished(animGroup)
	local overlay = animGroup:GetParent()
	local frame = overlay:GetParent()
	overlay:Hide()
	tinsert(lib.unusedOverlays, overlay)
	frame.__LBGoverlay = nil
end

local function OverlayGlow_OnUpdate(self, elapsed)
	AnimateTexCoords(self.ants, 512, 512, 96, 96, 25, elapsed, 0.01)
	local cooldown = self:GetParent().cooldown
	-- we need some threshold to avoid dimming the glow during the gdc
	-- (using 1500 exactly seems risky, what if casting speed is slowed or something?)
	if(cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000) then
		self:SetAlpha(0.5)
	else
		self:SetAlpha(1.0)
	end
end

local function OverlayGlow_OnHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		OverlayGlowAnimOutFinished(self.animOut)
	end
end

local function CreateScaleAnim(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation('Scale')
	scale:SetTarget(target:GetName())
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay)
	local alpha = group:CreateAnimation('Alpha')
	alpha:SetTarget(target:GetName())
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromAlpha)
	alpha:SetToAlpha(toAlpha)

	if delay then
		alpha:SetStartDelay(delay)
	end
end


local function AnimIn_OnPlay(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetSize(frameWidth, frameHeight)
	frame.spark:SetAlpha(0.3)
	frame.innerGlow:SetSize(frameWidth / 2, frameHeight / 2)
	frame.innerGlow:SetAlpha(1.0)
	frame.outerGlow:SetSize(frameWidth * 2, frameHeight * 2)
	frame.outerGlow:SetAlpha(1.0)
	frame.outerGlowOver:SetAlpha(1.0)
	frame.ants:SetSize(frameWidth * 1.05, frameHeight * 1.05)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlow:SetSize(frameWidth, frameHeight)
	frame.outerGlow:SetSize(frameWidth, frameHeight)
	frame.outerGlowOver:SetAlpha(0.0)
	frame.outerGlowOver:SetSize(frameWidth, frameHeight)
	frame.ants:SetAlpha(1.0)
end

local function CreateOverlayGlow()
	lib.numOverlays = lib.numOverlays + 1

	-- create frame and textures
	local name = 'CPButtonGlowOverlay' .. tostring(lib.numOverlays)
	local overlay = CreateFrame('Frame', name, UIParent)

	-- spark
	overlay.spark = overlay:CreateTexture(name .. 'Spark', 'BACKGROUND')
	overlay.spark:SetPoint('CENTER')
	overlay.spark:SetAlpha(0)
	overlay.spark:SetTexture(CPAPI.GetAsset('Textures\\Glow\\IconAlert'))
	overlay.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

	-- inner glow
	overlay.innerGlow = overlay:CreateTexture(name .. 'InnerGlow', 'ARTWORK')
	overlay.innerGlow:SetPoint('CENTER')
	overlay.innerGlow:SetAlpha(0)
	overlay.innerGlow:SetTexture(CPAPI.GetAsset('Textures\\Glow\\IconAlert'))
	overlay.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

	-- outer glow
	overlay.outerGlow = overlay:CreateTexture(name .. 'OuterGlow', 'ARTWORK')
	overlay.outerGlow:SetPoint('CENTER')
	overlay.outerGlow:SetAlpha(0)

	-- outer glow over
	overlay.outerGlowOver = overlay:CreateTexture(name .. 'OuterGlowOver', 'ARTWORK')
	overlay.outerGlowOver:SetPoint('TOPLEFT', overlay.outerGlow, 'TOPLEFT')
	overlay.outerGlowOver:SetPoint('BOTTOMRIGHT', overlay.outerGlow, 'BOTTOMRIGHT')
	overlay.outerGlowOver:SetAlpha(0)
	overlay.outerGlowOver:SetTexture(CPAPI.GetAsset('Textures\\Glow\\IconAlert'))
	overlay.outerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

	-- ants
	overlay.ants = overlay:CreateTexture(name .. 'Ants', 'OVERLAY')
	overlay.ants:SetPoint('CENTER')
	overlay.ants:SetAlpha(0)
	overlay.ants:SetTexture(CPAPI.GetAsset('Textures\\Glow\\Ants'))

	-- setup antimations
	overlay.animIn = overlay:CreateAnimationGroup()
	CreateScaleAnim(overlay.animIn, overlay.spark,          1, 0.2, 1.5, 1.5)
	CreateAlphaAnim(overlay.animIn, overlay.spark,          1, 0.2, 0, 1)
	CreateScaleAnim(overlay.animIn, overlay.innerGlow,      1, 0.3, 2, 2)
	CreateScaleAnim(overlay.animIn, overlay.outerGlow,      1, 0.3, 0.5, 0.5)
	CreateScaleAnim(overlay.animIn, overlay.outerGlowOver,  1, 0.3, 0.5, 0.5)
	CreateAlphaAnim(overlay.animIn, overlay.outerGlowOver,  1, 0.3, 1, 0)
	CreateScaleAnim(overlay.animIn, overlay.spark,          1, 0.2, 2/3, 2/3, 0.2)
	CreateAlphaAnim(overlay.animIn, overlay.spark,          1, 0.2, 1, 0, 0.2)
	CreateAlphaAnim(overlay.animIn, overlay.innerGlow,      1, 0.2, 1, 0, 0.3)
	CreateAlphaAnim(overlay.animIn, overlay.ants,           1, 0.2, 0, 1, 0.3)
	overlay.animIn:SetScript('OnPlay', AnimIn_OnPlay)
	overlay.animIn:SetScript('OnFinished', AnimIn_OnFinished)

	overlay.animOut = overlay:CreateAnimationGroup()
	CreateAlphaAnim(overlay.animOut, overlay.outerGlowOver, 1, 0.2, 0, 1)
	CreateAlphaAnim(overlay.animOut, overlay.ants,          1, 0.2, 1, 0)
	CreateAlphaAnim(overlay.animOut, overlay.outerGlowOver, 2, 0.2, 1, 0)
	CreateAlphaAnim(overlay.animOut, overlay.outerGlow,     2, 0.2, 1, 0)
	overlay.animOut:SetScript('OnFinished', OverlayGlowAnimOutFinished)

	-- scripts
	overlay:SetScript('OnUpdate', OverlayGlow_OnUpdate)
	overlay:SetScript('OnHide', OverlayGlow_OnHide)

	return overlay
end

local function GetOverlayGlow()
	local overlay = tremove(lib.unusedOverlays)
	if not overlay then
		overlay = CreateOverlayGlow()
	end
	return overlay
end

function lib.ShowOverlayGlow(frame)
	if frame.__LBGoverlay then
		if frame.__LBGoverlay.animOut:IsPlaying() then
			frame.__LBGoverlay.animOut:Stop()
			frame.__LBGoverlay.animIn:Play()
		end
	else
		local overlay = GetOverlayGlow()
		local frameWidth, frameHeight = frame:GetSize()
		overlay:SetParent(frame)
		overlay:ClearAllPoints()
		--Make the height/width available before the next frame:
		overlay:SetSize(frameWidth * 1.2, frameHeight * 1.2)
		overlay:SetPoint('TOPLEFT', frame, 'TOPLEFT', -frameWidth * 0.2, frameHeight * 0.2)
		overlay:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', frameWidth * 0.2, -frameHeight * 0.2)
		overlay.animIn:Play()
		frame.__LBGoverlay = overlay
	end
	if ConsolePortBar and ConsolePortBar.CoverArt then
		ConsolePortBar.CoverArt:Flash()
	end
end

function lib.HideOverlayGlow(frame)
	if frame.__LBGoverlay then
		if frame.__LBGoverlay.animIn:IsPlaying() then
			frame.__LBGoverlay.animIn:Stop()
		end
		if frame:IsVisible() then
			frame.__LBGoverlay.animOut:Play()
		else
			OverlayGlowAnimOutFinished(frame.__LBGoverlay.animOut)
		end
	end
end
