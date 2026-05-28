/*
 * QuickSettings — the popout below the bar's right edge.
 *
 * Layer:    overlay (above tiled windows + Bar).
 * Anchor:   top + right with margins matching the bar's geometry.
 * Toggle:   `qs ipc call quickSettings toggle` (bind in niri config.kdl).
 *
 * The blurred chrome is rendered client-side via MultiEffect — niri has
 * no layer-shell blur, so we can't ask the compositor for backdrop blur.
 * Instead we render the popout itself with a heavily-translucent fill +
 * a soft shadow + an inner sheen, which reads as glassy without needing
 * to see what's behind it.
 *
 * Content sections (top to bottom):
 *   1. Header  — avatar + user@host + power
 *   2. Tiles   — 4 toggles (Wi-Fi / BT / Night / DND)
 *   3. Sliders — brightness · keyboard · volume
 *   4. Media   — cover · title · artist · scrubber · play button
 *   5. Footer  — shell label + live RAM
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.services

PanelWindow {
    id: panel
    color: "transparent"
    visible: false

    // Anchor under the bar's right side. Margins mirror Bar so the popout
    // visually hangs from the bar rather than free-floating.
    anchors {
        top: true
        right: true
    }
    margins.top:   Tokens.topPad + Tokens.barHeight + 8
    margins.right: Tokens.gap

    implicitWidth:  320
    implicitHeight: card.implicitHeight

    // Overlay layer — sits above app windows.
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-quicksettings"
    // Click outside doesn't dismiss yet; use the keybind to toggle.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // ── IPC ──────────────────────────────────────────────────────────────
    IpcHandler {
        target: "quickSettings"
        function toggle(): void { panel.visible = !panel.visible }
        function show():   void { panel.visible = true }
        function hide():   void { panel.visible = false }
    }

    // ── Card chrome ─────────────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius: Tokens.radiusLg
        color: Qt.rgba(Tokens.mantle.r, Tokens.mantle.g, Tokens.mantle.b, 0.88)
        border.color: Tokens.border3
        border.width: 1

        // Top inner sheen.
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 1 }
            height: 1
            radius: parent.radius
            color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.06)
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // ── 1. Header ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Avatar — initial chip with accent → mauve gradient.
                Rectangle {
                    width: 32; height: 32; radius: 16
                    gradient: Gradient {
                        orientation: Gradient.Diagonal
                        GradientStop { position: 0.0; color: Tokens.accent }
                        GradientStop { position: 1.0; color: Tokens.mauve }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "V"            // first letter of user; static for now
                        color: Tokens.mantle
                        font.family: Tokens.ffSans
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: "victor"
                        color: Tokens.ink1
                        font.family: Tokens.ffSans
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Text {
                        text: "~ on r2d2"
                        color: Tokens.ink4
                        font.family: Tokens.ffMono
                        font.pixelSize: 11
                    }
                }

                // Power button.
                Rectangle {
                    width: 28; height: 28; radius: 8
                    color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.04)
                    border.color: Tokens.border1
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        // nf-fa power-off
                        text: ""
                        color: Tokens.ink3
                        font.family: Tokens.ffMono
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: Quickshell.execDetached(["niri", "msg", "action", "power-off-monitors"])
                    }
                }
            }

            // ── 2. Toggle tile grid ─────────────────────────────────────
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 6
                rowSpacing: 6

                component Tile : Rectangle {
                    property string glyph
                    property string label
                    property bool   on:    false
                    property var    onClick: function() {}
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 10
                    color: on
                        ? Tokens.accentSoft
                        : Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.04)
                    border.color: on ? Tokens.accentRing : Tokens.border1
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: Tokens.transFast } }
                    Behavior on border.color { ColorAnimation { duration: Tokens.transFast } }
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: parent.parent.glyph
                            color: parent.parent.on ? Tokens.accent : Tokens.ink3
                            font.family: Tokens.ffMono
                            font.pixelSize: 16
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: parent.parent.label
                            color: parent.parent.on ? Tokens.ink1 : Tokens.ink3
                            font.family: Tokens.ffSans
                            font.pixelSize: 10
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.onClick()
                    }
                }

                Tile { glyph: "";  label: "Wi-Fi"; on: Network.isWifi && Network.online }
                Tile { glyph: ""; label: "BT" }                                       // stub: Bluetooth service is a follow-up
                Tile { glyph: "";  label: "Night" }                                    // stub: wlsunset toggle is a follow-up
                Tile { glyph: ""; label: "DND" }
            }

            // ── 3. Sliders ──────────────────────────────────────────────
            component QSlider : RowLayout {
                property string glyph
                property int    value: 0          // 0..100
                property int    accentMin: 0
                property var    onChange: function(v) {}
                property var    trail                       // optional right-side adornment
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: parent.glyph
                    color: Tokens.ink3
                    font.family: Tokens.ffMono
                    font.pixelSize: 14
                    Layout.preferredWidth: 18
                }

                Rectangle {                                  // track
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.06)
                    Rectangle {                              // fill
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: parent.width * (parent.parent.value / 100)
                        radius: parent.radius
                        color: Tokens.accent
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: mouse => if (pressed) parent.parent.onChange(
                            Math.round((mouse.x / width) * 100))
                        onClicked: mouse => parent.parent.onChange(
                            Math.round((mouse.x / width) * 100))
                    }
                }

                Text {
                    text: parent.value.toString()
                    color: Tokens.ink3
                    font.family: Tokens.ffMono
                    font.pixelSize: 11
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight
                }
            }

            QSlider {
                glyph: ""
                value: Brightness.screen
                onChange: function(v) { Brightness.setScreen(v) }
            }
            // Keyboard slider — replace the numeric trail with 3 dots.
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: ""
                    color: Tokens.ink3
                    font.family: Tokens.ffMono
                    font.pixelSize: 14
                    Layout.preferredWidth: 18
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.06)
                    Rectangle {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: parent.width * (Brightness.keyboard / 100)
                        radius: 3
                        color: Tokens.accent
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => Brightness.setKeyboard(Math.round((mouse.x / width) * 100))
                    }
                }
                Row {
                    spacing: 3
                    Layout.preferredWidth: 28
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            required property int index
                            width: 6; height: 6; radius: 3
                            color: index < Brightness.kbdSteps ? Tokens.accent
                                                                : Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.10)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
            QSlider {
                glyph: ""
                value: Volume.level
                onChange: function(v) { Volume.set(v) }
            }

            // ── 4. Media card ───────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 62
                radius: 10
                color: Qt.rgba(Tokens.surface0.r, Tokens.surface0.g, Tokens.surface0.b, 0.30)
                border.color: Tokens.border1
                border.width: 1
                visible: Media.active

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Album cover (gradient stub unless artUrl loads).
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 6
                        gradient: Gradient {
                            orientation: Gradient.Diagonal
                            GradientStop { position: 0.0; color: Tokens.accent }
                            GradientStop { position: 1.0; color: Tokens.mauve }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 18; height: 18; radius: 9
                            color: Qt.rgba(Tokens.mantle.r, Tokens.mantle.g, Tokens.mantle.b, 0.85)
                            border.color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.30)
                            border.width: 1
                        }
                        Image {
                            anchors.fill: parent
                            source: Media.artUrl
                            visible: Media.artUrl.length > 0 && status === Image.Ready
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: Media.title
                            color: Tokens.ink1
                            font.family: Tokens.ffSans
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Media.artist
                            color: Tokens.ink4
                            font.family: Tokens.ffSans
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 3
                            radius: 999
                            color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.08)
                            Rectangle {
                                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                width: parent.width * Media.progress
                                radius: parent.radius
                                color: Tokens.accent
                            }
                        }
                    }

                    // Play / pause button — accent fill, mantle glyph.
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: Tokens.accent
                        Text {
                            anchors.centerIn: parent
                            text: Media.playing ? "" : ""    // nf-fa pause / play
                            color: Tokens.mantle
                            font.family: Tokens.ffMono
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Media.playPause()
                        }
                    }
                }
            }

            // ── 5. Footer ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "quickshell · niri"
                    color: Tokens.ink4
                    font.family: Tokens.ffSans
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }
                Text {
                    text: "live"
                    color: Tokens.green
                    font.family: Tokens.ffMono
                    font.pixelSize: 10
                }
            }
        }
    }

    // Drop shadow behind the card.
    MultiEffect {
        anchors.fill: card
        source: card
        shadowEnabled: true
        shadowBlur: 0.8
        shadowVerticalOffset: 36
        shadowOpacity: 0.55
        shadowColor: "black"
        z: -1
    }
}
