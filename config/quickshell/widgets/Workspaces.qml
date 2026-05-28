/*
 * Workspaces — pill row driven by Niri.workspaces.
 *
 * v1 (this build): index + occupied indicator + accent for active.
 * Click switches focus to that workspace via Niri.focusWorkspace(id).
 *
 * v2 (follow-up): per-pill app-glyph for the focused window in that
 * workspace. Stub left in place (the AppGlyph delegate is wired but
 * sources from an empty map; populate `appGlyphMap` to enable).
 */

import QtQuick
import QtQuick.Layouts
import qs.services

Row {
    id: workspaces
    spacing: 4

    // app_id (lowercase) → Nerd Font glyph. Populate as you discover
    // common app_ids on this system; missing entries fall back silently.
    readonly property var appGlyphMap: ({
        // "firefox":  "",   // nf-fa-firefox
        // "ghostty":  "",   // nf-fa-terminal
        // "code":     "",
        // "obsidian": ""
    })

    Repeater {
        model: Niri.workspaces

        delegate: Rectangle {
            id: pill
            // Niri workspace records: { id, idx, name, output, is_active,
            //   active_window_id, … } — both `idx` (display index) and
            //   `id` (stable handle) are present.
            required property var modelData

            readonly property bool active: modelData.is_active === true
            readonly property bool occupied: (modelData.active_window_id != null)
            readonly property string label:
                modelData.name && modelData.name.length > 0
                ? modelData.name
                : (modelData.idx != null ? modelData.idx.toString() : "·")

            height: 22
            width: Math.max(22, contentRow.implicitWidth + 14)
            radius: Tokens.radiusSm

            color: active
                   ? Tokens.accentSoft
                   : Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.04)
            border.width: 1
            border.color: active ? Tokens.accentRing : Tokens.border1

            Behavior on color        { ColorAnimation { duration: Tokens.transFast } }
            Behavior on border.color { ColorAnimation { duration: Tokens.transFast } }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 5

                // Occupied dot (hidden when active — accent fill already signals it).
                Rectangle {
                    visible: pill.occupied && !pill.active
                    width: 4; height: 4; radius: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Tokens.ink5
                }

                Text {
                    text: pill.label
                    color: pill.active ? Tokens.ink1 : Tokens.ink3
                    font.family: Tokens.ffSans
                    font.pixelSize: Tokens.tLabel
                    font.weight: pill.active ? Font.Medium : Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(modelData.id)
            }
        }
    }

    // Layout-hint trailing piece (col N / M) — niri scrollable affordance.
    // Hidden until we can read it from niri IPC; placeholder so the row
    // still parses cleanly when uncommented later.
    // Rectangle { … }
}
