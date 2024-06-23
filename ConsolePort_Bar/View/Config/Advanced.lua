local _, env, db = ...; db = env.db;
---------------------------------------------------------------
local Editor = CreateFromMixins(ScrollingEditBoxMixin);
---------------------------------------------------------------

local function Format(text) return (text or ''):gsub('\t', '  ') end;
local function Prune(text, cmp)  return text ~= cmp and text or nil end;

function Editor:SetData(current, default)
	self:SetDefaultTextEnabled(not current)
	self:SetDefaultText(Format(default))
	self:SetText(Format(current))
end

function Editor:GetData()
	return Prune(self:GetInputText(), ''), self:GetEditBox().defaultText;
end

---------------------------------------------------------------
local Advanced = Mixin({
---------------------------------------------------------------
	EditorControls = {
		{
			tooltipTitle = RESET;
			icon         = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
			iconSize     = 16;
			onClickHandler = function(self)
				local _, default = self.data.get()
				self.data.set(default)
				self.data.editor:SetData(self.data.get())
			end;
		};
		{
			tooltipTitle = SAVE;
			icon         = [[Interface\RAIDFRAME\ReadyCheck-Ready]];
			iconSize     = 16;
			onClickHandler = function(self)
				local text = self.data.editor:GetData()
				if text then
					self.data.set(text)
				end
			end;
		};
	};
	Headers = {
		Condition = {
			name   = 'Page Condition';
			height = 50;
			get    = function() return db('actionPageCondition'), db.Pager:GetDefaultPageCondition() end;
			set    = function(value) db('Settings/actionPageCondition', Prune(value, db.Pager:GetDefaultPageCondition())) end;
			text   = env.MakeMacroDriverDesc(
				'Global condition of the action bar page. Accepts pairs of a macro condition and a page number, or a single page number.',
				'Sends the resulting page to the response handler for post-processing.',
				'actionbar', 'page', true, env.Const.PageDescription, {
					n = 'Page number to forward to the response handler.';
					any = 'A simple value (number, string, boolean) to forward to the response handler where the real action page number is calculated.';
				}, WHITE_FONT_COLOR);
		};
		Response = {
			name   = 'Page Response';
			height = 150;
			get    = function() return db('actionPageResponse'), db.Pager:GetDefaultPageResponse() end;
			set    = function(value) db('Settings/actionPageResponse', Prune(value, db.Pager:GetDefaultPageResponse())) end;
			text   = env.MakeMacroDriverDesc(
				'Global post-processing in Lua of the action bar page condition. This is shared across all action bars and systems. Restricted environment API only.',
				'Sets the resulting page to the action headers, which in turn update the action buttons.',
				nil, nil, nil, {
					newstate = 'The resulting value from the condition handler.';
				}, {
					newstate = 'The resulting page number to set on the action headers.';
				}, WHITE_FONT_COLOR);
		};
		Visibility = {
			name   = 'Visibility Condition';
			height = 30;
			get    = function() return env('Layout/visibility'), env.Const.ManagerVisibility end;
			set    = function(value) env('Layout/visibility', value) end;
			text   = env.MakeMacroDriverDesc(
				'Global condition for the visibility of the action bar. This is shared across all action bars.',
				'Sets the visibility of all action bar components based on the result of the condition.',
				'actionbar', 'visibility', true, {
					['vehicleui']   = 'Vehicle UI is active.';
					['overridebar'] = 'An override bar is active, used when the specific scenario does not have a vehicle UI.';
					['petbattle']   = 'Player is in a pet battle.';
				}, {
					['show'] = 'Show the action bar(s).';
					['hide'] = 'Hide the action bar(s).';
				}, WHITE_FONT_COLOR);
		};
	};
}, env.SharedConfig.HeaderOwner);

function Advanced:OnLoad(inputHandler, headerPool)
	local sharedConfig = env.SharedConfig;
	sharedConfig.HeaderOwner.OnLoad(self, sharedConfig.Header)

	self.owner = inputHandler;
	self.headerPool = headerPool;
	self.cmdButtonPool = sharedConfig.CreateSquareButtonPool(self, sharedConfig.CmdButton)

	CPAPI.Start(self)
end

function Advanced:OnShow()
	local layoutIndex = CreateCounter()
	self.headerPool:ReleaseAll()
	self.cmdButtonPool:ReleaseAll()
	self:MarkDirty()

	local function DrawEditor(info)
		local header = self:CreateHeader(info.name)
		header.layoutIndex = layoutIndex()
		header:SetTooltipInfo(info.name, info.text)

		local editor = info.editor or Mixin(env.SharedConfig.CreateEditBox(self), Editor);
		editor:SetSize(header:GetWidth() - 8, info.height)
		editor.layoutIndex = layoutIndex()
		editor.leftPadding, editor.topPadding = 8, 8;
		editor:SetData(info.get())
		info.editor = editor;

		local left, right = math.huge, 0;
		for i, control in ipairs(self.EditorControls) do
			local button = self.cmdButtonPool:Acquire()
			button:SetPoint('RIGHT', header, 'RIGHT', -(32 * (i - 1)), 0)
			button:Setup(control, info)
			button:SetFrameLevel(header:GetFrameLevel() + 1)
			button:Show()
			left, right = math.min(left, button:GetLeft()), math.max(right, button:GetRight())
		end
		header:SetIndentation(-(right - left))
	end

	DrawEditor(self.Headers.Visibility)
	DrawEditor(self.Headers.Condition)
	DrawEditor(self.Headers.Response)
end

env.SharedConfig.Advanced = Advanced;