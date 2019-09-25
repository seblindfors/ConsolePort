---------------------------------------------------------------
-- Hooks.lua: Default interface hooking and script alteration
---------------------------------------------------------------
-- Customizes the behaviour of Blizzard frames to accommodate
-- the gimmicky nature of controller input. Also contains a
-- terrible tooltip hook to provide click instructions.

local _, db = ...

do 
	-- Give default UI action buttons their correct action IDs.
	-- This is to make it easier to distinguish action buttons,
	-- since action bar addons use this attribute to perform actions.
	-- Blizzard's own system does not use the attribute by default,
	-- instead resorting to table keys/:GetID() to determine correct action.
	-- Assigning the attribute manually unifies default UI with addons.
	local bars = {
		['ActionButton'] = 1,
		['MultiBarRightButton'] = 3,
		['MultiBarLeftButton'] = 4,
		['MultiBarBottomRightButton'] = 5,
		['MultiBarBottomLeftButton'] = 6,
	}

	for bar, page in pairs(bars) do
		for btn=1, 12 do
			local button = _G[bar..btn]
			button:SetAttribute('action', (12 * (page - 1)) + btn)
		end
	end

	if ExtraActionButton1 then
		ExtraActionButton1:SetAttribute('action', 169)
	end

	for i=1, 6 do
		local button = _G['OverrideActionBarButton'..i]
		if button then
			button:SetAttribute('action', 132 + i)
		end
	end
end


