local env = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Skins = {}; env.LIB.Skin.ClusterBar = Skins;
---------------------------------------------------------------
local SkinUtility          = env.LIB.SkinUtility;
local ASSETS               = env.Const.Cluster.Assets;
---------------------------------------------------------------
local CLUSTER_DESIGN      = env.Const.ClusterDesign;
local FLYOUT_PARTS        = {M1 = 'FlyoutSide'; M2 = 'FlyoutSide'; M3 = 'FlyoutMiddle';};
local FLYOUT_MODIFIERS    = {M1 = 'Shift'; M2 = 'Ctrl'; M3 = 'ShiftCtrl';};
local FULL_TEX_COORDS     = {0; 1; 0; 1;};
local MIDDLE_MASK_INSET   = 1 / 46; -- one pixel per side at the default flyout size
local COOLDOWN_MASK_PATH  = [[Textures\Masks\Cooldowns\%s]];

local function getClusterBorderTextures(design, part)
	local path      = env.GetAsset([[Textures\Cluster\%s\%s]], design, part);
	local normal    = path .. '';
	local highlight = path .. 'Highlight';
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

local goldMainTextures = getClusterBorderTextures('RoundGold', 'Main');

local function getSilverMainTextures(design, pushHighlight)
	local textures = getClusterBorderTextures(design, 'Main');
	if pushHighlight then
		textures.PushedTexture = textures.HighlightTexture;
	end
	textures.Flash = env.GetAsset([[Textures\Button\Hilite2x]]);
	textures.SpellHighlightTexture = env.GetAsset([[Textures\Button\Hilite2x.png]]);
	return textures;
end

local function getRoundSilverFlyoutTextures(part)
	local textures = getClusterBorderTextures('RoundSilver', part);
	textures.Border = textures.NormalTexture;
	return textures;
end

local silverTextures = {
	[CLUSTER_DESIGN.Original] = {
		Main         = getSilverMainTextures('RoundSilver', true);
		FlyoutSide   = getRoundSilverFlyoutTextures('FlyoutSide');
		FlyoutMiddle = getRoundSilverFlyoutTextures('FlyoutMiddle');
	};
	[CLUSTER_DESIGN.Beveled] = {
		Main         = getSilverMainTextures('BeveledSilver');
		FlyoutSide   = getClusterBorderTextures('BeveledSilver', 'FlyoutSide');
		FlyoutMiddle = getClusterBorderTextures('BeveledSilver', 'FlyoutMiddle');
	};
};

local function getProcFlipBook(asset)
	local path = env.GetAsset([[Textures\Cluster\Glow\Flipbooks\%s]], asset);
	return {Start = path .. 'Start'; Loop = path .. 'Loop';};
end

local roundProcGlow = getProcFlipBook('Round');

local function getShapeSkins(design, asset, orientation)
	local slots = {Shadow = env.GetAsset([[Textures\Cluster\%s\Shadow%s]], design, orientation);};
	for _, slot in ipairs({'Main'; 'Flyout';}) do
		local isMain = slot == 'Main';
		slots[slot] = {
			Border       = getClusterBorderTextures(design, slot .. orientation);
			Mask         = env.GetAsset([[Textures\Cluster\Shapes\%s%sMask]], asset, slot);
			MaskShape    = asset .. slot;
			ProcGlow     = isMain and getProcFlipBook(asset) or env.GetAsset([[Textures\Cluster\Glow\%sFlyout]], asset);
		};
	end
	return slots;
end

local shapeSkins = {};
for _, shape in pairs(env.Const.Cluster.GoldShapes) do
	local design = shape.Asset .. 'Gold';
	local slots  = getShapeSkins(design, shape.Asset, shape.HorizontalAsset and 'Vertical' or '');
	if shape.HorizontalAsset then
		slots.Horizontal = getShapeSkins(design, shape.HorizontalAsset, 'Horizontal');
	end
	shapeSkins[shape] = slots;
end

local function setBorders(self, textures, coords, texSize)
	for key, file in pairs(textures) do
		local texture = self[key];
		if texture then
			texture:SetTexture(file)
			if coords then
				texture:SetTexCoord(unpack(coords))
			end
			if texture.SetTexelSnappingBias and texture.SetSnapToPixelGrid then
				texture:SetTexelSnappingBias(0)
				texture:SetSnapToPixelGrid(false)
			end
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
	-- LAB uses Border for equipped items.
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
	-- Put macro text above the hover border, using the native text frame when available.
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

	-- Keep native border states on the button, above the icon and both timers.
	local iconFrame = CreateFrame('Frame', nil, button);
	iconFrame:SetAllPoints(button)
	iconFrame:SetFrameLevel(iconLevel)
	button.icon:SetParent(iconFrame)
	button.icon:SetDrawLayer('BACKGROUND')
	button.NormalTexture:SetDrawLayer('OVERLAY')

	background:SetParent(iconFrame)
	background:SetDrawLayer('BACKGROUND', -8)
	background:SetAllPoints(button.icon)
	background:SetTexture(ASSETS.EmptyIcon)
	background:AddMaskTexture(mask)
	background:SetDesaturated(true)

	local effectLevel = iconLevel + 1;
	button:SetCooldownFrameLevel(effectLevel)
	local cast  = button.SpellCastAnimFrame;
	if not cast then return end;
	if cast.SetUsingParentLevel then cast:SetUsingParentLevel(false) end;
	cast:SetFrameLevel(effectLevel)
	local fill, burst = cast.Fill, cast.EndBurst;
	fill.CastFill:RemoveMaskTexture(fill.FillMask)
	burst.GlowRing:RemoveMaskTexture(burst.EndMask)
	-- Anchor the tint to the visible icon so rounded and wedge buttons get the same coverage.
	fill.InnerGlowTexture:ClearAllPoints()
	fill.InnerGlowTexture:SetAllPoints(mask)
	fill.InnerGlowTexture:AddMaskTexture(mask)
	fill.CastFill:AddMaskTexture(mask)
	burst.GlowRing:AddMaskTexture(mask)
