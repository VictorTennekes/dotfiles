-- Built-in 2880x1920 panel. 1.6 gives an 1800x1200 workspace (2 is huge on 13.5").
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1920@120",
    position = "0x0",
    scale    = 1.6,
})

-- Anything plugged in: preferred mode, to the right.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
