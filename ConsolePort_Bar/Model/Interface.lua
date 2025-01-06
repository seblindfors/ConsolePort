local c, _, env, Data = CreateCounter(), ...; Data = env.db.Data;
_ = function(i) i.sort = c() return i end;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

env.Toplevel = {
	Art     = false;
	Cluster = false;
	Divider = false;
	Group   = false;
	Page    = false;
	Petring = true;
	Toolbar = true;
}; -- k: interface, v: unique

---------------------------------------------------------------
local Type = {}; env.Types = Type;
---------------------------------------------------------------
Type.SimplePoint = Data.Interface {
	name = 'Position';
	desc = 'Position of the element.';
	Data.Point {
		point = _{
			name = 'Anchor';
			desc = 'Anchor point to attach.';
			Data.Select('CENTER', env.Const.ValidPoints());
		};
		relPoint = _{
			name = 'Relative Anchor';
			desc = 'Anchor point of parent to pair with.';
			Data.Select('CENTER', env.Const.ValidPoints());
		};
		x = _{
			name = 'X Offset';
			desc = 'Horizontal offset from anchor point.';
			Data.Number(0, 1, true);
		};
		y = _{
			name = 'Y Offset';
			desc = 'Vertical offset from anchor point.';
			vert = true;
			Data.Number(0, 1, true);
		};
	};
};

Type.ComplexPoint = Data.Interface {
	name = 'Position';
	desc = 'Position of the element.';
	Data.Point {
		point = _{
			name = 'Anchor';
			desc = 'Anchor point to attach.';
			Data.Select('CENTER', env.Const.ValidPoints());
		};
		relPoint = _{
			name = 'Relative Anchor';
			desc = 'Anchor point of parent to pair with.';
			Data.Select('CENTER', env.Const.ValidPoints());
		};
		strata = _{
			name = 'Strata';
			desc = 'Frame strata of the element.';
			Data.Select('MEDIUM', env.Const.ValidStratas());
		};
		level = _{
			name = 'Level';
			desc = 'Frame level of the element.';
			Data.Number(2, 1);
		};
		x = _{
			name = 'X Offset';
			desc = 'Horizontal offset from anchor point.';
			Data.Number(0, 1, true);
		};
		y = _{
			name = 'Y Offset';
			desc = 'Vertical offset from anchor point.';
			vert = true;
			Data.Number(0, 1, true);
		};
		offsetscale = _{
			name = 'Relative Rescale';
			desc = 'Maintain offset relative to scale.';
			Data.Bool(false);
		};
	};
};

Type.Visibility = Data.Interface {
	name = 'Visibility';
	desc = env.MakeMacroDriverDesc(
		'Visibility condition of the element. Accepts pairs of a macro condition and a visibility state, or a single visibility state.',
		'Shows or hides the element based on the condition.',
		'condition', 'state', true, nil, {
			['show'] = 'Show the element.';
			['hide'] = 'Hide the element.';
		}
	);
	Data.String(env.Const.DefaultVisibility);
};

Type.Opacity = Data.Interface {
	name = 'Opacity';
	desc = env.MakeMacroDriverDesc(
		'Opacity condition of the element. Accepts pairs of a macro condition and an opacity in percentage, or a single opacity value.',
		'Changes the opacity of the element based on the condition.',
		'condition', 'opacity', true, nil, {
			['100'] = 'Fully opaque.';
			['50']  = 'Half visible.';
			['0']   = 'Fully transparent.';
		}
	);
	note = 'Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.';
	Data.String('100');
};

Type.Scale = Data.Interface {
	name = 'Scale';
	desc = env.MakeMacroDriverDesc(
		'Scale condition of the element. Accepts pairs of a macro condition and a scale in percentage, or a single scale value.',
		'Scales the element to the applicable scale.',
		'condition', 'scale', true, nil, {
			['100'] = 'Normal scale.';
			['200'] = 'Double scale.';
			['50']  = 'Half scale.';
		}
	);
	Data.String('100');
};

