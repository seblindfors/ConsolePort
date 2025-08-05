local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local UnpackEntryID, CurrentSetID;

local function MapToAction(info)
	return info.funcs.map(env.SecureHandlerMap, UnpackEntryID(info.id));
end

local function GetCurrentSetEntry(info)
	local action = MapToAction(info);
	return Container:SearchActionByCompare(CurrentSetID, action);
end

local function AppendAction(info)
	local action = MapToAction(info);
	return Container:AddUniqueAction(CurrentSetID, nil, action);
end

local function ReplaceAction(info, index)
	env.ReplaceID = nil;
	local action = MapToAction(info);
	Container:RemoveAction(CurrentSetID, index);
	return Container:AddUniqueAction(CurrentSetID, index, action);
end

local function RemoveAction(info)
	local action = MapToAction(info);
	return not Container:ClearActionByCompare(CurrentSetID, action);
end

---------------------------------------------------------------
local Entry = CPAPI.CreateElement('CPRingLoadoutCard', 292, 48);
---------------------------------------------------------------

function Entry:OnSelected(info)
	if self:GetChecked() then
		local operation = env.ReplaceID and ReplaceAction or AppendAction;
		self:SetChecked(operation(info, env.ReplaceID))
	else
		self:SetChecked(RemoveAction(info))
	end
	self:OnButtonStateChanged()
	env:TriggerEvent('OnSetChanged', CurrentSetID, self:GetChecked())
end

function Entry:ShouldBeChecked(info)
	return GetCurrentSetEntry(info)
end

function Entry:OnLeaveEntry()
	env:TriggerEvent('OnIndexHighlight', nil)
end

function Entry:OnFocusEntry(info)
	local index = GetCurrentSetEntry(info)
	if index then
		env:TriggerEvent('OnIndexHighlight', index)
	end
end

function Entry:OnAcquire(new)
	if new then
		env.SharedConfig.LoadoutEntry.OnAcquire(self, new)
		CPAPI.Specialize(self, Entry)
		self.Icon.SetTexture = env.ActionButton.SkinUtility.SetTexture;
	end
end

---------------------------------------------------------------
local Loadout = {}; env.SharedConfig.Loadout = Loadout;
---------------------------------------------------------------
-- Extends CPLoadoutContainerMixin.

function Loadout:OnLoad()
	self:InitDefault()

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
	env:RegisterCallback('OnSearch', self.OnSearch, self)
	env:RegisterCallback('OnSetChanged', self.OnSetChanged, self)
	env:RegisterCallback('OnConfigShown', self.OnConfigShown, self)

	local LoadoutEntry = env.SharedConfig.LoadoutEntry;
	Entry, UnpackEntryID = CreateFromMixins(LoadoutEntry, Entry), LoadoutEntry.UnpackID;
end

function Loadout:OnSelectSet(_, setID, isSelected)
	CurrentSetID = isSelected and setID or nil;
	self:ClearCollections()
end

function Loadout:OnSetChanged(setID)
	if ( setID == CurrentSetID ) then
		self:GetScrollView():ReinitializeFrames()
	end
end

function Loadout:OnConfigShown(shown)
	if not shown then
		self:ClearCollections()
	end
end

function Loadout:OnShow()
	local shouldMoveCursor = not self.Collections;
	self:RefreshCollections()
	if not shouldMoveCursor then return end;
	local firstHeader = self:FindFirstFrameOfType(select(2, self:GetElements()), self:GetScrollView())
	if firstHeader then
		ConsolePort:SetCursorNodeIfActive(firstHeader)
	end
end

function Loadout:GetCollections(...)
	if not self.Collections then
		CPLoadoutContainerMixin.GetCollections(self, ...);
		tAppendAll(self.Collections, env:GetCollections(CurrentSetID, env:IsSharedSet(CurrentSetID)));
	end
	return self.Collections;
end

function Loadout:GetElements()
	return Entry, CPLoadoutContainerMixin.GetElements(self)
end