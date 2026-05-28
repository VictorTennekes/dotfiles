/*
 * StatusItems — right-side icon row (brightness, kbd, network, volume,
 * battery, idle dot). Each item is glyph + thin value text. Glyphs are
 * Nerd Font FontAwesome characters embedded via \u escapes so the
 * encoding survives editor/transport (per memory).
 *
 * Click-to-open is wired through to QuickSettings via the global
 * IpcHandler defined in components/QuickSettings.qml — left-click any
 * item to toggle the popout.
 */

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

Row {
    id: status
    spacing: 12

    // Compact item — glyph + value text in a single row.
    component Item_ : Row {
        spacing: 4
        property string glyph
        property string value
        property color  glyphColor: Tokens.ink3
        property color  textColor:  Tokens.ink2

        Text {
            text: parent.glyph
            color: parent.glyphColor
            font.family: Tokens.ffMono                // Nerd Font is in mono
            font.pixelSize: Tokens.tBar
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: parent.value
            color: parent.textColor
            font.family: Tokens.ffSans
            font.pixelSize: Tokens.tLabel
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.value.length > 0
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["qs", "ipc", "call", "quickSettings", "toggle"])
        }
    }

    Item_ {                                            // brightness — sun
        glyph: ""
        value: Brightness.screen.toString()
    }
    Item_ {                                            // keyboard backlight
        glyph: ""
        value: Brightness.kbdSteps.toString()
    }
    Item_ {                                            // network — wifi
        glyph: ""
        value: Network.online ? "" : "off"
        glyphColor: Network.online ? Tokens.ink3 : Tokens.ink5
    }
    Item_ {                                            // volume — speaker
        glyph: Volume.muted ? "" : ""      // mute vs speaker-up
        value: Volume.level.toString()
        glyphColor: Volume.muted ? Tokens.ink5 : Tokens.ink3
    }
    Item_ {                                            // battery — capacity-aware
        glyph: {
            if (Battery.charging) return "";     // bolt
            if (Battery.capacity >= 90) return "";   // full
            if (Battery.capacity >= 65) return "";   // 3/4
            if (Battery.capacity >= 40) return "";   // half
            if (Battery.capacity >= 15) return "";   // 1/4
            return "";                                // empty
        }
        value: Battery.capacity + "%"
        glyphColor: Battery.capacity <= 15 && !Battery.charging
                    ? Tokens.red : Tokens.ink3
    }

    // Idle indicator (always green when shell is alive — purely cosmetic).
    Rectangle {
        width: 6; height: 6; radius: 3
        color: Tokens.green
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.85
    }
}