function ConsolePort:LoadHookScripts()
	-- Click instruction hooks. Pending removal for cleaner solution
	local core = self
	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		if 	not InCombatLockdown() then
			local clickString
			local owner = self:GetOwner()
			local item = self:GetItem()
			if core:IsCurrentNode(owner) and not core:IsCursorObstructed() then
				local ownerParent = owner and owner:GetParent()
				local parentName = ownerParent and ownerParent:GetName()
				if		parentName and parentName:match('MerchantItem') then
						clickString = db.CLICK.BUY
						if GetMerchantItemMaxStack(owner:GetID()) > 1 then 
							self:AddLine(db.CLICK.STACK_BUY, 1,1,1)
						end
				-- This is a loot item?
				elseif	ownerParent == LootFrame then
						self:AddLine(db.CLICK_LOOT, 1,1,1)
				-- This item is in a bag?
				elseif owner and owner.JunkIcon then
					-- This is an item in the bag while talking to a merchant?
					if 	MerchantFrame:IsVisible() and not IsEquippedItem(item) then 
						clickString = db.CLICK.SELL
					-- This item is equippable?
					elseif 	IsEquippableItem(item) then -- and not IsEquippedItem(item) then
						self:AddLine(db.CLICK.COMPARE, 1,1,1)
						clickString = db.CLICK.EQUIP
					-- This item is usable?
					elseif 	GetItemSpell(item) then 
						clickString = db.CLICK.USE
					end
					self:AddLine(db.CLICK.PICKUP_ITEM, 1,1,1)
				end
				if 	GetItemCount(item, false) ~= 0 or
					MerchantFrame:IsVisible() then
					if 	EquipmentFlyoutFrame and EquipmentFlyoutFrame:IsVisible() then
						self:AddLine(db.CLICK_CANCEL, 1,1,1)
					end
					self:AddLine(clickString, 1,1,1)

					local hasStack = select(8, GetItemInfo(item))
					hasStack = hasStack and hasStack > 1
					
					if clickString == db.CLICK.USE then
						self:AddLine(db.CLICK.ADD_TO_EXTRA, 1,1,1)
					elseif hasStack then
						self:AddLine(db.CLICK.STACK_SPLIT)
					end
					if not ownerParent == LootFrame then
						self:AddLine(db.CLICK.PICKUP, 1,1,1)
					end
					self:Show()
				end
	--		else
			--	ConsolePort:SetCurrentNode(owner)
			end
		end
	end)
	GameTooltip:HookScript('OnTooltipSetSpell', function(self)
		if not InCombatLockdown() then
			local owner = self:GetOwner()
			if core:IsCurrentNode(owner) and not core:IsCursorObstructed() then
				if 	owner and owner:GetParent() == SpellBookSpellIconsFrame and not owner.isPassive then
					if owner.UnlearnedFrame and not owner.UnlearnedFrame:IsVisible() then
						self:AddLine(db.CLICK.USE_NOCOMBAT, 1,1,1)
						self:AddLine(db.CLICK.PICKUP, 1,1,1)
					end
					self:Show()
				end
			end
		end
	end)

	-- Re-adjust tooltips anchored to mouse cursor when owned by the interface cursor.
	if not db('UIdisableTooltipFix') then
		local function TooltipAdjustOnShow(self)
			local node = core:GetCurrentNode()
			if node and self:IsOwned(node) then
				local anchor = self:GetAnchorType()
				if anchor and anchor:match('^ANCHOR_CURSOR') then
					anchor = anchor:gsub('ANCHOR_CURSOR', 'ANCHOR')
					self:SetAnchorType(anchor, 0, 0)
				end
			end
		end

		GameTooltip:HookScript('OnShow', TooltipAdjustOnShow)
		WorldMapTooltip:HookScript('OnShow', TooltipAdjustOnShow)
	end
	
	-- Disable keyboard input when splitting stacks (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false)

	-- Remove the need to type 'DELETE' when removing rare or better quality items
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

	-- This hook might cause issues, but refines the interaction
	-- with dropdowns. This causes separators and arrow buttons to
	-- be ignored. 
	if db('UIdropDownFix') then
		local dropDowns = {
			DropDownList1,
			DropDownList2,
		}

		for _, DD in pairs(dropDowns) do
			DD:HookScript('OnShow', function(self)
				for _, child in ipairs({self:GetChildren()}) do
					child.ignoreNode = (child.IsVisible and not child:IsVisible()) or (child.IsEnabled and not child:IsEnabled())
					child.ignoreChildren = child.hasArrow
				end
			end)
		end
	end

	-- Allow cinematics to be cancelled by pressing CROSS/A button.
	for frame, closeButton in pairs({
		-----------------------------
		[CinematicFrame] = CinematicFrameCloseDialogConfirmButton;
		[MovieFrame] = MovieFrame.CloseDialog and MovieFrame.CloseDialog.ConfirmButton;
		-----------------------------
	}) do frame:HookScript('OnKeyUp', function(self, key)
			if core:GetUIControlKeyFromInput(key) == db.KEY.CROSS then
				closeButton:Click()
			end
		end)
	end

	--
	if db('enableCenterPanels') then
		for frame, anchorData in pairs({
		--	['WorldMapFrame'] = {xoffset = 0, yoffset = -100, pushable = 1, area = 'center'};
		--	['PlayerTalentFrame'] = {xoffset = 0, yoffset = -100, pushable = 1, area = 'center'};
		--	['WardrobeFrame'] = {area = 'center'};
		}) do
			if UIPanelWindows[frame] then
				for k, v in pairs(anchorData) do
					UIPanelWindows[frame][k] = v
				end
			end
		end
	end

	-- Need to handle SaveBindings, so that calibration data isn't stored permanently
	-- against user's will. The keybinding UI should circumvent this because it exits to the
	-- game menu frame and cancels the popup, but calls from interface options will be intercepted.
	local RealSaveBindings = SaveBindings
	function SaveBindings(set)
		if db('allowSaveBindings') then
			RealSaveBindings(set)
			return
		end
		local info = debugstack(2) -- get debug info
		local addon = info and info:match('\\%a+\\'):gsub('\\', '')
		local file = info and info:match('%a+%.lua:%d+')
		local blockSave
		StaticPopupDialogs['CONSOLEPORT_WARNINGSAVEBINDINGS'] = {
			text = db.TUTORIAL.SLASH.WARNINGSAVEBINDINGS:format(file or '<unidentified file>', addon or '<unidentified addon>'),
			button1 = ACCEPT,
			button2 = CANCEL,
			button3 = db.TUTORIAL.SLASH.ALLOW,
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAlt = function() 
				self.ClearPopup()
				db('allowSaveBindings', true, 'Settings')
			end,
			OnCancel = function() 
				self.ClearPopup()
				blockSave = true
			end,
			OnHide = function()
				if not blockSave then
					RealSaveBindings(set)
				end
			end,
		}
		self:ShowPopup('CONSOLEPORT_WARNINGSAVEBINDINGS')
	end

	-- Hack to fix the varying tab levels causing cursor to skip nodes
	if CPAPI:IsClassicVersion() then
		local level
		for i=1, 5 do
			local tab = _G['FriendsFrameTab' .. i]
			if tab then
				if not level then
					level = tab:GetFrameLevel()
				else
					tab:SetFrameLevel(level)
				end
			end
		end
	end


	self.LoadHookScripts = nil
end