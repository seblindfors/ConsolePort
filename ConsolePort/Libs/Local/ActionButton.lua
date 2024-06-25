----------------------------------------------------------------
-- LibActionButton-1.0 and LibButtonGlow-1.0 wrapper for CP
----------------------------------------------------------------
local Lib = LibStub:NewLibrary('ConsolePortActionButton', 1) -- TODO: rename the lib?
if not Lib then return end
local LAB = LibStub('LibActionButton-1.0')
local LBG = LibStub('LibButtonGlow-1.0')
---------------------------------------------------------------

function Lib:NewPool(info)
	local i = CreateCounter();
	local id, name, header = info.id, info.name, info.header;
	local type, config, mixin = info.type, info.config, info.mixin;
	local customType = self.CustomTypes[type];

	local function creationFunc()
		local index = i();
		local frame = LAB:CreateButton(id and id..index or index, name..index, header, config)
		frame:SetID(index)
		if customType then
			Mixin(frame, customType)
		end
		return frame;
	end

	local resetterFunc = CPAPI.HideAndClearAnchors;

	return creationFunc, resetterFunc, mixin;
end

---------------------------------------------------------------
Lib.CustomTypes = {};
---------------------------------------------------------------
-- Common action button
---------------------------------------------------------------
local Common = {}; Lib.CustomTypes.Common = Common;

---------------------------------------------------------------
-- Pet action button
---------------------------------------------------------------
local Pet = CreateFromMixins(Common); Lib.CustomTypes.Pet = Pet;

function Pet:HasAction()         return true                                 end
function Pet:GetCooldown()       return GetPetActionCooldown(self.id)        end
function Pet:IsAttack()          return IsPetAttackAction(self.id)           end
function Pet:IsCurrentlyActive() return select(4, GetPetActionInfo(self.id)) end
function Pet:IsAutoRepeat()      return select(6, GetPetActionInfo(self.id)) end
function Pet:IsUsable()          return GetPetActionSlotUsable(self.id)      end
function Pet:SetTooltip()        return GameTooltip:SetPetAction(self.id)    end

function Pet:GetTexture()
	local texture, isToken = select(2, GetPetActionInfo(self.id))
	return isToken and _G[texture] or texture
end

function Pet:UpdateLocal()
	local _, _, _, _, autoCastAllowed, autoCastEnabled = GetPetActionInfo(self.id)
	if autoCastEnabled then
		CPAPI.AutoCastStart(self, autoCastAllowed, CPAPI.GetClassColor())
	else
		CPAPI.AutoCastStop(self, autoCastAllowed)
	end
end

---------------------------------------------------------------
Lib.Skin, Lib.SkinUtility = {}, {};
---------------------------------------------------------------

function Lib.SkinUtility.GetIconMask(self)
	if self.IconMask then
		return self.IconMask;
	end
	self.IconMask = self:CreateMaskTexture(nil, 'BACKGROUND')
	self.icon:AddMaskTexture(self.IconMask)
	return self.IconMask;
end

function Lib.SkinUtility.GetSlotBackground(self)
	if not self.SlotBackground then
		self.SlotBackground = self:CreateTexture(nil, 'BACKGROUND')
	end
	return self.SlotBackground;
end

function Lib.SkinUtility.GetHighlightTexture(self)
	if not self.HighlightTexture then
		self.HighlightTexture = self:GetHighlightTexture()
	end
	return self.HighlightTexture;
end

function Lib.SkinUtility.GetPushedTexture(self)
	if not self.PushedTexture then
		self.PushedTexture = self:GetPushedTexture()
	end
	return self.PushedTexture;
end

function Lib.SkinUtility.GetCheckedTexture(self)
	if not self.CheckedTexture then
		self.CheckedTexture = self:GetCheckedTexture()
	end
	return self.CheckedTexture;
end

function Lib.SkinUtility.PreventSkinning(self)
	self.MasqueSkinned = true;
end

function Lib.SkinUtility.SkinChargeCooldown(self, skin, reset)
	local obj = self.chargeCooldown;
	if ( not obj or ( self.hookedChargeCooldown == obj ) ) then
		return;
	end
	if self.hookedChargeCooldown then
		reset(self.hookedChargeCooldown, self)
	end
	local script = obj:GetScript('OnCooldownDone')
	self.hookedChargeCooldown = obj;
	skin(obj, self)
	obj:SetScript('OnCooldownDone', function()
		self.hookedChargeCooldown = nil;
		reset(obj, self)
		if script then
			script(obj)
		end
	end)
