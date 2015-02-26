local _
local _, G = ...;
local iterator = 16;
local Enter = ContainerFrame1Item1:GetScript("OnEnter");
local Leave = ContainerFrame1Item1:GetScript("OnLeave");

function ConsolePort:CleanBags() 
	local i, item;
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			i = { GetContainerItemInfo(bag, slot) };
			item = i[7];
			if item and string.find(item,"9d9d9d") then
				UseContainerItem(bag, slot);
			end
		end
	end
	BagItemAutoSortButton:Click();
end

local function UnlockAll()
	for b=1, 5 do for s = 1, GetContainerNumSlots(b-1) do
		_G["ContainerFrame"..b.."Item"..s]:UnlockHighlight();
	end end
end

function ConsolePort:Bags (key, state)
	UnlockAll();
	local bagSlots = {};
	local slotCount = 0;
	for bag = 1, 5 do
		for slotNum = 1, GetContainerNumSlots(bag-1) do
			slotCount = slotCount + 1;
			table.insert(bagSlots, { 
				slot 		= _G["ContainerFrame"..bag.."Item"..slotNum],
				bagIndex  	= bag-1,
				slotIndex 	= GetContainerNumSlots(bag-1)+1-slotNum,
			});
		end
	end
	if iterator > slotCount then iterator = 16; end;
	local slot = bagSlots[iterator];
	if 	slot.slot then 
		slot.slot:LockHighlight();
		Enter(slot.slot);
		if	not MerchantFrame:IsVisible() and
			not InCombatLockdown() then
			CP_R_RIGHT_NOMOD:SetAttribute("type", "item");
			CP_R_RIGHT_NOMOD:SetAttribute("item", slot.bagIndex.." "..slot.slotIndex);
		end
	end
	if 		key == G.PREPARE then return;
	elseif 	key == G.CIRCLE then
		UseContainerItem(slot.bagIndex, slot.slotIndex);
	elseif 	key == G.SQUARE then
		if 	state == G.STATE_DOWN then
			PickupContainerItem(slot.bagIndex, slot.slotIndex);
		end
		if 	CursorHasItem() then
			MouselookStop();
		end
	elseif 	state == G.STATE_DOWN then
		if 		key == G.UP 	then iterator = iterator + 4;
		elseif 	key == G.DOWN 	then iterator = iterator - 4;
		elseif	key == G.LEFT	then iterator = iterator + 1;
		elseif 	key == G.RIGHT	then iterator = iterator - 1 end;
		if 		iterator > slotCount then iterator = 1
		elseif 	iterator < 1 then iterator = slotCount end;
	end
end