Type.Override = Data.Interface {
	name = 'Override';
	desc = env.MakeMacroDriverDesc(
		'Binding override condition of the element. Accept pairs of a macro condition and an override state, or a single override state.',
		'Sets or unsets applicable bindings to the element.',
		'condition', 'override', true, nil, {
			['true']   = 'Bindings are set to the element.';
			['false']  = 'Bindings are removed from the element.';
			['shown']  = 'Bindings are set to the element when it is shown.';
			['hidden'] = 'Bindings are set to the element when it is hidden.';
		}
	);
	Data.String('shown');
};

Type.Modifier = Data.Interface {
	name = 'Modifier';
	desc = env.MakeMacroDriverDesc(
		'Modifier condition of the element. Accepts pairs of a macro condition and a modifier.',
		'Swaps the buttons to show the applicable modifier.',
		'condition', 'modifier', false, {
			['M0']   = 'Shorthand for no modifiers.';
			['M1']   = 'Shorthand for the Shift modifier.';
			['M2']   = 'Shorthand for the Ctrl modifier.';
			['M3']   = 'Shorthand for the Alt modifier.';
			['[mod:...]'] = 'Prefix for matching a modifier being held.';
			['[]']   = 'Empty condition, always true.';
		}, {
			['Mn']   = 'Button set to swap to, where n is the modifier number. Multiple modifiers can be combined.';
		}
	);
	note = 'Modifiers can be combined. For example, M1M2 is the Shift and Ctrl modifiers held at the same time.';
	Data.String(' ');
};

Type.Page = Data.Interface {
	name = 'Page';
	desc = env.MakeMacroDriverDesc(
		'Page condition of the element. Accepts pairs of a macro condition and a page identifier, or a single page number.',
		'Swaps the buttons to the applicable page, with the formula:\nslotID = (page - 1) * slots + offset + i',
		'condition', 'page', true, env.Const.PageDescription, {
			['dynamic']  = 'Dynamic page number, matching the global page number.';
			['override'] = 'Resolves to the current override or vehicle page.';
			['n']        = 'Static page number to swap to.';
		}
	);
	Data.String('dynamic');
};

---------------------------------------------------------------
local Interface = {}; env.Interface = Interface;
---------------------------------------------------------------
Interface.ClusterHandle = Data.Interface {
	name = 'Cluster Handle';
	desc = 'A button cluster for all modifiers of a single button.';
	Data.Table {
		type = {hide = true; Data.String('ClusterHandle')};
		pos = _(Type.SimplePoint : Implement {
			desc = 'Position of the button cluster.';
		});
		size = _{
			name = 'Size';
			desc = 'Size of the button cluster.';
			Data.Number(64, 2);
		};
		showFlyouts = _{
			name = 'Show Flyouts';
			desc = 'Show the flyout of small buttons for the button cluster.';
			Data.Bool(true);
		};
		dir = _{
			name = 'Direction';
			desc = 'Direction of the button cluster.';
			Data.Select('DOWN', env.Const.Cluster.Directions());
		};
	};
};

Interface.Cluster = Data.Interface {
	name = 'Cluster Action Bar';
	desc = 'A cluster action bar.';
	Data.Table {
		type = {hide = true; Data.String('Cluster')};
		children = _{
			name = 'Buttons';
			desc = 'Buttons in the cluster bar.';
			Data.Mutable(Interface.ClusterHandle):SetKeyOptions(env.Const.ProxyKeyOptions);
		};
		pos = _(Type.SimplePoint : Implement {
			desc = 'Position of the cluster bar.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 16;
			};
		});
		width = _{
			name = 'Width';
			desc = 'Width of the cluster bar.';
			Data.Number(1200, 25);
		};
		height = _{
			name = 'Height';
			desc = 'Height of the cluster bar.';
			Data.Number(140, 25);
		};
		rescale    = _(Type.Scale : Implement {});
		visibility = _(Type.Visibility : Implement {});
		opacity    = _(Type.Opacity : Implement {});
		override   = _(Type.Override : Implement {});
	};
};

Interface.GroupButton = Data.Interface {
	name = 'Action Button';
	desc = 'An action button in a group.';
	Data.Table {
		type = {hide = true; Data.String('GroupButton')};
		pos = Type.SimplePoint : Implement {
			desc = 'Position of the button.';
		};
	};
};

