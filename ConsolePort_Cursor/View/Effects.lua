---------------------------------------------------------------
-- Interface cursor effects
---------------------------------------------------------------

local env, db = CPAPI.GetEnv(...)
local Cursor, Fade, Node = db.Cursor, db.Alpha.Fader, env.Node;

---------------------------------------------------------------
-- Anchoring and movement
---------------------------------------------------------------
function Cursor:SetAnchorForNode(node)
	self:SetCustomAnchor(node.customCursorAnchor, false);
end

function Cursor:SetCustomAnchor(anchor, force)
	self.customAnchor = anchor;
	self.forceAnchor  = force;
	if anchor then
		self:ClearAllPoints();
		self:SetPoint(unpack(anchor));
	end
end

function Cursor:GetCustomAnchor()
	return self.customAnchor, self.forceAnchor;
end

function Cursor:RefreshAnchor()
	if not self:GetCustomAnchor() then
		local node = self:GetCurrentNode()
		self:ClearAllPoints()
		self:SetPoint('CENTER', node, 'CENTER', Node.GetCenterPos(node))
	end
end

function Cursor:SetPosition(node)
	self:SetTexture()
	self:SetAnchorForNode(node)
	self:Show()
	self:Move()
end

function Cursor:Move()
	local node = self:GetCurrentNode()
	if node then
		self:ClearHighlight()
		local newX, newY = Node.GetCenter(node)
		local oldX, oldY = self:GetCenter()
		if oldX and oldY and newX and newY and self:IsVisible() then
			self.Enlarge:SetStartDelay(0.05)
			self.ScaleInOut:ConfigureScale()
			self:Chime()
		else
			self.Enlarge:SetStartDelay(0)
		end
		self:SetHighlight(node)
	end
end

---------------------------------------------------------------
-- Cursor textures and animations
---------------------------------------------------------------
do	local f, path = format, 'Gamepad/Active/Icons/%s-64';
	-- lambdas to handle texture swapping without caching icons
	local function left  () return db('UIpointerDefaultIcon') and db(f(path, db('UICursorLeftClick'))) end
	local function mod   () return db(f(path, db('Gamepad/Index/Modifier/Key/' .. db('UImodifierCommands')) or '')) end
	local function opt   () return db(f(path, db('UICursorSpecial'))) end
	local function right () return db(f(path, db('UICursorRightClick'))) end

	Cursor.Textures = CPAPI.Proxy({
		Right    = right;
		Modifier = mod;
		-- object cases
		EditBox  = opt;
		Slider   = nop;
		Frame    = nop;
	}, function() return left end)
	-- remove texture evaluator so cursor refreshes on next movement
	local function ResetTexture(self)
		self.textureEvaluator = nil;
		self.useAtlasIcons = db('useAtlasIcons')
	end
	db:RegisterCallbacks(ResetTexture, Cursor,
		'Gamepad/Active',
		'Settings/UIpointerDefaultIcon',
		'Settings/useAtlasIcons'
	);
	ResetTexture(Cursor)
end

function Cursor:SetTexture(texture)
	local object = texture or self:GetCurrentObjectType()
	local evaluator = self.Textures[object]
	if ( evaluator ~= self.textureEvaluator ) then
		local node = self:GetCurrentNode()
		if self.useAtlasIcons then
			local atlas = evaluator(node)
			if atlas then
				self.Display.Button:SetAtlas(atlas)
			else
				self.Display.Button:SetTexture(nil)
			end
		else
			self.Display.Button:SetTexture(evaluator(node))
		end
	end
	self.textureEvaluator = evaluator;
end

function Cursor:ToggleScrollIndicator(enabled)
	self.Display.Scroller:SetPoint('LEFT', self.Display.Button, 'RIGHT', self.Display.Button:GetTexture() and 2 or -16, 0)
	if self.isScrollingActive == enabled then return end;
	local evaluator = self.Textures.Modifier;
	local texture   = evaluator and evaluator() or nil;
	local newAlpha  = ( enabled and texture and 1 ) or 0;
	Fade.In(self.Display.ScrollUp,   0.2, self.Display.ScrollUp:GetAlpha(),   newAlpha)
	Fade.In(self.Display.ScrollDown, 0.2, self.Display.ScrollDown:GetAlpha(), newAlpha)
	Fade.In(self.Display.Scroller,   0.2, self.Display.Scroller:GetAlpha(),   newAlpha)
	if enabled then
		if self.useAtlasIcons then
			if texture then
				self.Display.Scroller:SetAtlas(texture)
			else
				self.Display.Scroller:SetTexture(nil)
			end
		else
			self.Display.Scroller:SetTexture(texture)
		end
	end
	self.isScrollingActive = enabled;
end

function Cursor:Chime()
	if not self.enableSound then return end;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor:UpdatePointer()
	self.Display:SetSize(db('UIpointerSize'))
	self.Display:SetOffset(db('UIpointerOffset'))
	self.Display:SetRotationEnabled(db('UIpointerAnimation'))
	self.Display.animationSpeed = db('UItravelTime');
	self.enableSound = db('UIpointerSound')
end

db:RegisterCallbacks(Cursor.UpdatePointer, Cursor,
	'Settings/UItravelTime',
	'Settings/UIpointerSize',
	'Settings/UIpointerOffset',
	'Settings/UIpointerAnimation',
	'Settings/UIpointerSound'
);

