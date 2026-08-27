if not CPAPI.IsRetailVersion then return end;
---------------------------------------------------------------
-- Target frame auras (Mainline)
---------------------------------------------------------------
-- Blizzard's custom aura containers drive the buttons from the
-- secure side, so aura data never has to be read by the addon.

local Ring = ConsolePortTargetRing;

local function InitializeAuraButton(size, button)
	button:SetSize(size, size)

	local icon = button:CreateTexture(nil, 'ARTWORK')
	icon:SetAllPoints()
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
	cooldown:SetAllPoints()
	cooldown:SetReverse(true)
	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)

	local count = cooldown:CreateFontString(nil, 'OVERLAY', 'NumberFontNormalSmall')
	count:SetPoint('BOTTOMRIGHT', 2, 0)

	local border = button:CreateTexture(nil, 'OVERLAY')
	border:SetPoint('TOPLEFT', -1, 1)
	border:SetPoint('BOTTOMRIGHT', 1, -1)

	button:SetIcon(icon)
	button:SetDurationCooldown(cooldown)
	button:SetApplicationCount(count)
	button:SetAuraBorder(border, { style = Enum.CustomAuraButtonDispelTypeTextureStyle.Border })
end

function Ring.CreateAuraContainer(parent, filter, size, gap, max)
	local container = CreateFrame('AuraContainer', nil, parent, 'CustomAuraContainerTemplate')
	container:AddAuraGroup(filter, filter, {
		maxFrameCount   = max;
		initializeFrame = GenerateClosure(InitializeAuraButton, size);
		layout = {
			elementSpacing = gap;
			elementWidth   = size;
			elementHeight  = size;
		};
	})
	container:SetEnabled(false)
	return container;
end

function Ring.SetAuraContainerMirrored(container, mirrored)
	container:SetFlowLayoutAnchorPoint(mirrored and 'TOPRIGHT' or 'TOPLEFT')
	container:SetFlowLayoutGrowthDirection(
		mirrored and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
		AnchorUtil.FlowDirection.Down
	)
end
