hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Small utility windows float, centered
hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(org.pulseaudio.pavucontrol|blueberry.py|nwg-look|xdg-desktop-portal-gtk|hyprland-share-picker|com.gabm.satty|org.tui.floating)$" },
    float  = true,
    center = true,
    size   = "900 600",
})

hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
})

-- Blur behind the bar, notifications, launcher and OSD
hl.layer_rule({
    name  = "blur-shell",
    match = { namespace = "^(waybar|swaync-control-center|swaync-notification-window|launcher|swayosd)$" },
    blur  = true,
    blur_popups = true,
    ignore_alpha = 0.3,
})

-- Launcher opens/closes instantly (like Spotlight); a fade-out left an empty
-- blurred rectangle behind for a moment
hl.layer_rule({
    name    = "launcher-no-anim",
    match   = { namespace = "^launcher$" },
    no_anim = true,
})
