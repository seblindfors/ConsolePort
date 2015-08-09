local _, db = ...;
local KEY = db.KEY;
local _DROPDOWN = "DropDownList";
local iterator = { 1, 1, 1 };
local list = 1;
local List1Visible = false;
local List2Visible = false;
local Leave = DropDownList1Button1:GetScript("OnLeave");
local Enter = DropDownList1Button1:GetScript("OnEnter");

_G[_DROPDOWN..1]:HookScript("OnShow", function(self) iterator[1] = 1; List1Visible = true; 	end);
_G[_DROPDOWN..1]:HookScript("OnHide", function(self) iterator[1] = 1; List1Visible = false; end);
_G[_DROPDOWN..2]:HookScript("OnShow", function(self) iterator[2] = 1; List2Visible = true;	end);
_G[_DROPDOWN..2]:HookScript("OnHide", function(self) iterator[2] = 1; List2Visible = false;	end);

function ConsolePort:List(key, state)
	if not List2Visible then list = 1; end;
	local dropDown 	= _G[_DROPDOWN..list];
	local listItems = { dropDown:GetChildren() };
	local buttons 	= {};
	local count 	= 0;
	for _, button in ipairs(listItems) do
		if 	button:IsObjectType("Button") and
			button:IsVisible() and
			button:GetButtonState() ~= "DISABLED" then
			tinsert(buttons, button);
			Leave(button);
			count = count + 1;
		end
	end
	if state == KEY.STATE_UP then
		if 		key == KEY.UP then
			if 	 iterator[list] == 1 then iterator[list] = count;
			else iterator[list] = iterator[list] - 1; end;
		elseif 	key == KEY.DOWN then
			if 	 iterator[list] == count then iterator[list] = 1;
			else iterator[list] = iterator[list] + 1; end;
		end
	end
	local button = buttons[iterator[list]];
	if button then
		Enter(button);
		CP_R_RIGHT_NOMOD:SetAttribute("clickbutton", button);
	--	if key == KEY.CIRCLE and not button.hasArrow then
	--		ConsolePort:Button(button, state);
	--		if state == KEY.STATE_UP then iterator[list] = 1; end;
	--	end
	end
	if 	key == KEY.LEFT or key == KEY.SQUARE then
		if 	_G[_DROPDOWN..(list-1)] and
			_G[_DROPDOWN..(list-1)]:IsVisible() then
			Leave(buttons[iterator[list]]);
			list = list - 1;
			ConsolePort:List(0, KEY.STATE_DOWN);
		end
	elseif 	key == KEY.RIGHT then
		if 	_G[_DROPDOWN..(list+1)] and
			_G[_DROPDOWN..(list+1)]:IsVisible() then
			list = list + 1;
			iterator[list] = 1;
			ConsolePort:List(0, KEY.STATE_DOWN);
		end
	end
end