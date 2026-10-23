local mod = "SUPER"

local terminal = "footclient"
local browser  = "zen-browser"
local files    = "footclient yazi"
local launcher = "pkill fuzzel || fuzzel"

local function bind(keys, cmd, opts)
    hl.bind(mod .. " + " .. keys, hl.dsp.exec_cmd(cmd), opts)
end

-- Apps
bind("Return",         terminal)
bind("SHIFT + Return", browser)
bind("space",          launcher)
bind("E",              files)
bind("SHIFT + V",      "cliphist list | fuzzel --dmenu --prompt '󰅌  ' | cliphist decode | wl-copy")
bind("N",              "swaync-client -t -sw")
bind("SHIFT + B",      "pkill -SIGUSR1 waybar") -- toggle bar

-- Session
bind("CTRL + Q", "loginctl lock-session")       -- macOS ctrl+cmd+Q
bind("Escape",   "~/.config/hypr/scripts/powermenu")

-- Screenshots, macOS numbers on Alt+Shift (Super+Shift+number moves windows):
-- 3 = full screen, 4 = region, 5 = region + annotate
hl.bind("ALT + SHIFT + 3", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot screen"))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot region"))
hl.bind("ALT + SHIFT + 5", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot edit"))
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot region"))

-- Windows
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

local dirs = { left = "left", right = "right", up = "up", down = "down",
               H = "left", L = "right", K = "up" }
for key, dir in pairs(dirs) do
    hl.bind(mod .. " + " .. key,           hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.swap({ direction = dir }))
end

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + Tab",        hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + S",          hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S",  hl.dsp.window.move({ workspace = "special:scratch" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys through swayosd (shows the on-screen indicator)
local function key(k, cmd, rep)
    hl.bind(k, hl.dsp.exec_cmd(cmd), { locked = true, repeating = rep })
end
key("XF86AudioRaiseVolume",  "swayosd-client --output-volume raise", true)
key("XF86AudioLowerVolume",  "swayosd-client --output-volume lower", true)
key("XF86AudioMute",         "swayosd-client --output-volume mute-toggle")
key("XF86AudioMicMute",      "swayosd-client --input-volume mute-toggle")
key("XF86MonBrightnessUp",   "swayosd-client --brightness raise", true)
key("XF86MonBrightnessDown", "swayosd-client --brightness lower", true)
key("XF86AudioNext",         "swayosd-client --playerctl next")
key("XF86AudioPrev",         "swayosd-client --playerctl previous")
key("XF86AudioPlay",         "swayosd-client --playerctl play-pause")
key("XF86AudioPause",        "swayosd-client --playerctl play-pause")
-- Framework F12 (gear) key
key("XF86AudioMedia",        "swaync-client -t -sw")
