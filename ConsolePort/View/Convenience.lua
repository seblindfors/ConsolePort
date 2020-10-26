---------------------------------------------------------------
-- Convenience UI modifications and hacks
---------------------------------------------------------------
local _, db = ...;

-- Popups:
-- Since popups normally appear in response to an event or
-- crucial action, the UI cursor will automatically move to
-- a popup when it is shown. StaticPopup1 has first priority.
do  local popups, visible, oldNode = {}, {};
	for i=1, STATICPOPUP_NUMDIALOGS do
		popups[_G['StaticPopup'..i]] = _G['StaticPopup'..(i-1)] or false;
	end

	for popup, previous in pairs(popups) do
		popup:HookScript('OnShow', function(self)
			visible[self] = true;
			if not InCombatLockdown() then
				local prio = popups[previous];
				if not prio or ( not prio:IsVisible() ) then
					local current = db('Cursor'):GetCurrentNode()
					-- assert not caching a return-to node on a popup
					if current and not popups[current:GetParent()] then
						oldNode = current;
					end
					db('Cursor'):SetCurrentNode(self.button1)
				end
			end
		end)
		popup:HookScript('OnHide', function(self)
			visible[self] = nil;
			if not next(visible) and not InCombatLockdown() and oldNode then
				db('Cursor'):SetCurrentNode(oldNode)
			end
		end)
	end
end


-- Remove the need to type 'DELETE' when removing rare or better quality items
do  local DELETE_ITEM = CopyTable(StaticPopupDialogs.DELETE_ITEM);
	DELETE_ITEM.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_ITEM = DELETE_ITEM;

	local DELETE_QUEST = CopyTable(StaticPopupDialogs.DELETE_QUEST_ITEM);
	DELETE_QUEST.timeout = 5; -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_QUEST_ITEM = DELETE_QUEST;
end


---------------------------------------------------------------
-- Convenience handler
---------------------------------------------------------------
local Handler = CPAPI.CreateEventHandler({'Frame', '$parentConvenienceHandler', ConsolePort}, {
	'MERCHANT_SHOW';
	'MERCHANT_CLOSED';
	'BAG_UPDATE_DELAYED';
}, {
	SellJunkHelper = function(item)
		if (C_Item.GetItemQuality(item) == Enum.ItemQuality.Poor) then
			UseContainerItem(item:GetBagAndSlot())
		end
	end;
})

function Handler:MERCHANT_CLOSED()
	self.merchantAvailable = nil;
end

function Handler:MERCHANT_SHOW()
	self.merchantAvailable = true;
	if db('autoSellJunk') then
		ContainerFrameUtil_IteratePlayerInventory(self.SellJunkHelper)
	end
end

function Handler:BAG_UPDATE_DELAYED()
	-- repeat attempt to auto-sell junk 
	if self.merchantAvailable then
		self:MERCHANT_SHOW()
	end
end

-- TEMP: slash handler to show config
function ShowGamePadConfig()
	if not IsAddOnLoaded('ConsolePort_Config') then
		LoadAddOn('ConsolePort_Config')
	end
	CPAPI.Log('Use /consoleport to show the config.')
	ConsolePortConfig:Show()
end

_G['SLASH_' .. _:upper() .. '1'] = '/' .. _:lower()
SlashCmdList[_:upper()] = function()
	ShowGamePadConfig()
end