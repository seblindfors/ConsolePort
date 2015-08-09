local _, db = ...;
local KEY = db.KEY;
local iterator = 1;
local Enter = MerchantItem1ItemButton:GetScript("OnEnter");
local Leave = MerchantItem1ItemButton:GetScript("OnLeave");

function ConsolePort:Shop(key, state)
	local items = {};
	local currentTab = MerchantFrame.selectedTab;
	local count = GetMerchantNumItems();
	local page = MerchantFrame.page;
	for i=1, 9, 2 do
		tinsert(items, _G["MerchantItem"..i.."ItemButton"]);
	end
	for i=2, 10, 2 do
		tinsert(items, _G["MerchantItem"..i.."ItemButton"]);
	end
	local slot = items[iterator];
	local index = slot:GetID();
	if key == KEY.PREPARE then iterator = 1;
	elseif state == KEY.STATE_DOWN then
		CP_R_RIGHT_NOMOD:SetAttribute("type", "Shop");
		if key == KEY.CIRCLE then
			slot:Click("RightButton");
		elseif key == KEY.SQUARE then
			MouselookStop();
			OpenAllBags();
			PickupMerchantItem(index);
		elseif key == KEY.TRIANGLE then
			local maxStack = GetMerchantItemMaxStack(slot:GetID());
			local _, _, price, stackCount, _, _, extendedCost = GetMerchantItemInfo(slot:GetID());
			if stackCount > 1 and extendedCost then
				slot:Click();
				return;
			end
			local canAfford;
			if 	price and price > 0 then
				canAfford = floor(GetMoney() / (price / stackCount));
			else
				canAfford = maxStack;
			end
			if	maxStack > 1 then
				local maxPurchasable = min(maxStack, canAfford);
				Leave(slot);
				OpenStackSplitFrame(maxPurchasable, slot, "BOTTOMLEFT", "TOPLEFT");
			end
		else
			local 	old = iterator;
			if 		key == KEY.UP 	then iterator = iterator - 1;
			elseif	key == KEY.DOWN 	then iterator = iterator + 1;
			elseif 	key == KEY.RIGHT 	then iterator = iterator + 5;
			elseif 	key == KEY.LEFT 	then iterator = iterator - 5; end;
			if iterator > 10 and MerchantNextPageButton:IsEnabled() and MerchantNextPageButton:IsVisible() then
				MerchantNextPageButton:Click();
				iterator = old - 5;
			elseif iterator < 1 and MerchantPrevPageButton:IsEnabled() and MerchantPrevPageButton:IsVisible() then
				MerchantPrevPageButton:Click();
				iterator = old + 5;
			elseif iterator < 1 or iterator > 10 then
				iterator = old;
			end
			if not items[iterator].hasItem then
				iterator = 1;
			end
			slot = items[iterator];
			ConsolePort:Highlight(iterator, items);
			Enter(slot);
		end
	end
end

