local _, env = ...;
---------------------------------------------------------------
local Skins = {}; env.LIB.Skin.ClusterBar = Skins;
---------------------------------------------------------------
local NOMOD = env.ClusterConstants.ModNames();
---------------------------------------------------------------
local Masks = env.ClusterConstants.Masks;
local Swipes = env.ClusterConstants.Swipes;
local Assets = env.ClusterConstants.Assets;
local AdjustTextures = env.ClusterConstants.AdjustTextures;
local GetIconMask = env.LIB.SkinUtility.GetIconMask;
local GetSlotBackground = env.LIB.SkinUtility.GetSlotBackground;
local SkinOverlayGlow = env.LIB.SkinUtility.SkinOverlayGlow;
local SkinChargeCooldown = env.LIB.SkinUtility.SkinChargeCooldown;
---------------------------------------------------------------

local function SetRotatedMaskTexture(self, mask, prefix, direction)
    local maskTexture = Masks[prefix][direction];
    mask:SetTexture(maskTexture)
    self.Flash:SetTexture(maskTexture)
end

local function SetRotatedSwipeTexture(self, prefix, direction)
    local swipeTexture = Swipes[prefix][direction];
    self.procTexture, self.procSize = swipeTexture, 0.6;
    self.cooldown:SetSwipeTexture(swipeTexture)
    self.cooldown:SetBlingTexture(Assets.CooldownBling)
end

local function SetMainSwipeTexture(self)
    self.cooldown:SetSwipeTexture(Assets.MainSwipe)
    self.cooldown:SetBlingTexture(Assets.CooldownBling)
    self.procTexture, self.procSize = Assets.MainSwipe, 0.62;
    if self.swipeColor then
        self.cooldown:SetSwipeColor(self.swipeColor:GetRGBA())
    end
end

local function SetTextures(self, adjustTextures, coords, texSize)
    for key, file in pairs(adjustTextures) do
        local texture = self[key];
        if texture then
            if coords then
                texture:SetTexCoord(unpack(coords))
            end
            texture:SetTexture(file)
            texture:ClearAllPoints()
            texture:SetPoint('CENTER', 0, 0)
            texture:SetSize(texSize, texSize)
        end
    end
    self.HighlightTexture:SetBlendMode('ADD')
end

local function SetBackground(self, mask)
    local bg = GetSlotBackground(self)
    bg:SetDrawLayer('BACKGROUND', -8)
    bg:SetAllPoints(self.icon)
    bg:SetTexture(Assets.EmptyIcon)
    bg:AddMaskTexture(mask)
    bg:SetDesaturated(true)
    bg:SetVertexColor(0.5, 0.5, 0.5, 1)
    if ( self.mod == NOMOD ) then
        mask:SetTexture(Assets.MainMask)
    end
    mask:SetAllPoints(self.icon)
end

local function OnChargeCooldownSet(self)
    self:SetUseCircularEdge(true)
end

local function OnChargeCooldownUnset(self)
    self:SetUseCircularEdge(false)
end

local OverlayPool = CreateFramePool('Frame', UIParent, 'CPFlashableFiligreeTemplate')
local SwatchPool = CreateFramePool('Frame', UIParent, 'CPSwatchHighlightTemplate')

local function OnShowOverlay(self)
    local overlay, swatch = self.overlay, self.swatch;
    if not overlay then
        overlay = OverlayPool:Acquire()
        overlay:SetParent(self:GetParent())
        overlay:SetFrameLevel(2)
        overlay:SetAnchor(self)
        overlay:SetSize(self:GetSize() * 2)
        overlay:SetScale(self.procSize)
        overlay:SetTexture(self.SpellHighlightTexture:GetTexture())
        overlay:SetTexCoord(self.SpellHighlightTexture:GetTexCoord())
        overlay:SetAnimationSpeedMultiplier(0.75)
        overlay.filigreeAnim:SetLooping('BOUNCE')
        overlay:Show()
    end
    if not swatch then
        swatch = SwatchPool:Acquire()
        swatch:SetParent(self)
        swatch:SetAllPoints(self)
        swatch:SetTexture(self.procTexture)
        swatch:Show()
    end
    overlay:Stop()
    overlay:Play()
    self:GetParent().ProcAnimation:Play()
    self.overlay, self.swatch = overlay, swatch;
end

local function OnHideOverlay(self)
    OverlayPool:Release(self.overlay)
    SwatchPool:Release(self.swatch)
    self.SpellHighlightTexture:Hide()
    self.SpellHighlightAnim:Stop()
    self.overlay, self.swatch = nil, nil;
end

for mod, data in pairs(env.ClusterConstants.Layout) do
    local prefix  = data.Prefix;
    local offset  = data.TexSize or 1;
    local adjust  = AdjustTextures[mod];

    Skins[mod] = function(self, force)
        local direction = self.direction;
        if direction then
            SetRotatedSwipeTexture(self, prefix, direction)
        else
            SetMainSwipeTexture(self)
        end
        SkinChargeCooldown(self, OnChargeCooldownSet, OnChargeCooldownUnset)

        if not force then return end;
        local size = self:GetSize()
        local mask = GetIconMask(self)
        local coords = direction and data[direction].Coords;
        SetTextures(self, adjust, coords, size * offset)
        SetBackground(self, mask)
        if direction then
            SetRotatedMaskTexture(self, mask, prefix, direction)
        end
        SkinOverlayGlow(self, OnShowOverlay, OnHideOverlay)
    end;
end