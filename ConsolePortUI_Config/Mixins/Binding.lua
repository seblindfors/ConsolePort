local _, L = ...
local db = L.db
L.BindingMixin = {
	Bindings = {},
	Headers = {},
}

local bindPrefix = "BINDING_NAME_" -- this prefix is used for actual bindings
local sortPrefix = "BINDING_" -- this prefix is used for headers inside categories
local bindFormat = "%s\n|cFF575757%s|r"
local bindingCounter = 0
local BindingMixin = L.BindingMixin

function BindingMixin:GetBindingInfo()
	if self.reserved then
		return self.reserved
	else
		local binding = self.binding
		if binding then
			local bindingText = binding and _G[bindPrefix..binding]
			local header, name = not self.omitHeader and binding and self.Headers[binding]

			local id = ConsolePort:GetActionID(binding)
			-- this binding has an action ID
			if id then
				-- re-calculate an action ID based on the current action page
				local loc = db.TUTORIAL.BIND
				local actionpage = MainMenuBarArtFrame:GetAttribute("actionpage") or 1
				id = id <= 12 and id + ( ( actionpage - 1 ) * 12 ) or id

				local texture = GetActionTexture(id)

				local actionType, actionID, subType, spellID = GetActionInfo(id)
				
				if actionType == "spell" and actionID then
					name = GetSpellInfo(actionID) or loc.SPELL
				elseif actionType == "item" and actionID then
					name = GetItemInfo(actionID) or loc.ITEM
				elseif actionType == "macro" then
					name = GetActionText(id) and GetActionText(id)..loc.MACRO
				elseif actionType == "companion" then
					name = loc[subType]
				elseif actionType == "summonmount" then
					name = loc.MOUNT
				elseif actionType == "equipmentset" then
					name = actionID..loc.EQSET
				end

				-- if the action has a name, suffix the binding and omit the header
				name = name and format(bindFormat, name, bindingText)

				if name then
					-- at this point there's a name and texture for the action ID
					return name, texture
				elseif texture then
					if bindingText then
						name = header and _G[header]
						name = name and format(bindFormat, bindingText, name) or bindingText 
					end
					return name, texture
				else
					name = header and _G[header]
					return name and format(bindFormat, bindingText, name) or bindingText
				end
			-- this binding does not have an action ID, just return the binding and header names
			elseif bindingText then
				name = header and _G[header]
				return name and format(bindFormat, bindingText, name) or bindingText
			-- at this point, this is not a usual binding. this is most likely a click/spell binding.
			else
				name = gsub(binding, "(.* ([^:]+).*)", "%2")
				return name
			end
		else
			return self.default
		end
	end
end

function BindingMixin:Refresh()
	if bindingCounter ~= GetNumBindings() then
		self:RefreshBindings()
	end

	local name, texture = self:GetBindingInfo()
	
	if name and texture then
		self.Mask:Show()
		self:SetText(name)
		self.SetIcon(self.Icon, texture)
	elseif texture then
		self.Mask:Show()
		self:SetText(self.default)
		self.SetIcon(self.Icon, texture)
	elseif name then
		self.Mask:Hide()
		self.Icon:SetTexture()
		self:SetText(name)
	end
end

