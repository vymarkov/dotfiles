local wezterm = require("wezterm")
local act = wezterm.action
return {
	-- enable_osc52_copy_on_remote_host = true,
	adjust_window_size_when_changing_font_size = false,
	-- color_scheme = 'termnial.sexy',
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = true,
	font_size = 14.0,
	font = wezterm.font("JetBrains Mono"),
	-- macos_window_background_blur = 40,
	macos_window_background_blur = 5,

	-- window_background_image = '/Users/omerhamerman/Downloads/3840x1080-Wallpaper-041.jpg',
	-- window_background_image_hsb = {
	-- 	brightness = 0.01,
	-- 	hue = 1.0,
	-- 	saturation = 0.5,
	-- },
	-- window_background_opacity = 0.92,
	--	window_background_opacity = 1.0,
	window_background_opacity = 0.78,
	-- window_background_opacity = 0.25,
	-- window_background_opacity = 0.55,
	window_decorations = "RESIZE",
	keys = { -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
		{
			key = "LeftArrow",
			mods = "OPT",
			action = act.SendKey({
				key = "b",
				mods = "ALT",
			}),
		},
		{
			key = "RightArrow",
			mods = "OPT",
			action = act.SendKey({ key = "f", mods = "ALT" }),
		},
		{
			key = "q",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "'",
			mods = "CTRL",
			action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
		},
		{ key = "k", mods = "CTRL|SHIFT", action = act.ScrollByPage(-0.5) },
		{ key = "j", mods = "CTRL|SHIFT", action = act.ScrollByPage(0.5) },
		-- split wezterm window
		{
			key = "h",
			mods = "CTRL|SHIFT",
			action = wezterm.action.SplitHorizontal({}),
		},
		{
			key = "v",
			mods = "CTRL|SHIFT",
			action = wezterm.action.SplitVertical({}),
		},
		{
			key = "l",
			mods = "CMD|SHIFT",
			action = wezterm.action.ActivateTabRelative(1),
		},
		{
			key = "h",
			mods = "CMD|SHIFT",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		{ key = "p", mods = "CMD|SHIFT", action = wezterm.action.ShowLauncher },
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
