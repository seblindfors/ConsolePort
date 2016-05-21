---------------------------------------------------------------
-- Hooks.lua: Default interface hooking and script alteration
---------------------------------------------------------------
-- Customizes the behaviour of Blizzard frames to accommodate
-- the gimmicky nature of controller input. Also contains a
-- terrible tooltip hook to provide click instructions.

local _, db = ...

function ConsolePort:LoadHookScripts()
	-- Click instruction hooks. Pending removal for cleaner solution
	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		if 	not InCombatLockdown() then
			local CLICK_STRING
			local owner = self:GetOwner()
			local item = self:GetItem()
			local ownerParent = owner and owner:GetParent()
			local parentName = ownerParent and ownerParent:GetName()
			if		parentName and parentName:match("MerchantItem") then
				--	string.find(owner:GetParent():GetName(), "MerchantItem") ~= nil then
					CLICK_STRING = db.CLICK.BUY
					if GetMerchantItemMaxStack(owner:GetID()) > 1 then 
						self:AddLine(db.CLICK.STACK_BUY, 1,1,1)
					end
			elseif	ownerParent == LootFrame then
					self:AddLine(db.CLICK_LOOT, 1,1,1)
			elseif 	MerchantFrame:IsVisible() and not IsEquippedItem(item) then 
				CLICK_STRING = db.CLICK.SELL
			elseif 	IsEquippableItem(item) and not IsEquippedItem(item) then 
				CLICK_STRING = db.CLICK.EQUIP
			elseif 	GetItemSpell(item) then 
				CLICK_STRING = db.CLICK.USE
			end
			if 	GetItemCount(item, false) ~= 0 or
				MerchantFrame:IsVisible() then
				if 	EquipmentFlyoutFrame:IsVisible() then
					self:AddLine(db.CLICK_CANCEL, 1,1,1)
				end
				self:AddLine(CLICK_STRING, 1,1,1)

				local hasStack = select(8, GetItemInfo(item))
				hasStack = hasStack and hasStack > 1
				
				if CLICK_STRING == db.CLICK.USE then
					self:AddLine(db.CLICK.ADD_TO_EXTRA, 1,1,1)
				elseif hasStack then
					self:AddLine(db.CLICK.STACK_SPLIT)
				end
				if not ownerParent == LootFrame then
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		if not InCombatLockdown() then
			if 	self:GetOwner():GetParent() == SpellBookSpellIconsFrame and not
				self:GetOwner().isPassive then
				if not self:GetOwner().UnlearnedFrame:IsVisible() then
					self:AddLine(db.CLICK.USE_NOCOMBAT, 1,1,1)
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	-- Disable keyboard input when splitting stacks (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false)
	-- Remove the need to type "DELETE" when removing rare or better quality items
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

	-- Give default UI action buttons their correct action IDs.
	-- This is to make it easier to distinguish action buttons,
	-- since action bar addons use this attribute to perform actions.
	-- Blizzard's own system does not use the attribute by default,
	-- instead resorting to table keys to determine correct action.
	-- Assigning the attribute manually unifies default UI with addons.
	local bars = {
		["ActionButton"] = 1,
		["MultiBarRightButton"] = 3,
		["MultiBarLeftButton"] = 4,
		["MultiBarBottomRightButton"] = 5,
		["MultiBarBottomLeftButton"] = 6,
	}

	for bar, page in pairs(bars) do
		for btn=1, 12 do
			local button = _G[bar..btn]
			button:SetAttribute("action", (12 * (page - 1)) + btn)
		end
	end

	ExtraActionButton1:SetAttribute("action", 169)

	for i=1, 6 do
		_G["OverrideActionBarButton"..i]:SetAttribute("action", 132 + i)
	end

	self.LoadHookScripts = nil
end