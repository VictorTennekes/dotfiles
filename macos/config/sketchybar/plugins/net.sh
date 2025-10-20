#!/usr/bin/env sh

LABEL=$(networksetup -listpreferredwirelessnetworks en0 | grep -v '^Preferred networks on' | head -1 | xargs)
ICON=""


sketchybar --set $NAME icon=$ICON label=$LABEL
