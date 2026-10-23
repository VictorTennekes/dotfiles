hl.config({
    input = {
        kb_layout  = "us",
        -- Caps Lock -> Escape (same as Karabiner on the Mac)
        kb_options = "caps:escape",

        -- macOS KeyRepeat=2 (30ms -> ~33/s) and InitialKeyRepeat=15 (225ms)
        repeat_rate  = 33,
        repeat_delay = 225,

        follow_mouse = 1,
        sensitivity  = 0,

        -- macOS "natural" scrolling, for mice too
        natural_scroll = true,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            -- Two-finger click = right click, like the Mac trackpad
            clickfinger_behavior = true,
            disable_while_typing = true,
            scroll_factor        = 0.5,
        },
    },

    cursor = {
        hide_on_key_press = true,
        inactive_timeout  = 5,
    },
})

-- Three-finger swipe between workspaces (Mission Control style)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
