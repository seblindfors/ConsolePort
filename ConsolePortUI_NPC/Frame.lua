local _, L = ...
local db = ConsolePort:GetData()
local KEY = db.KEY
local UI = ConsolePortUI
local Control = UI:GetControlHandle()
L.db = db

local frame = UI:CreateFrame('Frame', 'ConsolePortUI_NPC', UIParent, 'SecureHandlerBaseTemplate', {
	Inspector = {
		Type = 'Frame',
		Hide = true,
		Point = {'CENTER', UIParent, 'CENTER', 0, 0},
		Size = {1, 1},
		Scale = 1.1,
		HintText = CHOOSE,
		ignoreRegions = true,
		Mixin = 'AdjustToChildren',
		Multiple = {
			SetScript = {
				{'OnEvent', function(self)
					local button = self:GetFocus()
					if button then
						local tooltip = button:GetParent()
						if IsShiftKeyDown() then
							GameTooltip_ShowCompareItem(tooltip)
							tooltip.shoppingTooltips[1]:SetScale(1.25)
							tooltip.shoppingTooltips[2]:SetScale(1.25)
							for _, other in self:GetActive() do
								if other ~= button then
									local otherTtip = other:GetParent()
									db.UIFrameFadeOut(otherTtip, 0.2, otherTtip:GetAlpha(), 0.25)
								end
							end
						else
							tooltip.shoppingTooltips[1]:SetScale(1)
							tooltip.shoppingTooltips[1]:Hide()
							tooltip.shoppingTooltips[2]:SetScale(1)
							tooltip.shoppingTooltips[2]:Hide()
							for _, other in self:GetActive() do
								local otherTtip = other:GetParent()
								db.UIFrameFadeIn(otherTtip, 0.2, otherTtip:GetAlpha(), 1)
							end
						end
					end
				end},
				{'OnShow', function(self)
					local cc = ConsolePortUI.Media.CC
					local parent = self:GetParent()
					local _, cross = Control:GetHintForKey(KEY.CROSS)
					local _, circle = Control:GetHintForKey(KEY.CIRCLE)
					local _, square = Control:GetHintForKey(KEY.SQUARE)
					self.CROSS = cross
					self.CIRCLE = circle
					self.SQUARE = square
					self:RegisterEvent('MODIFIER_STATE_CHANGED')
					self.Background:SetGradientAlpha('VERTICAL', 0, 0, 0, 0.75, cc.r / 5, cc.g / 5, cc.b / 5, 0.75)
					db.UIFrameFadeOut(parent.TalkBox, 0.2, parent.TalkBox:GetAlpha(), 0.10)
					parent.isInspecting = true
					Control:RemoveHint(KEY.SQUARE)
					Control:AddHint(KEY.CIRCLE, DONE)
				end},
				{'OnHide', function(self)
					local parent = self:GetParent()
					self:UnregisterEvent('MODIFIER_STATE_CHANGED')
					db.UIFrameFadeIn(parent.TalkBox, 0.2, parent.TalkBox:GetAlpha(), 1)
					parent.isInspecting = false
					-- Recycle tooltips to core
					for _, tooltip in pairs(self.Choices.Tooltips) do
						tooltip:Hide()
					end
					for _, tooltip in pairs(self.Extras.Tooltips) do
						tooltip:Hide()
					end
					-- Reset columns
					for _, column in pairs(self.Choices.Columns) do
						column.lastItem = nil
						column:SetSize(1, 1)
						column:Hide()
					end
					for _, column in pairs(self.Extras.Columns) do
						column.lastItem = nil
						column:SetSize(1, 1)
						column:Hide()
					end
					-- Wipe tooltips and active selection
					wipe(self.Choices.Tooltips)
					wipe(self.Extras.Tooltips)
					wipe(self.Active)
					-- Reset text
					self.Choices.Text:SetText()
					self.Extras.Text:SetText()
					-- Reset hints to previous state
					if self.CROSS then
						Control:AddHint(KEY.CROSS, self.CROSS)
						self.CROSS = nil
					end
					if self.SQUARE then
						Control:AddHint(KEY.SQUARE, self.SQUARE)
						self.SQUARE = nil
					end
					if self.CIRCLE then
						Control:AddHint(KEY.CIRCLE, self.CIRCLE)
						self.CIRCLE = nil
					end
				end},
			},
		},
		{
			Background = {
				Type = 'Texture',
				Fill = UIParent,
				SetColorTexture = {1, 1, 1},
			},
			Choices = {
				Type = 'Frame',
				Point = {'TOP', 0, 0},
				Size = {1, 200},
				Mixin = 'AdjustToChildren',
				{
					Tooltips = {},
					Columns = {},
					Text = {
						Type = 'FontString',
						Setup = {'ARTWORK', 'Fancy22Font'},
						Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 0, 4},
						Color = {1, 0.82, 0},
						AlignH = 'LEFT',
						Font = {'Fonts\\MORPHEUS.ttf', 18, ''},
					},
				},
			},
			Extras = {
				Type = 'Frame',
				Point = {'TOP', '$parent.Choices', 'BOTTOM', 0, -52},
				Size = {1, 200},
				Mixin = 'AdjustToChildren',
				{
					Tooltips = {},
					Columns = {},
					Text = {
						Type = 'FontString',
						Setup = {'ARTWORK', 'Fancy22Font'},
						Point = {'BOTTOMLEFT', '$parent', 'TOPLEFT', 0, 4},
						Color = {1, 0.82, 0},
						AlignH = 'LEFT',
						Font = {'Fonts\\MORPHEUS.ttf', 18, ''},
					},
				},
			},
			Items = {},
			Active = {},
		},
	},
	TitleButtons = {
		Type = 'Frame',
		Size = {300, 0},
		Point = {'RIGHT', UIParent, 'CENTER', -350, 0},
		Mixin = L.TitlesMixin,
		Threshold = NUMGOSSIPBUTTONS,
		HintText = ACCEPT,
		{
			Active = {},
			Buttons = {},
		},
	},
	TalkBox = {
		Type = 'Frame',
		Size = {570, 155},
		Point = {'BOTTOM', UIParent, 'BOTTOM', 0, 150},
		Strata = 'HIGH',
		Scale = 1.1,
		{
			Elements = {
				Type = 'Frame',
				Backdrop = UI.Media:GetBackdrop('TALKBOX'),
				Point = {'TOP', '$parent', 'BOTTOM',  0, 8},
				Mixin = {L.ElementsMixin, 'AdjustToChildren'},
				Size = {570, 0},
				{
					Active = {},
					Content = {
						Type = 'Frame',
						Setup = {'CPUINPCContentFrame'},
						Mixin = 'AdjustToChildren',
						Size = {570, 403},
						Point = {'TOPLEFT', 32, -32},
						OnLoad = function(self)
							UI:ApplyMixin(self.RewardsFrame, nil, 'AdjustToChildren')
						end,
					},
					Progress = {
						Type = 'Frame',
						Setup = {'CPUINPCProgress'},
						Mixin = 'AdjustToChildren',
						Size = {570, 403},
						Point = {'TOPLEFT', 32, -32},
						Hide = true,
					},
				},
			},
			NameFrame = {
				Type = 'Frame',
				Fill = true,
				Level = 1,
				{
					Name = {
						Type = 'FontString',
						Setup = {'ARTWORK', 'Fancy22Font'},
						Point = {'TOPLEFT', '$parent.$parent.MainFrame.Model.Portrait', 'TOPRIGHT', 2, -19},
						Color = {1, 0.82, 0},
						Width = 370,
						AlignH = 'LEFT',
						Font = {'Fonts\\MORPHEUS.ttf', 22, ''},
					},
					FadeIn = {
						Type = 'AnimationGroup',
						{
							Name = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Name',
								SetStartDelay = 0,
								SetDuration = 0.25,
								SetFromAlpha = 0,
								SetToAlpha = 1,
							},
						},
					},
				},
			},
			TextFrame = {
				Type = 'Frame',
				Fill = true,
				Level = 2,
				{
					Text = {
						Type = 'FontString',
						Setup = {'ARTWORK', 'GameFontHighlightLarge'},
						Mixin = L.TextMixin,
						SetFontObjectsToTry = {SystemFont_Shadow_Large, SystemFont_Shadow_Med2, SystemFont_Shadow_Med1},
						Color = {1, 1, 1},
						AlignH = 'LEFT',
						Points = {
							{'TOPLEFT', '$parent.$parent.NameFrame.Name', 'BOTTOMLEFT', 0, -3},
							{'BOTTOMRIGHT', -42, 12},
						},
					},
					SpeechProgress = {
						Type = 'FontString',
						Setup = {'ARTWORK', 'Fancy22Font'},
						Point = {'BOTTOMRIGHT', '$parent.$parent.MainFrame', 'BOTTOMRIGHT', -22, 22},
						Color = {1, 0.82, 0},
						AlignH = 'RIGHT',
						Font = {'Fonts\\MORPHEUS.ttf', 16, ''},
					},
					FadeIn = {
						Type = 'AnimationGroup',
						{
							Text = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Text',
								SetStartDelay = 0,
								SetDuration = 0.25,
								SetFromAlpha = 0,
								SetToAlpha = 1,
							},
						},
					},
				},
			},
			BackgroundFrame = {
				Type = 'Frame',
				Fill = true,
				Level = 1,
				{
					TextBackground = {
						Type = 'Texture',
						Setup = {'BACKGROUND'},
						Blend = 'BLEND',
						Atlas = 'TalkingHeads-TextBackground',
						Fill = true,
					},
					FadeIn = {
						Type = 'AnimationGroup',
						{
							Text = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'TextBackground',
								SetStartDelay = 0,
								SetDuration = 0.75,
								SetFromAlpha = 0,
								SetToAlpha = 1,
							},
						},
					}
				},
			},
			MainFrame = {
				Type = 'Frame',
				Fill = true,
				Level = 2,
				{
					Indicator = {
						Type = 'Texture',
						Setup = {'OVERLAY', nil, 7},
						Point = {'TOPRIGHT', -24, -24},
					},
					Model = {
						Type = 'PlayerModel',
						Size = {115, 115},
						Point = {'TOPLEFT', 19, -19},
						Level = 1,
						SetLight = {true, false, -250, 0, 0, 0.25, 1, 1, 1, 75, 1, 1, 1},
						HookScript = {'OnAnimFinished', function(self)
							if self.reading then
								self:SetAnimation(520)
							elseif self.delay and self.timestamp then
								local time = GetTime()
								local diff = time - self.timestamp
								-- shave off a second to avoid awkwardly long animation sequences
								if diff < ( self.delay - 1 ) then
									self.timestamp = time
									self.delay = ( self.delay - 1 ) - diff
									self.talking = true
									if self.asking then
										self:SetAnimation(65)
									else
										local yell = self.yelling and ( random(2) == 2 )
										self:SetAnimation(yell and 64 or 60)
									end
								else
									self.timestamp = nil
									self.delay = nil
									self.talking = nil
									self.yelling = nil
									self.asking = nil
									self:SetAnimation(0)
								end 
							elseif self.talking then
								self.talking = nil
								self.yelling = nil
								self:SetAnimation(0)
							end
						end},
						{
							PortraitBG = {
								Type = 'Texture',
								Setup = {'BACKGROUND'},
								Atlas = 'TalkingHeads-PortraitBg',
								Point = {'TOPLEFT', 0, 0},
								Size = {116, 116},
							},
							ModelShadow = {
								Type = 'Texture',
								Setup = {'ARTWORK', nil, -2},
								Atlas = 'Artifacts-BG-Shadow',
								Point = {'TOPLEFT', 0, 0},
								Size = {115, 115},
							},
							Portrait = {
								Type = 'Texture',
								Setup = {'OVERLAY'},
								Size = {143, 143},
								Blend = 'BLEND',
								Atlas = 'TalkingHeads-PortraitFrame',
								Point = {'CENTER', 0, 0},
							},							
							Glow_TopBar = {
								Type = 'Texture',
								Size = {81, 23},
								Alpha = 0,
								Setup = {'OVERLAY', nil, 1},
								Blend = 'ADD',
								Atlas = 'TalkingHeads-Glow-TopBarGlow',
								Point = {'CENTER', '$parent.$parent.Model.Portrait', 'TOP', 0, -11},
							},
							Glow_LeftBar = {
								Type = 'Texture',
								Size = {23, 86},
								Alpha = 0,
								Setup = {'OVERLAY', nil, 1},
								Blend = 'ADD',
								Atlas = 'TalkingHeads-Glow-SideBarGlow',
								Point = {'CENTER', '$parent.$parent.Model.Portrait', 'LEFT', 11, 25},
							},
							Glow_RightBar = {
								Type = 'Texture',
								Size = {23, 86},
								Alpha = 0,
								Setup = {'OVERLAY', nil, 1},
								Blend = 'ADD',
								Atlas = 'TalkingHeads-Glow-SideBarGlow',
								Point = {'CENTER', '$parent.$parent.Model.Portrait', 'RIGHT', -11, 25},
							},
						},
					},
					Sheen = {
						Type = 'Texture',
						Size = {262, 32},
						Alpha = 0,
						Setup = {'OVERLAY'},
						Blend = 'ADD',
						Atlas = 'TalkingHeads-Glow-Sheen',
						Point = {'LEFT', '$parent.$parent.NameFrame.Name', 'LEFT', -48, 0},
					},
					InAnim = {
						Type = 'AnimationGroup',
						SetToFinalAlpha = true,
						{
							----- Left glow animation
							LeftAlphaIn = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_LeftBar',
								SetStartDelay = 0.25,
								SetDuration = 0.25,
								SetFromAlpha = 0,
								SetToAlpha = 0.7,
							},
							LeftTranslate = {
								Type = 'Animation',
								Setup = 'Translation',
								SetChildKey = 'Model.Glow_LeftBar',
								SetStartDelay = 0.25,
								SetDuration = 0.25,
								SetOffset = {0, -10},
							},
							LeftScale = {
								Type = 'Animation',
								Setup = 'Scale',
								SetChildKey = 'Model.Glow_LeftBar',
								SetStartDelay = 0.25,
								SetDuration = 0.25,
								SetFromScale = {1, 0.5},
								SetToScale = {1, 1.6},
								SetOrigin = {'TOP', 0, 0},
							},
							LeftAlphaOut = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_LeftBar',
								SetStartDelay = 0,
								SetDuration = 0.25,
								SetFromAlpha = 0.7,
								SetToAlpha = 0,
								SetOrder = 1,
							},
							----- Right glow animation
							RightAlphaIn = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_RightBar',
								SetStartDelay = 0.25,
								SetDuration = 0.25,
								SetFromAlpha = 0,
								SetToAlpha = 0.7,
							},
							RightTranslate = {
								Type = 'Animation',
								Setup = 'Translation',
								SetChildKey = 'Model.Glow_RightBar',
								SetStartDelay = 0.25,
								SetDuration = 0.8,
								SetOffset = {0, -10},
							},
							RightScale = {
								Type = 'Animation',
								Setup = 'Scale',
								SetChildKey = 'Model.Glow_RightBar',
								SetStartDelay = 0.25,
								SetDuration = 0.7,
								SetFromScale = {1, 0.5},
								SetToScale = {1, 1.6},
								SetOrigin = {'TOP', 0, 0},
							},
							RightAlphaOut = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_RightBar',
								SetStartDelay = 0,
								SetDuration = 0.25,
								SetFromAlpha = 0.7,
								SetToAlpha = 0,
								SetOrder = 1,
							},							
							----- Top glow animation
							TopAlphaIn = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_TopBar',
								SetStartDelay = 0.15,
								SetDuration = 0.25,
								SetFromAlpha = 0,
								SetToAlpha = 0.7,
							},
							TopScale = {
								Type = 'Animation',
								Setup = 'Scale',
								SetChildKey = 'Model.Glow_TopBar',
								SetStartDelay = 0.15,
								SetDuration = 0.15,
								SetFromScale = {0.25, 1},
								SetToScale = {1.5, 1},
							},
							TopAlphaOut = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.Glow_TopBar',
								SetStartDelay = 0,
								SetDuration = 0.5,
								SetFromAlpha = 0.7,
								SetToAlpha = 0,
								SetOrder = 1,
							},
						},
					},
					SheenAnim = {
						Type = 'AnimationGroup',
						SetToFinalAlpha = true,
						{
							----- Sheen animation	
							SheenAlphaIn = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Sheen',
								SetStartDelay = 0,
								SetDuration = 0.5,
								SetFromAlpha = 0,
								SetToAlpha = 0.7,
							},
							SheenScale = {
								Type = 'Animation',
								Setup = 'Scale',
								SetChildKey = 'Sheen',
								SetStartDelay = 0.5,
								SetDuration = 0.25,
								SetFromScale = {0.25, 1},
								SetToScale = {1, 1},
								SetOrigin = {'LEFT', 0, 0},
							},
							SheenAlphaOut = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Sheen',
								SetStartDelay = 0,
								SetDuration = 0.5,
								SetFromAlpha = 0.7,
								SetToAlpha = 0,
								SetOrder = 1,
							},
							PortraitIn = {
								Type = 'Animation',
								Setup = 'Alpha',
								SetChildKey = 'Model.PortraitBG',
								SetDuration = 0.75,
								SetFromAlpha = 0,
								SetToAlpha = 1,
							},
						},
					},
				},
			},
			StatusBar = {
				Type = 'StatusBar',
				Setup = {'CPUINPCStatusBar'},
			},
		},
	},
})

frame:SetSize(570, 155)
frame:SetFrameStrata('HIGH')
frame:Hide()
L.frame = frame