Interface.Group = Data.Interface {
	name = 'Action Button Group';
	desc = 'A group of action buttons.';
	Data.Table {
		type = {hide = true; Data.String('Group')};
		children = _{
			name = 'Buttons';
			desc = 'Buttons in the group.';
			Data.Mutable(Interface.GroupButton):SetKeyOptions(env.Const.ProxyKeyOptions);
		};
		pos = _(Type.ComplexPoint : Implement {
			desc = 'Position of the group.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 16;
			};
		});
		width = _{
			name = 'Width';
			desc = 'Width of the group.';
			Data.Number(400, 10);
		};
		height = _{
			name = 'Height';
			desc = 'Height of the group.';
			Data.Number(120, 10);
		};
		modifier   = _(Type.Modifier : Implement {});
		rescale    = _(Type.Scale : Implement {});
		visibility = _(Type.Visibility : Implement {});
		opacity    = _(Type.Opacity : Implement {});
		override   = _(Type.Override : Implement {});
	};
};

Interface.Page = Data.Interface {
	name = 'Action Page';
	desc = 'A page of action buttons.';
	Data.Table {
		type = {hide = true; Data.String('Page')};
		pos = _(Type.ComplexPoint : Implement {
			desc = 'Position of the page.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 20;
			};
		});
		hotkeys = _{
			name = 'Show Hotkeys';
			desc = 'Show the hotkeys on the buttons.';
			Data.Bool(true);
		};
		reverse = _{
			name = 'Reverse Order';
			desc = 'Reverse the order of the buttons.';
			Data.Bool(false);
		};
		paddingX = _{
			name = 'Horizontal Padding';
			desc = 'Padding between buttons horizontally.';
			Data.Number(4, 1);
		};
		paddingY = _{
			name = 'Vertical Padding';
			desc = 'Padding between buttons vertically.';
			vert = true;
			Data.Number(4, 1);
		};
		orientation = _{
			name = 'Orientation';
			desc = 'Orientation of the page.';
			Data.Select('HORIZONTAL', 'HORIZONTAL', 'VERTICAL');
		};
		stride = _{
			name = 'Stride';
			desc = 'Number of buttons per row or column.';
			Data.Range(NUM_ACTIONBAR_BUTTONS, 1, 1, NUM_ACTIONBAR_BUTTONS);
		};
		slots = _{
			name = 'Slots';
			desc = 'Number of buttons in the page.';
			Data.Range(NUM_ACTIONBAR_BUTTONS, 1, 1, NUM_ACTIONBAR_BUTTONS);
		};
		offset = _{
			name = 'Offset';
			desc = 'Starting point of the page.';
			Data.Range(1, 1, 1, NUM_ACTIONBAR_BUTTONS);
		};
		page       = _(Type.Page : Implement {});
		rescale    = _(Type.Scale : Implement {});
		visibility = _(Type.Visibility : Implement {});
		opacity    = _(Type.Opacity : Implement {});
		override   = _(Type.Override : Implement {});
	};
};

Interface.Petring = Data.Interface {
	name = 'Pet Ring';
	desc = 'A ring of buttons for pet commands.';
	Data.Table {
		type = {hide = true; Data.String('Petring')};
		pos = _(Type.ComplexPoint : Implement {
			desc = 'Position of the pet ring.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 90;
			};
		});
		fade = _{
			name = 'Fade Buttons';
			desc = 'Fade out the pet ring when not moused over.';
			Data.Bool(true);
		};
		status = _{
			name = 'Status Bar';
			desc = 'Show the pet power and health status.';
			Data.Bool(true);
		};
		vehicle = _{
			name = 'Enable Vehicle';
			desc = 'Show the pet ring when in a vehicle.';
			Data.Bool(true);
		};
		scale = _{
			name = 'Scale';
			desc = 'Scale of the pet ring.';
			Data.Range(0.75, 0.05, 0.5, 2);
		};
	};
};

