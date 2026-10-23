hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Native Wayland everywhere it's supported (sharper, less power than XWayland)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- No accessibility bus (at-spi) for GTK apps; re-enable if you need a screen reader
hl.env("GTK_A11Y", "none")
hl.env("NO_AT_BRIDGE", "1")
