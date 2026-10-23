-- Catppuccin Mocha
local mauve    = "rgb(cba6f7)"
local peach    = "rgb(fab387)"
local surface0 = "rgba(313244aa)"

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border   = { colors = { mauve, peach }, angle = 45 },
            inactive_border = surface0,
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Shadows and blur cost GPU time every frame. Keep them cheap: a small
        -- shadow, and xray blur (blurs only the cached wallpaper, not windows).
        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = "rgba(11111b99)",
        },
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            xray              = true,
            new_optimizations = true,
            popups            = false,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = "rgb(11111b)",
        -- Wake the screen on input after DPMS off
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
        focus_on_activate       = true,
        -- Throttle unfocused-but-visible windows (saves power with video etc.)
        render_unfocused_fps    = 15,
    },

    xwayland = {
        -- Off: everything here is native Wayland (saves ~70MB). X11-only apps
        -- (Steam, some games/Electron apps) won't open; set true to bring it back.
        enabled = false,
        -- Let XWayland apps render at native res instead of blurry upscaling
        force_zero_scaling = true,
    },

    dwindle = {
        preserve_split = true,
        -- New windows always open to the right/bottom, not where the mouse is
        force_split = 2,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

-- Short, snappy animations (shorter = fewer rendered frames = less power)
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1}    } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}  } })

hl.animation({ leaf = "global",     enabled = true, speed = 6,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3,   bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "linear",       style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slide" })