Interface.Toolbar = Data.Interface {
	name = 'Toolbar';
	desc = 'A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.';
	Data.Table {
		type = {hide = true; Data.String('Toolbar')};
		pos = _(Type.SimplePoint : Implement {
			desc = 'Position of the toolbar.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
			};
		});
		menu = _{
			name = 'Menu';
			desc = 'Menu buttons to display on the toolbar.';
			Data.Table {
				eye = _{
					name = 'Cluster Modifier Toggle';
					desc = 'Toggle visibility of all modifier flyouts for cluster action bars.';
					Data.Bool(true);
				};
				micromenu = _{
					name = 'Micro Menu';
					desc = 'Take ownership of, and move the micro menu buttons to the toolbar.';
					note = 'Requires /reload to fully unhook when disabled.';
					Data.Bool(true);
				};
			};
		};
		castbar = _{
			name = 'Casting Bar';
			desc = 'Configure the casting bar.';
			note = 'This feature is only available in Classic.';
			hide = CPAPI.IsRetailVersion;
			Data.Table {
				enabled = _{
					name = 'Enable';
					desc = 'Enable casting bar ownership.';
					note = 'Requires /reload to fully unhook when disabled.';
					Data.Bool(true);
				};
			};
		};
		totem = _{
			name = 'Class Bar';
			desc = 'Configure the class related bar.';
			note = CPAPI.IsRetailVersion and 'This feature is only available in Classic.';
			hide = CPAPI.IsRetailVersion;
			Data.Table {
				enabled = _{
					name = 'Enable';
					desc = 'Enable class bar ownership.';
					note = 'Requires /reload to fully unhook when disabled.';
					Data.Bool(true);
				};
				hidden = _{
					name = 'Hide';
					desc = 'Hide the class bar.';
					Data.Bool(false);
				};
				pos = _(Type.SimplePoint : Implement {
					desc = 'Position of the class bar.';
					{
						point    = 'BOTTOM';
						relPoint = 'BOTTOM';
						y        = 190;
					};
				});
			};
		};
		width = _{
			name = 'Width';
			desc = 'Width of the toolbar.';
			Data.Range(900, 25, 300, 1200);
		};
	};
};

Interface.Divider = Data.Interface {
	name = 'Divider';
	desc = 'A divider to separate elements.';
	Data.Table {
		type = {hide = true; Data.String('Divider')};
		pos = _(Type.ComplexPoint : Implement {
			desc = 'Position of the divider.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 100;
			};
		});
		breadth = _{
			name = 'Breadth';
			desc = 'Breadth of the divider.';
			Data.Number(400, 25);
		};
		depth = _{
			name = 'Depth';
			desc = 'Depth of the divider.';
			vert = true;
			Data.Number(50, 10);
		};
		thickness = _{
			name = 'Thickness';
			desc = 'Thickness of the divider.';
			Data.Range(1, 1, 1, 10)
		};
		intensity = _{
			name = 'Intensity';
			desc = 'Intensity of the gradient.';
			Data.Range(25, 5, 0, 100);
		};
		rotation = _{
			name = 'Rotation';
			desc = 'Rotation of the divider.';
			Data.Range(0, 5, 0, 360);
		};
		transition = _{
			name = 'Transition';
			desc = 'Transition time for opacity changes.';
			note = 'Time in milliseconds for the opacity to change from one state to another.';
			Data.Range(50, 25, 0, 500);
		};
		opacity = _(Type.Opacity : Implement {});
		rescale = _(Type.Scale : Implement {});
	};
};

Interface.Art = Data.Interface {
	name = 'Art';
	desc = 'Artwork for the interface.';
	Data.Table {
		type = {hide = true; Data.String('Art')};
		pos = _(Type.SimplePoint : Implement {
			desc = 'Position of the artwork.';
			{
				point    = 'BOTTOM';
				relPoint = 'BOTTOM';
				y        = 16;
			};
		});
		width = _{
			name = 'Width';
			desc = 'Width of the artwork.';
			Data.Number(768, 16);
		};
		height = _{
			name = 'Height';
			desc = 'Height of the artwork.';
			Data.Number(192, 16);
		};
		style = _{
			name = 'Style';
			desc = 'Artwork style.';
			Data.Select('Collage', env.Const.Art.Types());
		};
		flavor = _{
			name = 'Flavor';
			desc = 'Artwork flavor.';
			Data.Select('Class', 'Class', unpack(env.Const.Art.Selection));
		};
		blend = _{
			name = 'Blend Mode';
			desc = 'Blend mode of the artwork.';
			Data.Select('BLEND', env.Const.Art.Blend());
		};
		opacity = _(Type.Opacity : Implement {});
		rescale = _(Type.Scale : Implement {});
	};
};