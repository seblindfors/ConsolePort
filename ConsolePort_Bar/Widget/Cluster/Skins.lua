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
local SkinOverlayGlow = env.LIB.Skin.ColorSwatchProc;
local SkinChargeCooldown = env.LIB.SkinUtility.SkinChargeCooldown;
---------------------------------------------------------------

local function SetRotatedMaskTexture(self, mask, prefix, direction)
    local maskTexture = Masks[prefix][direction];
    mask:SetTexture(maskTexture)
    self.Flash:SetTexture(maskTexture)
end

local function SetRotatedSwipeTexture(self, prefix, direction)
    local swipeTexture = Swipes[prefix][direction];
    self.__procText, self.__procSize = swipeTexture, 0.6;
    self.cooldown:SetSwipeTexture(swipeTexture)
    self.cooldown:SetBlingTexture(Assets.CooldownBling)
end

local function SetMainSwipeTexture(self)
    self.cooldown:SetSwipeTexture(Assets.MainSwipe)
    self.cooldown:SetBlingTexture(Assets.CooldownBling)
    self.__procText, self.__procSize = Assets.MainSwipe, 0.62;
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
        SkinOverlayGlow(self)
    end;
end