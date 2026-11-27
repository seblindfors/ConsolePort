local env = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Skins = {}; env.LIB.Skin.ClusterBar = Skins;
---------------------------------------------------------------
local SkinUtility    = env.LIB.SkinUtility;
local Const          = env.Const.Cluster;
local Assets         = Const.Assets;
local AssetFormats   = Const.AssetFormats;
local Designs        = Const.Designs;
local CLUSTER_DESIGN = env.Const.ClusterDesign;
---------------------------------------------------------------
local FULL_TEX_COORDS        = {0; 1; 0; 1;};
local MIDDLE_MASK_INSET      = 1 / 46;
local CAST_FILL_NATIVE_SIZE  = 46;
local MAIN_EDGE_SCALE        = 1.2;
local SHAPED_MAIN_EDGE_SCALE = 1.25;
local MAIN_PART, FLYOUT_PART = 'Main', 'Flyout';
local ROUND_SHAPE            = 'Round';
local WEDGE_SHAPE            = '%s_%s';
local ROUND_SILVER           = Designs[CLUSTER_DESIGN.Original].Directory;
local BEVELED_SILVER         = Designs[CLUSTER_DESIGN.Beveled].Directory;
local ROUND_GOLD             = Designs[CLUSTER_DESIGN.OriginalGold].Directory;
---------------------------------------------------------------
local SetUsingParentLevel    = UIParent.SetUsingParentLevel or nop;
local disablePixelSnapping   = nop;

do local probe = UIParent:CreateTexture();
	if ( probe.SetTexelSnappingBias and probe.SetSnapToPixelGrid ) then
		function disablePixelSnapping(texture)
			texture:SetTexelSnappingBias(0)
			texture:SetSnapToPixelGrid(false)
		end
	end
end

---------------------------------------------------------------
-- Textures by design
---------------------------------------------------------------
local function getClusterBorderTextures(directory, part)
	local normal    = AssetFormats.Border:format(directory, part);
	local highlight = AssetFormats.BorderHighlight:format(directory, part);
	return {
		NormalTexture         = normal;
		Border                = highlight;
		PushedTexture         = normal;
		HighlightTexture      = highlight;
		CheckedTexture        = highlight;
		NewActionTexture      = highlight;
		SpellHighlightTexture = highlight;
		Flash                 = highlight;
	};
end

local function getSilverMainTextures(directory, pushHighlight)
	local textures = getClusterBorderTextures(directory, MAIN_PART);
	if pushHighlight then
		textures.PushedTexture = textures.HighlightTexture;
	end
	textures.Flash                 = Assets.SilverFlash;
	textures.SpellHighlightTexture = Assets.SilverSpellHighlight;
	return textures;
end

local function getRoundSilverFlyoutTextures(part)
	local textures = getClusterBorderTextures(ROUND_SILVER, part);
	textures.Border = textures.NormalTexture;
	return textures;
end

local function getProcFlipBook(shape)
	return {
		Start = AssetFormats.ProcStart:format(shape);
		Loop  = AssetFormats.ProcLoop:format(shape);
	};
end

local function getShapeSkins(directory, asset, orientation)
	local slots = {Shadow = AssetFormats.ShapeShadow:format(directory, orientation);};
	for _, slot in ipairs({MAIN_PART; FLYOUT_PART;}) do
		local isMain = slot == MAIN_PART;
		slots[slot] = {
			Border    = getClusterBorderTextures(directory, slot .. orientation);
			Mask      = AssetFormats.ShapeMask:format(asset, slot);
			MaskShape = asset .. slot;
			ProcGlow  = isMain and getProcFlipBook(asset) or AssetFormats.ProcFlyout:format(asset);
		};
	end
	return slots;
end

local goldMainTextures = getClusterBorderTextures(ROUND_GOLD, MAIN_PART);
local roundProcGlow    = getProcFlipBook(ROUND_SHAPE);