---------------------------------------------------------------
-- Highlight mime
---------------------------------------------------------------
function Cursor:ClearHighlight()
	self.Mime:Clear()
end

function Cursor:SetHighlight(node)
	if node and (not node.IsEnabled or node:IsEnabled())
    and not node:GetAttribute(env.Attributes.IgnoreMime) then
		self.Mime:SetNode(node)
	else
		self:ClearHighlight()
	end
end

function Cursor.Mime:SetFontString(region)
	if region:IsShown() and region:GetFont() then
		local obj = self.Fonts:Acquire()
		obj:SetFont(obj.GetFont(region))
		obj:SetText(obj.GetText(region))
		obj:SetTextColor(obj.GetTextColor(region))
		obj:SetJustifyH(obj.GetJustifyH(region))
		obj:SetJustifyV(obj.GetJustifyV(region))
		obj:SetSize(obj.GetSize(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function Cursor.Mime:SetTexture(region)
	if region:IsShown() then
		local obj = self.Textures:Acquire()
		if obj.GetAtlas(region) then
			obj:SetAtlas(obj.GetAtlas(region))
		else
			local texture = obj.GetTexture(region)
			-- DEPRECATED: returns File Data ID <num> in 9.0
			if (type(texture) == 'string') and texture:find('^[Cc]olor-') then
				obj:SetColorTexture(CPAPI.Hex2RGB(texture:sub(7), true))
			else
				obj:SetTexture(texture)
			end
		end
		obj:SetBlendMode(obj.GetBlendMode(region))
		obj:SetTexCoord(obj.GetTexCoord(region))
		obj:SetVertexColor(obj.GetVertexColor(region))
		obj:SetSize(obj.GetSize(region))
		obj:SetRotation(obj.GetRotation(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function Cursor.Mime:SetNode(node)
	self:MimeRegions(node:GetRegions())
	self:ClearAllPoints()
	self:SetSize(node:GetSize())
	self:SetScale(node:GetEffectiveScale() / Cursor:GetEffectiveScale())
	self:Show()
	for i=1, node:GetNumPoints() do
		self:SetPoint(node:GetPoint(i))
	end
	self.Scale:Stop()
	self.Scale:Play()
end

function Cursor.Mime:Clear()
	self.Fonts:ReleaseAll()
	self.Textures:ReleaseAll()
	self:Hide()
end

function Cursor.Mime:MimeRegions(region, ...)
	if region then
		if (region:GetDrawLayer() == 'HIGHLIGHT') then
			if (region:GetObjectType() == 'Texture') then
				self:SetTexture(region)
			elseif (region:GetObjectType() == 'FontString') then
				self:SetFontString(region)
			end
		end
		self:MimeRegions(...)
	end
end

---------------------------------------------------------------
-- Animation scripts
---------------------------------------------------------------
function Cursor:SetFlashNextNode()
	self.ScaleInOut.Flash = true;
end

function Cursor.ScaleInOut:ConfigureScale()
	local cur, old = Cursor:GetCurrent(), Cursor:GetOld()
	if (cur == old) and not self.Flash then
		self.Shrink:SetDuration(0)
		self.Enlarge:SetDuration(0)
	elseif cur then
		local scaleAmount, shrinkDuration = 1.15, 0.2
		if self.Flash then
			scaleAmount = 1.75
			shrinkDuration = 0.5
		end
		self.Flash = nil
		self.Enlarge:SetScale(scaleAmount, scaleAmount)
		self.Shrink:SetScale(1/scaleAmount, 1/scaleAmount)
		self.Shrink:SetDuration(shrinkDuration)
		self.Enlarge:SetDuration(.1)
	end
end

function Cursor.Mime.Scale:OnPlay()
	self.Enlarge:SetScale(Cursor.ScaleInOut.Enlarge:GetScale())
	self.Shrink:SetScale(Cursor.ScaleInOut.Shrink:GetScale())

	self.Enlarge:SetDuration(Cursor.ScaleInOut.Enlarge:GetDuration())
	self.Shrink:SetDuration(Cursor.ScaleInOut.Shrink:GetDuration())

	self.Enlarge:SetStartDelay(Cursor.ScaleInOut.Enlarge:GetStartDelay())
	self.Shrink:SetStartDelay(Cursor.ScaleInOut.Shrink:GetStartDelay())
end

function Cursor.ScaleInOut:OnPlay()
	Cursor.Mime:SetParent(Cursor:GetCurrentNode() or Cursor)
end

do  -- Set up animation scripts
	local animationGroups = {Cursor.ScaleInOut, Cursor.Mime.Scale}

	local function setupScripts(w)
		for k, v in pairs(w) do
			if w:HasScript(k) then w:SetScript(k, v) end
		end
	end

	for _, group in pairs(animationGroups) do
		setupScripts(group)
		for _, animation in pairs({group:GetAnimations()}) do
			setupScripts(animation)
		end
	end

	-- Convenience references to animations
	Cursor.Enlarge = Cursor.ScaleInOut.Enlarge;
	Cursor.Shrink  = Cursor.ScaleInOut.Shrink;
end

---------------------------------------------------------------
-- Initialize the pointer
---------------------------------------------------------------
Cursor:UpdatePointer()