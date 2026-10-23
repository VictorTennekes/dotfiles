#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
#
# Server mode: Tailscale up + no system sleep, toggled from the menu bar.
# `caffeinate -s` only holds while on AC power, so a forgotten "on" never
# keeps a laptop awake in a bag. The lid must stay open: clamshell sleep can
# only be blocked with sudo pmset, deliberately avoided here.
# Also works as a CLI: server-mode.10s.sh on|off|toggle (~/bin/server-mode links
# here). Option+click the icon for SwiftBar's own menu.

TS=/opt/homebrew/bin/tailscale
PIDFILE="${TMPDIR:-/tmp}/server-mode.pid"

running() {
  [[ -f "$PIDFILE" ]] && ps -p "$(<"$PIDFILE")" -o comm= 2>/dev/null | grep -q caffeinate
}

if [[ "$1" == toggle ]]; then
  running && set -- off || set -- on
fi

case "$1" in
  on)
    "$TS" up || exit 1
    running || { nohup caffeinate -s >/dev/null 2>&1 & echo $! >"$PIDFILE"; }
    exit 0
    ;;
  off)
    running && kill "$(<"$PIDFILE")"
    rm -f "$PIDFILE"
    "$TS" down --accept-risk=lose-ssh
    exit 0
    ;;
esac

# --- Menu bar rendering (SwiftBar runs this every 10s) ---
# Header only, so a click toggles. Same symbol both ways: outline = off,
# filled = on, orange = on but paused because we're on battery.
icon=externaldrive.connected.to.line.below
"$TS" status >/dev/null 2>&1 && ts=up || ts=down
pmset -g batt | grep -q "'AC Power'" && ac=1 || ac=0
click="bash='$0' param1=toggle terminal=false refresh=true"

if ! running; then
  echo "| sfimage=$icon tooltip='Server mode off (Tailscale $ts)' $click"
elif (( ac )); then
  echo "| sfimage=$icon.fill tooltip='Server mode on (Tailscale $ts)' $click"
else
  # sfcolor is ignored in the menu bar; a palette sfconfig is what tints it.
  orange=$(printf '{"renderingMode":"Palette","colors":["#fab387"]}' | base64)
  echo "| sfimage=$icon.fill sfconfig=$orange tooltip='Server mode paused: on battery (Tailscale $ts)' $click"
fi