local silverTextures = {
	[CLUSTER_DESIGN.Original] = {
		Main         = getSilverMainTextures(ROUND_SILVER, true);
		FlyoutSide   = getRoundSilverFlyoutTextures('FlyoutSide');
		FlyoutMiddle = getRoundSilverFlyoutTextures('FlyoutMiddle');
	};
	[CLUSTER_DESIGN.Beveled] = {
		Main         = getSilverMainTextures(BEVELED_SILVER);
		FlyoutSide   = getClusterBorderTextures(BEVELED_SILVER, 'FlyoutSide');
		FlyoutMiddle = getClusterBorderTextures(BEVELED_SILVER, 'FlyoutMiddle');
	};
};

local shapeSkins = {};
for design, shape in pairs(Const.GoldShapes) do
	local directory = Designs[design].Directory;
	local slots     = getShapeSkins(directory, shape.Asset, shape.HorizontalAsset and 'Vertical' or '');
	if shape.HorizontalAsset then
		slots.Horizontal = getShapeSkins(directory, shape.HorizontalAsset, 'Horizontal');
	end
	shapeSkins[shape] = slots;
end

---------------------------------------------------------------
-- Skin helpers
---------------------------------------------------------------
local function setBorders(self, textures, coords, texSize)
	for key, file in pairs(textures) do
		local texture = self[key];
		if texture then
			texture:SetTexture(file)
			if coords then
				texture:SetTexCoord(unpack(coords))
			end
			disablePixelSnapping(texture)
			texture:ClearAllPoints()
			if texSize then
				texture:SetPoint('CENTER', 0, 0)
				texture:SetSize(texSize, texSize)
			else
				texture:SetAllPoints(self.icon)
			end
		end
	end

	self.HighlightTexture:SetBlendMode('ADD')
	self.PushedTexture:SetBlendMode(env('clusterDesign') == CLUSTER_DESIGN.Original and 'ADD' or 'BLEND')
	self.CheckedTexture:SetBlendMode('ADD')
	self.PushedTexture:SetDrawLayer('OVERLAY', 2)
	self.CheckedTexture:SetDrawLayer('OVERLAY', 1)
	self.Border:SetBlendMode('BLEND')
	self.Border:SetDrawLayer('OVERLAY', 1)
	self.Border:SetDesaturated(true)
	if self.borderColor then
		self:SetBorderColor(self.borderColor)
	end
	if self.BorderShadow then
		self.BorderShadow:SetTexture(nil)
	end
end

local function raiseButtonName(button)
	local overlay = button.TextOverlayContainer or button.clusterTextOverlay;
	if not overlay then
		overlay = CreateFrame('Frame', nil, button);
		overlay:SetAllPoints(button)
		overlay:SetFrameLevel(button:GetFrameLevel() + 1)
		button.clusterTextOverlay = overlay;
	end
	button.Name:SetParent(overlay)
end

local function anchorMask(button, mask, insetMask)
	local icon = button.icon;
	mask:ClearAllPoints()
	if insetMask then
		local x = icon:GetWidth() * MIDDLE_MASK_INSET;
		local y = icon:GetHeight() * MIDDLE_MASK_INSET;
		mask:SetPoint('TOPLEFT', icon, 'TOPLEFT', x, -y)
		mask:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', -x, y)
	else
		mask:SetAllPoints(icon)
	end
end

local function initializeSkinLayers(button, mask, background)
	if button.clusterSkinLayered then return end;
	button.clusterSkinLayered = true;
	local iconLevel = button:GetFrameLevel();
	button:SetFrameLevel(iconLevel + 2)

	local iconFrame = CreateFrame('Frame', nil, button);
	iconFrame:SetAllPoints(button)
	iconFrame:SetFrameLevel(iconLevel)
	button.icon:SetParent(iconFrame)
	button.icon:SetDrawLayer('BACKGROUND')
	button.NormalTexture:SetDrawLayer('OVERLAY')

	background:SetParent(iconFrame)
	background:SetDrawLayer('BACKGROUND', -8)
	background:SetAllPoints(button.icon)
	background:SetTexture(Assets.EmptyIcon)
	background:AddMaskTexture(mask)
	background:SetDesaturated(true)

	local effectLevel = iconLevel + 1;
	button:SetCooldownFrameLevel(effectLevel)
	local cast = button.SpellCastAnimFrame;
	if not cast then return end;
	SetUsingParentLevel(cast, false)
	cast:SetFrameLevel(effectLevel)
	local fill, burst = cast.Fill, cast.EndBurst;
	fill.CastFill:RemoveMaskTexture(fill.FillMask)
	burst.GlowRing:RemoveMaskTexture(burst.EndMask)
	fill.InnerGlowTexture:ClearAllPoints()
	fill.InnerGlowTexture:SetAllPoints(mask)
	fill.InnerGlowTexture:AddMaskTexture(mask)
	fill.CastFill:AddMaskTexture(mask)
	burst.GlowRing:AddMaskTexture(mask)
