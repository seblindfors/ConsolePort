local Menu = select(2, ...).Menu
local abs = math.abs
local FadeIn, FadeOut

do
	local UI = ConsolePortUI
	local db = ConsolePort:GetData()

	local gBase, gMulti, gAlpha = .3, 1.1, .5
	local nR, nG, nB = db.Atlas.GetNormalizedCC()
	local cc = UI.Media.CC

	local classGradient = {
		'HORIZONTAL',
		(cc.r + gBase) * gMulti, (cc.g + gBase) * gMulti, (cc.b + gBase) * gMulti, gAlpha,
		1 - (cc.r - gBase) * gMulti, 1 - (cc.g - gBase) * gMulti, 1 - (cc.b - gBase) * gMulti, gAlpha,
	}

	UI:BuildFrame(Menu, {
		BG = {
			Type 	= 'Texture';
			Setup  	= {'BACKGROUND'};
			Texture = [[Interface\AddOns\ConsolePort\Textures\Window\Gradient]];
			SetGradientAlpha = classGradient;
			Points 	= {
				{'TOPLEFT', 0, 0};
				{'BOTTOMRIGHT', 0, 0};
			};
		};
		Art = {
			Type 	= 'Texture';
			Setup 	= {'BACKGROUND', nil, 7};
			Fill 	= true;
			Texture = [[Interface\GLUES\LOADINGSCREENS\LoadingScreen_8xp_ForlornVictory_wide]];
			Vertex 	= {nR, nG, nB, 1};
			SetDesaturated = true,
		};
		TopLine = {
			Type 	= 'Texture';
			Setup 	= {'ARTWORK'};
			Size 	= {0, 8};
			Texture = UI.Media:GetTexture('Menu_TopLine');
			Vertex 	= {nR, nG, nB, 1};
			Points 	= {
				{'BOTTOMLEFT', 0, -4};
				{'BOTTOMRIGHT', 0, -4};
			};
		};
		Emblem = {
			Type 	= 'Texture';
			Setup 	= {'OVERLAY'};
			Texture = UI.Media:GetTexture('Menu_TopEmblem');
			Size 	= {1024, 16};
			Point 	= {'BOTTOM', 0, -16};
		};
		Flair = {
			Type 	= 'PlayerModel';
			Size 	= {230, 52};
			Hide 	= true;
			Alpha 	= .25;
			SetDisplayInfo = 54419;
			SetCamDistanceScale = 3;
			SetPosition = {0, 0, -1.5};
		};
		GlowLeft = {
			Type 	= 'Frame';
			Setup 	= {'CPUILineSheenTemplate'};
			Point 	= {'TOP', 'parent', 'BOTTOM', 0, 12};
			SetDirection = {'LEFT', 1.5};
		};
		GlowRight = {
			Type 	= 'Frame';
			Setup 	= {'CPUILineSheenTemplate'};
			Point 	= {'TOP', 'parent', 'BOTTOM', 0, 12};
			SetDirection = {'RIGHT', 1.5};
		};
	})

	FadeIn, FadeOut = db.UIFrameFadeIn, db.UIFrameFadeOut
end

-- :)
local LS_HEIGHT = 1080
local artDisplays = {
	[[Interface\GLUES\LOADINGSCREENS\LoadingScreen_8xp_ForlornVictory_wide]],
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenKalimdor4wide]],
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenEasternKingdoms4wide]],
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenDeathwingRaid]],
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenBlizzcon2013Wide]],
}

function Menu:OnArtUpdate(elapsed)
	self.updateThrottle = self.updateThrottle + elapsed
	if self.updateThrottle > .025 then
		local half, pan, base = self.halfY, self.pxPan, self.pxBase
		local isAtTop = pan - half < 0
		local isAtBottom = pan + half > LS_HEIGHT

		if isAtTop or isAtBottom then
			pan = isAtTop and half or (LS_HEIGHT - half)
			self.artIndex = self.artIndex >= #artDisplays and 1 or self.artIndex + 1
			self.Art:SetTexture(artDisplays[self.artIndex])
			self.panDelta = self.panDelta * -1
		else
			pan = pan + self.panDelta
		end

		local alpha = (((abs(abs(base - pan) - base) / base) ^ 1.25) - .6)
		if alpha >= 0 then
			self.Art:SetAlpha(alpha)
			self.Art:SetTexCoord(0, 1, (pan - half) / LS_HEIGHT, (pan + half) / LS_HEIGHT)
		end
		self.pxPan = pan
		self.updateThrottle = 0
	end
end

function Menu:OnAspectRatioChanged()
	local x, y = self:GetSize()
	local scale = (UIParent:GetHeight() / LS_HEIGHT)
	self.halfY =  (y / scale / 2)
	self.pxBase = (LS_HEIGHT / 2)
	self.pxPan = LS_HEIGHT - (self.halfY)
	self.panDelta = -0.5
	self.artIndex = 1
	self.updateThrottle = 0
	self.Art:SetAlpha(0)
end


function Menu:OnHeaderSet(name)
	self.Flair:ClearAllPoints()
	local header = _G[name]
	if header then
		FadeOut(self.Flair, 0.5, 1, .25)
		header.OnFocusAnim:Play()
		self.Flair:SetPoint('BOTTOMLEFT', header, 'BOTTOMLEFT')
		self.Flair:SetPoint('BOTTOMRIGHT', header, 'BOTTOMRIGHT')
		self.Flair:SetHeight(64)
		self.Flair:Show()
	end
end

function Menu:OnShowPlay()
	FadeIn(self.Emblem, 0.5, 0, 1)
end

Menu:HookScript('OnShow', Menu.OnShowPlay)
Menu:HookScript('OnSizeChanged', Menu.OnAspectRatioChanged)
Menu:HookScript('OnUpdate', Menu.OnArtUpdate)
Menu:OnAspectRatioChanged()