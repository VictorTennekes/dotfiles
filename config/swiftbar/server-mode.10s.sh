#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
#
# Server mode: Tailscale up + no system sleep, toggled from the menu bar.
# `caffeinate -s` only holds while on AC power, so a forgotten "on" never
# keeps a laptop awake in a bag. The lid must stay open: clamshell sleep can
# only be blocked with sudo pmset, deliberately avoided here.
# Also works as a CLI: server-mode.10s.sh on|off (~/bin/server-mode links here).

TS=/opt/homebrew/bin/tailscale
PIDFILE="${TMPDIR:-/tmp}/server-mode.pid"

running() {
  [[ -f "$PIDFILE" ]] && ps -p "$(<"$PIDFILE")" -o comm= 2>/dev/null | grep -q caffeinate
}

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
# Same symbol both ways: outline = off, filled = on (battery pause shows in the menu).
icon=externaldrive.connected.to.line.below
"$TS" status >/dev/null 2>&1 && ts=up || ts=down
pmset -g batt | grep -q "'AC Power'" && ac=1 || ac=0

if running; then
  if (( ac )); then
    echo "| sfimage=$icon.fill"
    echo "---"
    echo "Server mode: ON (Tailscale $ts)"
  else
    echo "| sfimage=$icon.fill"
    echo "---"
    echo "Server mode: paused, on battery (Tailscale $ts)"
  fi
  echo "Turn off | bash='$0' param1=off terminal=false refresh=true"
else
  echo "| sfimage=$icon"
  echo "---"
  echo "Server mode: OFF (Tailscale $ts)"
  echo "Turn on | bash='$0' param1=on terminal=false refresh=true"
fi