end

do -- Lib.SkinUtility.SkinOverlayGlow
	function Lib.SkinUtility.SkinOverlayGlow(self, onShow, onHide)
		if self.__LBGoverlaySkin then return end;
		self.ShowOverlayGlow = onShow;
		self.HideOverlayGlow = onHide;
		self.__LBGoverlaySkin = true;
	end
end -- Lib.SkinUtility.SkinOverlayGlow

---------------------------------------------------------------
-- Skins
---------------------------------------------------------------

do -- Lib.Skin.ColorSwatchProc
	local SkinOverlayGlow = Lib.SkinUtility.SkinOverlayGlow;
	local OverlayPool = CreateFramePool('Frame', UIParent, 'CPFlashableFiligreeTemplate')
	local SwatchPool = CreateFramePool('Frame', UIParent, 'CPSwatchHighlightTemplate')

	local function OnOverlayFinished(self)
		OverlayPool:Release(self:GetParent())
	end

	local function OnShowOverlay(self)
		local overlay, swatch, newObj = self.__overlay, self.__swatch;
		if not overlay and not self.__procNoFlash then
			overlay, newObj = OverlayPool:Acquire()
			overlay:SetParent(self:GetParent())
			overlay:SetAnchor(self)
			overlay:SetSize(self:GetSize() * 2)
			overlay:SetScale(self.__procSize)
			overlay:SetTexture(self.SpellHighlightTexture:GetTexture())
			overlay:SetTexCoord(self.SpellHighlightTexture:GetTexCoord())
			overlay:SetLooping('BOUNCE')
			if self.GetOverlayColor then
				overlay:SetVertexColor(self:GetOverlayColor())
			end
			if newObj then
				overlay:SetFrameLevel(2)
				overlay:SetAnimationSpeedMultiplier(0.75)
				overlay.filigreeAnim:SetScript('OnFinished', OnOverlayFinished)
			end
			overlay:Show()
		end
		if not swatch and not self.__procNoSwatch then
			swatch = SwatchPool:Acquire()
			swatch:SetParent(self)
			swatch:SetAllPoints(self)
			swatch:SetTexture(self.__procText)
			swatch:Show()
		end
		if overlay then
			overlay:Stop()
			overlay:Play()
		end
		if self.OnOverlayGlow then
			self:OnOverlayGlow(true, overlay, swatch)
		end
		self.__overlay, self.__swatch = overlay, swatch;
	end

	local function OnHideOverlay(self)
		SwatchPool:Release(self.__swatch, true)
		local overlay = self.__overlay;
		if overlay then
			overlay:SetLooping('NONE')
		end
		if self.OnOverlayGlow then
			self:OnOverlayGlow(false, self.__overlay, self.__swatch)
		end
		self.__overlay, self.__swatch = nil, nil;
	end

	Lib.Skin.ColorSwatchProc = function(self, config) config = config or {};
		self.__procSize     = config.procSize or self.__procSize or 0.6;
		self.__procText     = config.procText or self.__procText;
		self.__procNoSwatch = config.noSwatch or self.__procNoSwatch;
		self.__procNoFlash  = config.noFlash  or self.__procNoFlash;
		SkinOverlayGlow(self, OnShowOverlay, OnHideOverlay)
	end;
end -- Lib.Skin.ColorSwatchProc