end

local function setBackgroundColor(background, goldBorders)
	local color = goldBorders and Const.GoldEmptySlotColor or Const.EmptySlotColor;
	background:SetVertexColor(color:GetRGBA())
end

---------------------------------------------------------------
-- Skins by modifier slot
---------------------------------------------------------------
for mod, data in pairs(Const.Layout) do
	local prefix          = data.Prefix;
	local coords          = data.Coords;
	local borderScale     = data.TexSize or 1;
	local borderPart      = data.Part;
	local goldByDirection = {};
	local procGlow        = prefix and AssetFormats.ProcWedge:format(data.Glow) or roundProcGlow;
	if prefix then
		for direction in pairs(Const.Directions) do
			local directionName = direction:sub(1, 1) .. direction:sub(2):lower();
			goldByDirection[direction] = getClusterBorderTextures(ROUND_GOLD, data.GoldPart .. directionName);
		end
	end

	Skins[mod] = function(self)
		local direction    = self.direction;
		local slots        = shapeSkins[self.clusterShape];
		local design       = env('clusterDesign');
		local isHorizontal = self.clusterDirection == 'LEFT' or self.clusterDirection == 'RIGHT';
		if ( slots and slots.Horizontal and isHorizontal ) then
			slots = slots.Horizontal;
		end
		local shape = slots and (prefix and slots.Flyout or slots.Main);
		local size  = self:GetWidth();

		local mask        = SkinUtility.GetIconMask(self);
		local goldBorders = env:IsGoldClusterDesign();
		local gold        = not prefix and goldMainTextures or goldByDirection[direction or 'DOWN'];
		local silver      = silverTextures[design] or silverTextures[CLUSTER_DESIGN.Original];
		local borders     = shape and shape.Border or goldBorders and gold or silver[borderPart];
		local maskShape   = shape and shape.MaskShape
			or direction and WEDGE_SHAPE:format(prefix, direction)
			or ROUND_SHAPE;
		local swipe       = AssetFormats.CooldownMask:format(maskShape);

		if direction then
			local wrap = not shape and 'CLAMPTOBLACKADDITIVE' or nil;
			mask:SetTexture(swipe, wrap, wrap)
		elseif ( shape or not prefix ) then
			mask:SetTexture(shape and shape.Mask or Assets.MainMask)
		end
		self:SetCooldownSwipeTexture(swipe)

		if ( data.Shadow and self.Shadow ) then
			self.Shadow:SetShapeTexture(slots and slots.Shadow)
		end
		local tcoords   = shape and FULL_TEX_COORDS or coords or direction and data[direction].Coords;
		local insetMask = prefix == 'M3' and design == CLUSTER_DESIGN.Original;
		setBorders(self, borders, tcoords, not shape and size * borderScale or nil)
		anchorMask(self, mask, insetMask)
		env:SetClusterPulseShape(self, maskShape)

		local background = SkinUtility.GetSlotBackground(self);
		initializeSkinLayers(self, mask, background)
		setBackgroundColor(background, goldBorders)
		self:LayoutCooldowns(mask, not prefix and (shape and SHAPED_MAIN_EDGE_SCALE or MAIN_EDGE_SCALE), maskShape)

		local maskWidth = mask:GetWidth();
		if ( self.SpellCastAnimFrame and maskWidth > 0 ) then
			self.SpellCastAnimFrame:SetScale(maskWidth / CAST_FILL_NATIVE_SIZE)
		end
		raiseButtonName(self)
		self:SetProcGlowTexture(shape and shape.ProcGlow or procGlow)
		self.Name:SetWidth(size)
	end;
end
