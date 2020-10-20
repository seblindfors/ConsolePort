local db, Carpenter, _, env = ConsolePort:DB(), LibStub:GetLibrary('Carpenter'), ...;
local Widgets = {}; env.Widgets = Widgets;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local COLOR_CHECKED = CPIndexButtonMixin.IndexColors.Checked;
local COLOR_HILITE  = CPIndexButtonMixin.IndexColors.Hilite;

---------------------------------------------------------------
-- Base widget object
---------------------------------------------------------------
local Widget = {};

function Widget:OnLoad(varID, data)
	self.metaData = data;
	self.variableID = varID;
	self.controller = data[1];
	self.tooltipText = data.desc;
	self.controller:SetCallback(function(value) db('Settings/'..varID, value) end)
end

function Widget:Get()
	return db(self.variableID)
end

function Widget:Set(...)
	self.controller:Set(...)
	self:OnValueChanged(self:Get())
end

function Widget:SetCallback(callback)
	self.controller:SetCallback(callback)
end

function Widget:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self, 'ANCHOR_TOP')
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end
end

function Widget:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Widget:OnValueChanged(newValue)
	-- replace callback in mixin
end

---------------------------------------------------------------
-- Boolean switch
---------------------------------------------------------------
local Bool = CreateFromMixins(Widget);

function Bool:OnLoad(varID, data)
	Widget.OnLoad(self, varID, data)
	Carpenter:BuildFrame(self, {
		CheckBorder = {
			_Type  = 'Texture';
			_Setup = {'BACKGROUND'};
			_Point = {'RIGHT', -8, 0};
			_Size  = {24, 24};
		};
		CheckFill = {
			_Type  = 'Texture';
			_Setup = {'BORDER'};
			_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
			_Size  = {20, 20};
			_SetColorTexture = {0, 0, 0, 1};
		};
		CheckedTexture = {
			_Type  = 'Texture';
			_Hide  = true;
			_Setup = {'BORDER'};
			_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
			_Size  = {12, 12};
			_SetColorTexture = {COLOR_CHECKED:GetRGBA()};
		};
		CheckedHilite = {
			_Type  = 'Texture';
			_Setup = {'HIGHLIGHT'};
			_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
			_Size  = {12, 12};
			_Texture = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Vertex_White');
			_Vertex = {COLOR_HILITE:GetRGBA()};
		};
	}, false, true)
end

function Bool:OnValueChanged(state)
	self.CheckedTexture:SetShown(state)
	self.CheckedHilite:SetShown(not state)
	if state then
		self.CheckBorder:SetColorTexture(COLOR_CHECKED:GetRGBA())
	else
		self.CheckBorder:SetColorTexture(0.25, 0.25, 0.25, 1)
	end
end

function Bool:OnShow()
	self:OnValueChanged(self:Get())
end

function Bool:OnClick()
	self:SetChecked(false)
	self:OnChecked(false)
	self:Set(not self:Get())
end

function Widgets.Bool(self, varID, data)
	db.table.mixin(self, Bool)
	self:OnLoad(varID, data)
end