end

local function setBackgroundColor(background, goldBorders)
	if goldBorders then
		background:SetVertexColor(env.Const.Cluster.GoldEmptySlotColor:GetRGBA())
	else
		background:SetVertexColor(0.5, 0.5, 0.5, 1)
	end
end

---------------------------------------------------------------
-- Skins by modifier slot
---------------------------------------------------------------
for mod, data in pairs(env.Const.Cluster.Layout) do
	local prefix          = data.Prefix;
	local coords          = data.Coords;
	local borderScale     = data.TexSize or 1;
	local borderPart      = FLYOUT_PARTS[prefix] or 'Main';
	local goldByDirection = {};
	local procGlow        = prefix and env.GetAsset([[Textures\Cluster\Glow\%s]], prefix == 'M3' and 'M3' or 'M1')
		or roundProcGlow;
	if prefix then
		for direction in pairs(env.Const.Cluster.Directions) do
			local directionName = direction:sub(1, 1) .. direction:sub(2):lower();
			local part          = 'Flyout' .. FLYOUT_MODIFIERS[prefix] .. directionName;
			goldByDirection[direction] = getClusterBorderTextures('RoundGold', part);
		end
	end

	Skins[mod] = function(self)
		local direction = self.direction;
		local slots     = shapeSkins[self.clusterShape];
		local design    = env('clusterDesign');
		-- Turn the hex so the side flyouts meet a flat edge of the main button.
		if ( slots and slots.Horizontal and (self.clusterDirection == 'LEFT' or self.clusterDirection == 'RIGHT') ) then
			slots = slots.Horizontal;
		end
		local shape = slots and (prefix and slots.Flyout or slots.Main);
		local size = self:GetWidth();

		local mask = SkinUtility.GetIconMask(self);
		local goldBorders = env:IsGoldClusterDesign();
		local gold = not prefix and goldMainTextures or goldByDirection[direction or 'DOWN'];
		local silver = silverTextures[design] or silverTextures[CLUSTER_DESIGN.Original];
		local borders = shape and shape.Border or goldBorders and gold or silver[borderPart];
		local maskShape = shape and shape.MaskShape or direction and prefix .. '_' .. direction or 'Round';
		local swipe = env.GetAsset(COOLDOWN_MASK_PATH, maskShape);

		-- A directed flyout uses the same silhouette for its icon and cooldown.
		-- Round-design wedges reach the texture boundary and need transparent clamping.
		if direction then
			local wrap = not shape and 'CLAMPTOBLACKADDITIVE' or nil;
			mask:SetTexture(swipe, wrap, wrap)
		elseif shape or not prefix then
			mask:SetTexture(shape and shape.Mask or ASSETS.MainMask)
		end
		self:SetCooldownSwipeTexture(swipe)

		if ( data.Shadow and self.Shadow ) then
			self.Shadow:SetShapeTexture(slots and slots.Shadow)
		end
		local tcoords = shape and FULL_TEX_COORDS or coords or direction and data[direction].Coords;
		setBorders(self, borders, tcoords, not shape and size * borderScale or nil)
		-- The Round Silver middle wedge's mask extends past its smaller rim.
		local insetMask = prefix == 'M3' and design == CLUSTER_DESIGN.Original;
		anchorMask(self, mask, insetMask)
		env:SetClusterPulseShape(self, maskShape)
		local background = SkinUtility.GetSlotBackground(self);
		initializeSkinLayers(self, mask, background)
		setBackgroundColor(background, goldBorders)
		-- Enlarge the streak so its bright tip reaches the round or polygonal main rim.
		self:LayoutCooldowns(mask, not prefix and (shape and 1.25 or 1.2), maskShape)
		local maskWidth = mask:GetWidth();
		if self.SpellCastAnimFrame and maskWidth > 0 then
			-- Blizzard's fill travels across a roughly 46-pixel icon.
			self.SpellCastAnimFrame:SetScale(maskWidth / 46)
		end
		raiseButtonName(self)
		self:SetProcGlowTexture(shape and shape.ProcGlow or procGlow)
		self.Name:SetWidth(size)
	end;
end
