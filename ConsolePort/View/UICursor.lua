local Cursor, Node, Input, _, db = CPAPI.AddEventHandler(ConsolePortCursor), ConsolePortNode, ConsolePortInputHandler, ...;
local current, old -- references to nodes

function Cursor:OnDataLoaded()
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	-- do something when it's loaded
end

function Cursor:OnShow()
	self.Button:SetTexture(db('Settings/UICursor/LeftClick'))
end

function Cursor:Release()
	Input:Release(self)
end


-- trigger for activating/deactivating cursor?
--hooksecurefunc('CanAutoSetGamePadCursorControl', function(...) print('CanAutoSetGamePadCursorControl', ...) end)
--hooksecurefunc('SetGamePadCursorControl', function(...) print('SetGamePadCursorControl', ...) end)


--[[
IsGamePadCursorControlEnabled
CanGamePadControlCursor
IsGamePadFreelookEnabled
SetGamePadFreeLook
CanAutoSetGamePadCursorControl


IsBindingForGamePad
SetGamePadCursorControl

]]


---------------------------------------------------------------
-- Cursor textures and animations
---------------------------------------------------------------
function Cursor:SetTexture(texture)
	local object = current and current.object
	local newType = (object == 'EditBox' and self.IndicatorS) or (object == 'Slider' and self.Modifier) or texture or self.Indicator
	if newType ~= self.type then
		self.Button:SetTexture(newType)
	end
	self.type = newType
end

function Cursor:SetPosition(node)
	local oldAnchor = self.anchor
	self:SetTexture()
	self.anchor = node.customCursorAnchor or {"TOPLEFT", node, "CENTER", 0, 0}
	self:Show()
	self:Move(oldAnchor)
end

function Cursor:SetPointer(node)
	self.Pointer:ClearAllPoints()
	self.Pointer:SetParent(node)
	self.Pointer:SetPoint(unpack(self.anchor))
	return self.Pointer:GetCenter()
end

function Cursor:Move(oldAnchor)
	if current then
		self:ClearHighlight()
		local newX, newY = self:SetPointer(current.node)
		if self.MoveAndScale:IsPlaying() then
			self.MoveAndScale:Stop()
			self.MoveAndScale:OnFinished(oldAnchor)
		end
		local oldX, oldY = self:GetCenter()
		if ( not current.node.noAnimation ) and oldX and oldY and newX and newY and self:IsVisible() then
			local oldScale, newScale = self:GetEffectiveScale(), self.Pointer:GetEffectiveScale()
			local sDiff, sMult = oldScale / newScale, newScale / oldScale
			self.Translate:SetOffset((newX - oldX * sDiff) * sMult, (newY - oldY * sDiff) * sMult)
			self.Enlarge:SetStartDelay(0.05)
			self.MoveAndScale:ConfigureScale()
			self.MoveAndScale:Play()
		else
			self.Enlarge:SetStartDelay(0)
			self.MoveAndScale:OnFinished()
		end
	end
end

-- Animation scripts
---------------------------------------------------------------
function Cursor.MoveAndScale:ConfigureScale()
	if old == current and not self.Flash then
		self.Shrink:SetDuration(0)
		self.Enlarge:SetDuration(0)	
	elseif current then
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

function Cursor.Highlight.Scale:OnPlay()
	self.Enlarge:SetScale(Cursor.MoveAndScale.Enlarge:GetScale())
	self.Shrink:SetScale(Cursor.MoveAndScale.Shrink:GetScale())

	self.Enlarge:SetDuration(Cursor.MoveAndScale.Enlarge:GetDuration())
	self.Shrink:SetDuration(Cursor.MoveAndScale.Shrink:GetDuration())

	self.Enlarge:SetStartDelay(Cursor.MoveAndScale.Enlarge:GetStartDelay())
	self.Shrink:SetStartDelay(Cursor.MoveAndScale.Shrink:GetStartDelay())
end

function Cursor.MoveAndScale.Translate:OnFinished()
	Cursor:SetHighlight(current and current.node)
end

function Cursor.MoveAndScale:OnPlay()
	Cursor.Highlight:SetParent(current and current.node or Cursor)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor.MoveAndScale:OnFinished(oldAnchor)
	Cursor:ClearAllPoints()
	Cursor:SetPoint(unpack(oldAnchor or Cursor.anchor))
end
---------------------------------------------------------------

function Cursor:ClearHighlight()
	self.Highlight:ClearAllPoints()
	self.Highlight:SetParent(self)
	self.Highlight:SetTexture(nil)
end

function Cursor:SetHighlight(node)
	local mime = self.Highlight
	local highlight = node and node.GetHighlightTexture and node:GetHighlightTexture()
	if highlight and node:IsEnabled() then
		if highlight:GetAtlas() then
			mime:SetAtlas(highlight:GetAtlas())
		else
			local texture = highlight.GetTexture and highlight:GetTexture()
			if (type(texture) == 'string') and texture:find('^[Cc]olor-') then
				local r, g, b, a = Hex2RGB(texture:sub(7), true)
				mime:SetColorTexture(r, g, b, a)
			else
				mime:SetTexture(texture)
			end
			mime:SetBlendMode(highlight:GetBlendMode())
			mime:SetVertexColor(highlight:GetVertexColor())
		end
		mime:SetSize(highlight:GetSize())
		mime:SetTexCoord(highlight:GetTexCoord())
		mime:SetAlpha(highlight:GetAlpha())
		mime:ClearAllPoints()
		mime:SetPoint(highlight:GetPoint())
		mime:Show()
		mime.Scale:Stop()
		mime.Scale:Play()
	else
		mime:ClearAllPoints()
		mime:Hide()
	end
end