local env, db, Observer = CPAPI.GetEnv(...); Observer = env.Frame;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

local function CreateCursorInfoAction(infoType, ...)
	local infoHandler = env.SecureHandlerMap[infoType];
	if infoHandler then
		return infoHandler(...);
	end
end

local function CreatePendingAction(setID, info, enabled)
	return {
		setID = setID;
		info  = info;
		add   = enabled;
	};
end

---------------------------------------------------------------
-- Cursor info action
---------------------------------------------------------------
function Observer:AddFromCursorInfo(setID, idx)
	local info = CreateCursorInfoAction(GetCursorInfo())
	if info then
		return self:AddUniqueAction(setID, idx, info)
	end
end

function Observer:CheckCursorInfo(setID, silent)
	if not InCombatLockdown() then
		setID = self:GetSetID(setID);
		if GetCursorInfo() then
			if self:AddFromCursorInfo(setID) then
				if not silent then
					-- TODO: map returns to links
					self:AnnounceAddition(
						GetCursorInfo():gsub('^%l', strupper),
						self:GetBindingSuffixForSet(setID), true
					);
				end
				ClearCursor()
				db:TriggerEvent('OnRingContentChanged', setID)
			end
		end
	end
end

---------------------------------------------------------------
-- Pending action
---------------------------------------------------------------
function Observer:SetPendingAction(setID, info, force)
	if force or self:IsUniqueAction(setID, info) then
		self.pendingAction = CreatePendingAction(setID, info, true)
		return true;
	end
end

function Observer:SetPendingRemove(setID, info)
	self.pendingAction = CreatePendingAction(setID, info, false)
	return true;
end

function Observer:HasPendingAction()
	return self.pendingAction;
end

function Observer:ClearPendingAction()
	self.pendingAction = nil;
end

function Observer:PostPendingAction(preferredIndex)
	local action = self.pendingAction;
	if action then
		if action.add then
			if self:AddAction(action.setID, preferredIndex, action.info) then
				self:AnnounceAddition(action.info.link, self:GetBindingSuffixForSet(action.setID), true)
			end
		else
			if self:ClearActionByAttribute(action.setID, 'link', action.info.link) then
				self:AnnounceRemoval(action.info.link)
			end
		end
		self.pendingAction = nil;
	end
end