function BindingMixin:RefreshBindings()
	local numBindings = GetNumBindings()
	-- check if the bindings have been updated since the last run (bindings can be added, but not removed)
	if numBindings ~= bindingCounter then
		local bindings = self.Bindings
		local headers = self.Headers

		-- wipe all current bindings, since indices may have changed
		wipe(bindings)
		wipe(headers)

		for i=1, numBindings do
			local id, header = GetBinding(i)

			-- link bindings to their respective header, so reverse lookup can be performed
			headers[id] = header

			local binding = _G[bindPrefix..id]
			local name = binding or _G[sortPrefix..id]
			-- if the binding has a designated header
			if header then
				-- use the header title if there is one.
				local hTitle = _G[header] or header
				local category = bindings[hTitle]
				if not category then
					category = {}
					bindings[hTitle] = category
				end
				-- add binding to its designated category table, omit binding index if not an actual binding
				category[#category + 1] = {name = name, binding = id}
			-- else check that this isn't (1) a header which isn't blank and is not a controller header or (2) just a header
			elseif ( id:match("^HEADER") and not id:match("^HEADER_BLANK") and not id:match("^CP_") ) or ( not id:match("^HEADER") ) then
				-- at this point, the binding definitely belongs in the "Other" category
				local otherCategory = bindings[BINDING_HEADER_OTHER]
				if not otherCategory then
					otherCategory = {}
					bindings[BINDING_HEADER_OTHER] = otherCategory
				end
				-- add binding to the "Other" table, omit binding index if not an actual binding
				otherCategory[#otherCategory + 1] = {name = name, binding = id}
			end
		end
		-- scrub base controller bindings, since they're not relevant.
		bindings["ConsolePort "] = nil
		-- include hidden bindings
		bindings[db.TUTORIAL.BIND.MAINCATEGORY] = ConsolePort:GetAddonBindings()
		-- update/add the counter
		bindingCounter = numBindings
	end
	return self.Bindings, self.Headers
end

L.GetBindingMetaButton = function(name, parent, config)
	assert(config, "Config.GetBindingMetaButton: No config provided.")
	---------------------------------
	local 	width, height, templates, hitRects,
			justifyH, textWidth, textPoint,
			iconPoint, iconSpaceX, iconSpaceY,
			useButton, buttonTexture, buttonPoint,
			binding, default, anchor = 
	---------------------------------
			config.width, config.height, config.templates, config.hitRects,
			config.justifyH, config.textWidth, config.textPoint,
			config.iconPoint, config.iconSpaceX, config.iconSpaceY,
			config.useButton, config.buttonTexture, config.buttonPoint,
			config.binding, config.default, config.anchor
	---------------------------------
	local self = CreateFrame("Button", name, parent, templates)
	local text = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local icon = self:CreateTexture(nil, "ARTWORK", nil, 7)
	local mask = self:CreateTexture(nil, "OVERLAY", nil, 7)

	self.Icon = icon
	self.Text = text
	self.Mask = mask

	self:SetSize(width or 200, height or 30)

	self.default = default or db.TUTORIAL.BIND.NOTASSIGNED
	self.omitHeader = config.omitHeader

	self:SetFontString(text)
	self:SetText(self.default)

	text:SetWidth(textWidth or width or 200)
	text:SetTextHeight(12)
	text:SetSpacing(2)
	text:SetWordWrap(true)
	text:SetJustifyH(justifyH or "LEFT")

	icon:SetSize(30, 30)

	self.SetIcon = SetPortraitToTexture

	if hitRects then
		self:SetHitRectInsets(unpack(hitRects))
	end

	if useButton then
		local button = self:CreateTexture(nil, "OVERLAY")
		button:SetSize(30, 30)
		button:SetTexture(buttonTexture)
		if buttonPoint then
			local point, relativePoint, xOffset, yOffset = unpack(buttonPoint)
			button:SetPoint(point, self, relativePoint, xOffset, yOffset)
		end
		self.ButtonTexture = button
	end
	if iconPoint then
		local point, relativePoint, xOffset, yOffset = unpack(iconPoint)
		icon:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end	
	if textPoint then
		local point, relativePoint, xOffset, yOffset = unpack(textPoint)
		text:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end
	if anchor then
		local point, relativePoint, xOffset, yOffset = unpack(anchor)
		self.customAnchor = {point, self, relativePoint, xOffset, yOffset}
	end

	mask:SetPoint("CENTER", icon, "CENTER", 0, 0)
	mask:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
	mask:SetSize(32, 32)
	mask:Hide()

	for k, v in pairs(BindingMixin) do
		self[k] = v
	end
	
	return self
end

---------------------------------------------------------------