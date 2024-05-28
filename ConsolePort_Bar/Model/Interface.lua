local c, _, env, Data = CreateCounter(), ...; Data = env.db.Data;
_ = function(i) i.sort = c() return i end;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

env.Toplevel = {
	Toolbar = true;
	Cluster = false;
	Divider = false;
	Group   = false;
}; -- k: interface, v: unique

---------------------------------------------------------------
local Interface = {}; env.Interface = Interface;
---------------------------------------------------------------
Interface.SimplePoint = Data.Interface {
	name = 'Position';
	desc = 'Position of the element.';
	Data.Point {
		point = _{
			name = 'Anchor';
			desc = 'Anchor point relative to parent action bar.';
			Data.Select('CENTER', 'CENTER', 'BOTTOM', 'TOP', 'LEFT', 'RIGHT');
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

Interface.ClusterHandle = Data.Interface {
	name = 'Cluster Handle';
	desc = 'A button cluster for all modifiers of a single button.';
	Data.Table {
		pos = _(Interface.SimplePoint : Implement {
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
			Data.Select('DOWN', env.ClusterConstants.Directions());
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
			Data.Mutable(Interface.ClusterHandle):SetKeyOptions(env.ClusterConstants.ProxyKeyOptions);
		};
		pos = _(Interface.SimplePoint : Implement {
			desc = 'Position of the cluster bar.';
			{
				point = 'BOTTOM';
				y     = 16;
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
		scale = _{
			name = 'Scale';
			desc = 'Scale of the cluster bar.';
			Data.Number(1, 0.1);
		};
	};
};

Interface.GroupButton = Data.Interface {
	name = 'Action Button';
	desc = 'An action button in a group.';
	Data.Table {
		type = {hide = true; Data.String('GroupButton')};
		pos = Interface.SimplePoint : Implement {
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
			Data.Mutable(Interface.GroupButton):SetKeyOptions(env.ClusterConstants.ProxyKeyOptions);
		};
		pos = _(Interface.SimplePoint : Implement {
			desc = 'Position of the group.';
			{
				point = 'BOTTOM';
				y     = 16;
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
		modifier = _{
			name = 'Modifier';
			desc = env.MakeMacroDriverDesc(
				'Modifier condition of the group. Accepts pairs of a macro condition and a modifier.',
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
		rescale = _{
			name = 'Scale';
			desc = env.MakeMacroDriverDesc(
				'Scale condition of the group. Accepts pairs of a macro condition and a scale in percentage, or a single scale value.',
				'Scales the group to the applicable scale.',
				'condition', 'scale', true, nil, {
					['100'] = 'Normal scale.';
					['200'] = 'Double scale.';
					['50']  = 'Half scale.';
				}
			);
			Data.String('100');
		};
		visibility = _{
			name = 'Visibility';
			desc = env.MakeMacroDriverDesc(
				'Visibility condition of the group. Accepts pairs of a macro condition and a visibility state, or a single visibility state.',
				'Shows or hides the group based on the condition.',
				'condition', 'state', true, nil, {
					['show'] = 'Show the group.';
					['hide'] = 'Hide the group.';
				}
			);
			Data.String('show');
		};
		opacity = _{
			name = 'Opacity Driver';
			desc = env.MakeMacroDriverDesc(
				'Opacity condition of the group. Accepts pairs of a macro condition and an opacity in percentage, or a single opacity value.',
				'Changes the opacity of the group based on the condition.',
				'condition', 'opacity', true, nil, {
					['100'] = 'Fully opaque.';
					['50']  = 'Half visible.';
					['0']   = 'Fully transparent.';
				}
			);
			note = 'Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.';
			Data.String('100');
		};
	};
};

Interface.Toolbar = Data.Interface {
	name = 'Toolbar';
	desc = 'A toolbar with XP indicators, shortcuts and other information.';
	Data.Table {
		type = {hide = true; Data.String('Toolbar')};
		pos = _(Interface.SimplePoint : Implement {
			desc = 'Position of the toolbar.';
			{
				point = 'BOTTOM';
			};
		});
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
		pos = _(Interface.SimplePoint : Implement {
			desc = 'Position of the divider.';
			{
				point = 'BOTTOM';
				y     = 100;
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
		opacity = _{
			name = 'Opacity Driver';
			desc = 'Opacity condition of the divider.';
			note = 'Expressed in percentage, where 100 is fully visible and 0 is fully transparent.';
			Data.String('100');
		};
        rescale = _{
            name = 'Scale Driver';
            desc = 'Scale condition of the divider.';
            note = 'Expressed in percentage, where 100 is normal scale.';
            Data.String('100');
        };
	};
};