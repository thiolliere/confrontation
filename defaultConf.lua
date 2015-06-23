function configure()
	local width = 800               -- The window width (number)
	local height = 600              -- The window height (number)
	local flags = {}
	flags.borderless = false        -- Remove all border visuals from the window (boolean)
	flags.resizable = false         -- Let the window be user-resizable (boolean)
	flags.minwidth = 1              -- Minimum window width if the window is resizable (number)
	flags.minheight = 1             -- Minimum window height if the window is resizable (number)
	flags.fullscreen = false        -- Enable fullscreen (boolean)
	flags.fullscreentype = "normal" -- Standard fullscreen or desktop fullscreen mode (string)
	flags.vsync = true              -- Enable vertical sync (boolean)
	flags.fsaa = 0                  -- The number of samples to use with multi-sampled antialiasing (number)
	flags.display = 1               -- Index of the monitor to show the window in (number)
	flags.highdpi = false           -- Enable high-dpi mode for the window on a Retina display (boolean)
	flags.srgb = false              -- Enable sRGB gamma correction when drawing to the screen (boolean)
	flags.x = nil                   -- The x-coordinate of the window's position in the specified display (number)
	flags.y = nil                   -- The y-coordinate of the window's position in the specified display (number)

	love.window.setMode(width,height,flags)

	local scan = love.keyboard.getKeyFromScancode	-- to not be bother by azerty and querty

	keymap={}					
	keymap.quit = "escape"
	keymap[1]={
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		key = " "
	}
	keymap[2]={
		up = scan("w"),
		down = scan("s"),
		left = scan("a"),
		right = scan("d"),
		key = scan("q")
	}
	keymap[3]={
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		key = " "
	}
	keymap[4]={
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		key = " "
	}
end
