local _, localEnv = ...;
local env, db, L = unpack(localEnv)
----------------------------------------------------------------
local Panel, BlockMixin = {}, CreateFromMixins(env.ScaleToContentMixin);
local PANEL_WIDTH = localEnv.PANEL_WIDTH;

function BlockMixin:OnLoad()
	self:SetMeasurementOrigin(self, self, PANEL_WIDTH, 0)
	self.Label = self:CreateFontString()
	self.Label:SetPoint('TOPLEFT', 24, -6)
	self.Label:SetFontObject(GameFontGreen)
	self.Label:SetText(self.text)
end

function Panel:OnFirstShow()
	local function FlyoutPopoutButtonSetReversed(self, isReversed)
		if ( self:GetParent().verticalFlyout ) then
			if ( isReversed ) then
				self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0, 0.5);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 0.5, 1);
			else
				self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			end
		else
			if ( isReversed ) then
				self:GetNormalTexture():SetTexCoord(0.15625, 0, 0.84375, 0, 0.15625, 0.5, 0.84375, 0.5);
				self:GetHighlightTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 1, 0.84375, 1);
			else
				self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
				self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			end
		end
	end
	
	local config = self:CreateScrollableColumn('Config', {
		_Mixin = localEnv.Display;
		_Width = PANEL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', 0, -1};
		};
		{
			Flexer = {
				_Type = 'CheckButton';
				_Setup = 'BackdropTemplate';
				_Mixin = env.FlexibleMixin;
				_Width = 24;
				_Points = {
					{'TOPLEFT', 'parent', 'TOPRIGHT', 0, 0};
					{'BOTTOMLEFT', 'parent', 'BOTTOMRIGHT', 0, 0};
				};
				_Backdrop = CPAPI.Backdrops.Opaque;
				_SetBackdropBorderColor = {0.15, 0.15, 0.15, 1};
				_SetNormalTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				_SetHighlightTexture = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['state'] = true;
				_OnLoad = function(self)
					local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
					self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
					CPAPI.SetGradient(self.Center, 'HORIZONTAL', r*2, g*2, b*2, 1, r/1.25, g/1.25, b/1.25, 1)
					local normal = self:GetNormalTexture()
					local hilite = self:GetHighlightTexture()
					normal:ClearAllPoints()
					normal:SetPoint('CENTER', -1, 0)
					normal:SetSize(16, 32)
					hilite:ClearAllPoints()
					hilite:SetPoint('CENTER', -1, 0)
					hilite:SetSize(16, 32)
					FlyoutPopoutButtonSetReversed(self, true)
					self:SetFlexibleElement(self:GetParent(), PANEL_WIDTH)
					self:SetChecked(true)
				end;
				_OnClick = function(self)
					local enabled = self:GetChecked()
					FlyoutPopoutButtonSetReversed(self, self:GetChecked())
					self:ToggleFlex(enabled)
				end;
			};
			Child = {
				_Width = PANEL_WIDTH;
				{
					DeviceSelect = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = localEnv.DeviceSelect;
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', 0, -32};
						{
							TopText = {
								_Type = 'FontString';
								_Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 8, 8};
								_OnLoad = function(self)
									self:SetFontObject(GameFontNormal)
									self:SetText(L'Selected device:')
								end;
							};
						};
					};
					Raw = {
						_Type  = 'IndexButton';
						_Mixin = localEnv.Wrapper;
						_Text  = L'Raw state';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.DeviceSelect', 'BOTTOM', 0, -8};
						fixedHeight = localEnv.STATE_VIEW_HEIGHT;
						{
							Content = {
								{
									RawAxes = {
										_Type = 'Frame';
										_Point = {'TOPRIGHT', '$parent', 'TOP', 0, 0};
										_Height = 200;
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Raw Axes:')
												end;
											};
										};
									};
									RawButtons = {
										_Type  = 'Frame';
										_Point = {'TOPLEFT', '$parent', 'TOP', 0, 0};
										_Size  = {240, 200};
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Raw Buttons:')
												end;
											};
										};
									};
								};
							};
						};
					};
					Map = {
						_Type  = 'IndexButton';
						_Mixin = localEnv.Wrapper;
						_Text  = L'Mapped state';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.Raw', 'BOTTOM', 0, -8};
						fixedHeight = localEnv.STATE_VIEW_HEIGHT;
						{
							Content = {
								{
									MapAxes = {
										_Type = 'Frame';
										_Point = {'TOPRIGHT', '$parent', 'TOP', 0, 0};
										_Height = 200;
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Mapped Axes:')
												end;
											};
										};
									};
									MapButtons = {
										_Type  = 'Frame';
										_Point = {'TOPLEFT', '$parent', 'TOP', 0, 0};
										_Size  = {240, 200};
										{
											TopText = {
												_Type = 'FontString';
												_Point = {'TOPLEFT', 0, 0};
												_OnLoad = function(self)
													self:SetFontObject(GameFontNormal)
													self:SetText(L'Mapped Buttons:')
												end;
											};
										};
									};
								};
							};
						};
					};
					Config = {
						_Type  = 'IndexButton';
						_Mixin = localEnv.Config;
						_Text  = L'Configuration';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Width = PANEL_WIDTH - 32;
						_Point = {'TOP', '$parent.Map', 'BOTTOM', 0, -8};
						{
							Content = {
								{
									RawAxisBlock = {
										text   = L'Raw Axis -> Mapped Axis';
										struct = 'rawAxisMappings';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', 0, 0};
									};
									RawButtonBlock = {
										text   = L'Raw Button -> Mapped Button';
										struct = 'rawButtonMappings';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.RawAxisBlock', 'BOTTOM', 0, 0};
									};
									MappedAxisBlock = {
										text   = L'Mapped Axes';
										struct = 'axisConfigs';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.RawButtonBlock', 'BOTTOM', 0, 0};
									};
									StickBlock = {
										text   = L'Stick Configuration';
										struct = 'stickConfigs';
										_Type  = 'Frame';
										_Mixin = BlockMixin;
										_Size  = {PANEL_WIDTH, 40};
										_Point = {'TOP', '$parent.MappedAxisBlock', 'BOTTOM', 0, 0};
									};
								};
							};
						};
					};
				};
			};
		};
	})
	config:Init()
end

env.Mapper = ConsolePortConfig:CreatePanel({
	name = L'Mapper';
	mixin = Panel;
	scaleToParent = true;
	forbidRecursiveScale = true;
})