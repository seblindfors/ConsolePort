local _, env = ...;
---------------------------------------------------------------
local ART, TYPE_COLLAGE, TYPE_ARTIFACT = 'Art', env.Const.Art.Types();
---------------------------------------------------------------

local COLLAGE_PIECE_SIZE  = 256;
local COLLAGE_ATLAS_SIZE  = 1024;
local COLLAGE_STYLE_CLASS = 'Class';

---------------------------------------------------------------
local Collage = {};
---------------------------------------------------------------

function Collage:SetProps(props)
	local flavor = props.flavor == COLLAGE_STYLE_CLASS and CPAPI.GetClassFile() or env.Const.Art.Flavors[props.flavor];
	local fileID, texCoordOffset = unpack(env.Const.Art.Collage[flavor]);

	self.Cover:SetBlendMode(props.blend)
	self.Cover:SetTexture(env.Const.Art.CollageAsset:format(fileID))
	self.Cover:SetTexCoord(0, 1,
		( (texCoordOffset - 1) * COLLAGE_PIECE_SIZE ) / COLLAGE_ATLAS_SIZE,
		( texCoordOffset * COLLAGE_PIECE_SIZE ) / COLLAGE_ATLAS_SIZE)
end


---------------------------------------------------------------
local Artifact = {};
---------------------------------------------------------------

function Artifact:SetProps(props)
	local flavor = props.flavor == COLLAGE_STYLE_CLASS and CPAPI.GetClassFile() or env.Const.Art.Flavors[props.flavor];
	local atlas, lineOffset = unpack(env.Const.Art.Artifact[flavor]);

	local line = C_Texture.GetAtlasInfo(env.Const.Art.ArtifactLine:format(atlas));
	local rune = C_Texture.GetAtlasInfo(env.Const.Art.ArtifactRune:format(atlas));

	if not line or not rune then
		return;
	end

	local width, height = self:GetSize()
	local lineScale = width / line.width;
	local runeScale = height / rune.height;

	-- lines
	self.Lines:SetPoint('CENTER', 0, lineOffset * lineScale)
	self.Lines:SetTexture(line.file)
	self.Lines:SetTexCoord(line.leftTexCoord, line.rightTexCoord, line.topTexCoord, line.bottomTexCoord)
	self.Lines:SetSize(width, line.height * lineScale)
	self.Lines:SetBlendMode(props.blend)
	self.LinesMask:SetSize(self.Lines:GetSize())

	-- runes
	for _, runeTexture in ipairs(self.Runes) do
		runeTexture:SetTexture(rune.file)
		runeTexture:SetTexCoord(rune.leftTexCoord, rune.rightTexCoord, rune.topTexCoord, rune.bottomTexCoord)
		runeTexture:SetSize(rune.width * runeScale, rune.height * runeScale)
		runeTexture:SetBlendMode(props.blend)
	end
end

---------------------------------------------------------------
CPCoverArt = Mixin({
---------------------------------------------------------------
	Styles = {
		[TYPE_COLLAGE]  = { template = 'CPCollageArtTemplate',  mixin = Collage  };
		[TYPE_ARTIFACT] = { template = 'CPArtifactArtTemplate', mixin = Artifact };
	};
}, env.ConfigurableWidgetMixin, env.AnimatedWidgetMixin);

function CPCoverArt:SetProps(props)
	self:SetDynamicProps(props)
	self:OnDriverChanged()
	self:Show()
	for piece, data in pairs(self.Styles) do
		self:TogglePiece(piece, data, props.style == piece)
	end
end

function CPCoverArt:OnPropsUpdated()
	self:SetProps(self.props)
end

function CPCoverArt:TogglePiece(piece, data, show)
	if show then
		if not self[piece] then
			self[piece] = CreateFrame('Frame', nil, self, data.template)
			Mixin(self[piece], data.mixin)
		end
		self[piece]:SetProps(self.props)
		self[piece]:Show()
	elseif self[piece] then
		self[piece]:Hide()
	end
end

---------------------------------------------------------------
-- Cover art factory
---------------------------------------------------------------
env:AddFactory(ART, function(id)
	local frame = CreateFrame('Frame', env.MakeID('ConsolePortArt%s', id), env.Manager, 'CPCoverArt')
	return frame;
end, env.Interface.Art)