do -- Lib.Skin.RingButton
	local GetIconMask = Lib.SkinUtility.GetIconMask;
	local SkinChargeCooldown = Lib.SkinUtility.SkinChargeCooldown;
	local SkinOverlayGlow = Lib.Skin.ColorSwatchProc;

	Lib.Skin.RingButton = function(self)
		assert(type(self.rotation) == 'number', 'Ring button must have a rotation value.')
		local obj, scale;
		local r, g, b = CPPieMenuMixin.SliceColors.Accent:GetRGB()
		local size = self:GetSize()
		do obj = self.NormalTexture;
			scale = 110 / 64;
			obj:ClearAllPoints()
			obj:SetPoint('CENTER', -1, 0)
			obj:SetSize(scale * size, scale * size)
			obj:SetVertexColor(r, g, b, 1)
			CPAPI.SetAtlas(obj, 'ring-metallight')
		end
		do obj = self.PushedTexture or self:GetPushedTexture();
			obj:ClearAllPoints()
			obj:SetPoint('CENTER')
			obj:SetSize(scale * size, scale * size)
			obj:SetVertexColor(r, g, b, 1)
			CPAPI.SetAtlas(obj, 'ring-metaldark')
		end
		do obj = self.Flash;
			obj:ClearAllPoints()
			obj:SetPoint('CENTER', 1, 0)
			obj:SetSize(scale * size, scale * size)
			obj:SetBlendMode('ADD')
			CPAPI.SetAtlas(obj, 'ring-horde')
			obj:SetDrawLayer('OVERLAY', 1)
		end
		do obj = self.CheckedTexture or self:GetCheckedTexture();
			scale = 78 / 64;
			obj:ClearAllPoints()
			obj:SetPoint('CENTER', 0, 0)
			obj:SetSize(scale * size, scale * size)
			obj:SetDrawLayer('OVERLAY', -1)
			obj:SetBlendMode('BLEND')
			CPAPI.SetAtlas(obj, 'ring-select')
		end
		do obj = self.HighlightTexture or self:GetHighlightTexture();
			scale = 90 / 64;
			obj:ClearAllPoints()
			obj:SetPoint('CENTER')
			obj:SetSize(scale * size, scale * size)
			obj:SetBlendMode('BLEND')
			CPAPI.SetAtlas(obj, 'ring-select')
		end
		do obj = self.icon;
			obj:SetAllPoints()
		end
		do obj = GetIconMask(self);
			obj:SetTexture(CPAPI.GetAsset([[Textures\Button\Mask]]), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
			obj:SetAllPoints()
		end
		do obj = self.SlotBackground;
			if obj then
				obj:SetPoint('CENTER')
				obj:SetSize(size, size)
				obj:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64]]))
				obj:SetRotation(self.rotation + math.pi)
				obj:AddMaskTexture(self.IconMask)
				obj:SetDrawLayer('BACKGROUND', -1)
			end
		end
		do obj = self.SpellHighlightTexture;
			obj:ClearAllPoints()
			obj:SetPoint('CENTER', 0, 0)
			obj:SetSize(size, size)
			obj:SetTexture([[Interface\Buttons\IconBorder-GlowRing]])
		end
		do obj = self.cooldown;
			obj:SetSwipeTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Cooldown\Swipe]])
			obj:SetSwipeColor(RED_FONT_COLOR:GetRGBA())
			obj:SetUseCircularEdge(true)
			obj.SetEdgeTexture = nop;
		end
		SkinChargeCooldown(self, function(cd)
			cd:SetUseCircularEdge(true)
		end, function(cd)
			cd:SetUseCircularEdge(false)
		end)
		SkinOverlayGlow(self, {
			procSize = 0.62;
			noFlash  = true;
			procText = [[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Cooldown\Swipe]];
		})
		if not self.RingMasked then
			local mask = self:GetParent().InnerMask;
			for _, region in ipairs({
				self.NormalTexture,
				self.PushedTexture,
				self.HighlightTexture,
				self.Border,
			}) do region:AddMaskTexture(mask) end
			self.RingMasked = true;
		end
	end;
end -- Lib.Skin.RingButton


