#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
#
# Server mode = reachable over Tailscale, toggled from the menu bar. Staying
# awake is macOS's job: `pmset -c sleep 0` (scripts/setup) keeps the Mac awake
# on the charger only, so on battery it sleeps normally. The lid must stay open.
# Also works as a CLI: server-mode.10s.sh on|off|toggle (~/bin/server-mode links
# here). Option+click the icon for SwiftBar's own menu.

TS=/opt/homebrew/bin/tailscale

running() { "$TS" status >/dev/null 2>&1; }

if [[ "$1" == toggle ]]; then
  running && set -- off || set -- on
fi

case "$1" in
  on)  exec "$TS" up ;;
  off) exec "$TS" down --accept-risk=lose-ssh ;;
esac

# --- Menu bar rendering (SwiftBar runs this every 10s) ---
# Header only, so a click toggles. Same symbol both ways: outline = off,
# filled = reachable, orange = reachable but on battery (so it will sleep).
icon=externaldrive.connected.to.line.below
click="bash='$0' param1=toggle terminal=false refresh=true"

if ! running; then
  echo "| sfimage=$icon tooltip='Server mode off: unreachable' $click"
elif pmset -g batt | grep -q "'AC Power'"; then
  echo "| sfimage=$icon.fill tooltip='Server mode on: reachable, stays awake' $click"
else
  # sfcolor is ignored in the menu bar; a palette sfconfig is what tints it.
  orange=$(printf '{"renderingMode":"Palette","colors":["#fab387"]}' | base64)
  echo "| sfimage=$icon.fill sfconfig=$orange tooltip='Server mode on, but on battery: will sleep normally' $click"
fi
