-- TODO: everything

--Button name="ConsolePortSpellFlyout" inherits="SecureHandlerBaseTemplate, SecureActionButtonTemplate" parent="UIParent" registerForClicks="AnyDown" hidden="true"
local Flyout, Selector = SpellFlyout, CreateFrame('Button', 'ConsolePortSpellFlyout', UIParent, 'SecureHandlerBaseTemplate, SecureActionButtonTemplate')
Selector:Execute('this = self')
Selector:WrapScript(Flyout, 'OnShow', [[
	print(self:GetName())
	print(this:GetName())

	this:EnableGamePadStick(true)
	print(GetMouseButtonClicked())
]])

Selector:WrapScript(Flyout, 'OnHide', [[
	this:EnableGamePadStick(false)
]])


function Selector:OnGamePadStick(...)

end

CPAPI.Start(Selector)
Selector:EnableGamePadStick(false)