do Lib.Skin.UtilityRingButton = function(self)
	Lib.Skin.RingButton(self)
	local r, g, b = CPPieMenuMixin.SliceColors.Accent:GetRGB()
	local obj;
	do obj = self.SlotBackground; if obj then
		obj:SetDrawLayer('BACKGROUND', -1)
		obj:SetTexture(CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
		obj:SetDesaturated(true)
		obj:SetVertexColor(0.5, 0.5, 0.5, 1)
		obj:AddMaskTexture(self.IconMask)
		obj:SetRotation(0)
	end; end
	do obj = self.Border;
		obj:SetDrawLayer('BACKGROUND', -2)
		obj:ClearAllPoints()
		obj:Show()
		if (self:GetAttribute('type') == 'action' and self:GetAttribute('action') == CPAPI.ExtraActionButtonID) then
			local skin, hasBarSkin = CPAPI.GetOverrideBarSkin(), true;
			if not skin then
				skin, hasBarSkin = [[Interface\ExtraButton\stormwhite-extrabutto]], false;
			end
			obj:SetSize(256 * 0.8, 128 * 0.8)
			obj:SetPoint('CENTER', -2, 0)
			obj:SetTexture(skin)
			if hasBarSkin then
				obj:SetVertexColor(1, 1, 1, 1)
			else
				obj:SetVertexColor(r, g, b, 0.5)
			end
		else
			obj:SetTexture(CPAPI.GetAsset([[Textures\Button\Shadow]]))
			obj:SetPoint('TOPLEFT', -5, 0)
			obj:SetPoint('BOTTOMRIGHT', 5, -10)
		end
	end
end;
end -- Lib.Skin.UtilityRingButton

---------------------------------------------------------------
Lib.TypeMetaMap = {};
---------------------------------------------------------------
do -- Workaround for LAB's private type meta map.
	setmetatable(Lib.TypeMetaMap, {__index = function(self, k)
		local ReferenceHeader = CreateFrame('Frame', 'ConsolePortABRefHeader', nil, 'SecureHandlerStateTemplate')
		local ReferenceButton = LAB:CreateButton('ref', '$parentButton', ReferenceHeader)
		for meta, dummy in pairs({
			empty  = 0;
			action = 1;
			spell  = 6603; -- Auto-attack
			item   = 6948; -- Hearthstone
			macro  = 1;
			custom = {};
		}) do
			ReferenceButton:SetState(meta, meta, dummy)
			ReferenceButton:SetAttribute('state', meta)
			ReferenceButton:UpdateAction(true)
			self[meta] = getmetatable(ReferenceButton)
		end
		ReferenceButton:SetAttribute('state', 'empty')
		ReferenceButton:UpdateAction(true)
		return rawget(setmetatable(self, nil), k);
	end})
end

---------------------------------------------------------------
do -- LBG hook
---------------------------------------------------------------

local ShowOverlayGlow, HideOverlayGlow = LBG.ShowOverlayGlow, LBG.HideOverlayGlow;
function LBG.ShowOverlayGlow(button)
	if button.OnOverlayGlow then
		button:OnOverlayGlow(true)
	end
	if button.ShowOverlayGlow then
		return button:ShowOverlayGlow(LBG)
	end
	return ShowOverlayGlow(button)
end

function LBG.HideOverlayGlow(button)
	if button.OnOverlayGlow then
		button:OnOverlayGlow(false)
	end
	if button.HideOverlayGlow then
		return button:HideOverlayGlow(LBG)
	end
	return HideOverlayGlow(button)
end

end -- LBG hook

---------------------------------------------------------------
do Lib.RoundGlow = {}; -- Round LBG replacement
---------------------------------------------------------------

Lib.RoundGlow.unusedOverlays = Lib.RoundGlow.unusedOverlays or {}
Lib.RoundGlow.numOverlays = Lib.RoundGlow.numOverlays or 0

local tinsert, tremove, tostring = table.insert, table.remove, tostring
local AnimateTexCoords = AnimateTexCoords

local function OverlayGlowAnimOutFinished(animGroup)
	local overlay = animGroup:GetParent()
	local frame = overlay:GetParent()
	overlay:Hide()
	tinsert(Lib.RoundGlow.unusedOverlays, overlay)
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
	scale:SetTarget(target)
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay)
	local alpha = group:CreateAnimation('Alpha')
	alpha:SetTarget(target)
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
	Lib.RoundGlow.numOverlays = Lib.RoundGlow.numOverlays + 1

	-- create frame and textures
	local name = 'CPButtonGlowOverlay' .. tostring(Lib.RoundGlow.numOverlays)
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
	local overlay = tremove(Lib.RoundGlow.unusedOverlays)
	if not overlay then
		overlay = CreateOverlayGlow()
	end
	return overlay
end

function Lib.RoundGlow.ShowOverlayGlow(frame)
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
end

function Lib.RoundGlow.HideOverlayGlow(frame)
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

---------------------------------------------------------------
end -- Round LBG replacement
---------------------------------------------------------------