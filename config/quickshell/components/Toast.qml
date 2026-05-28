/*
 * Toast — shell-internal notification surface.
 *
 * Distinct from mako (which still owns OS-level dbus notifications). This
 * is for shell-emitted messages: "Theme switched to Latte", "Audio sink
 * changed", "Niri config reloaded", etc.
 *
 * Usage from anywhere via Quickshell IPC:
 *     qs ipc call toast show "Title" "Body text"
 *     qs ipc call toast hide
 *
 * The toast auto-dismisses after `timeoutMs`. Geometry mirrors the v3
 * mockup: top-left, anchored just below the bar.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.services

PanelWindow {
    id: toast
    color: "transparent"
    visible: false

    anchors {
        top:  true
        left: true
    }
    margins.top:  Tokens.topPad + Tokens.barHeight + 8
    margins.left: Tokens.gap

    implicitWidth:  card.implicitWidth
    implicitHeight: card.implicitHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-toast"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property string title: "niri"
    property string body:  ""
    property int    timeoutMs: 4000

    IpcHandler {
        target: "toast"
        function show(title: string, body: string): void {
            toast.title = title;
            toast.body = body;
            toast.visible = true;
            dismiss.restart();
        }
        function hide(): void { toast.visible = false }
    }

    Timer {
        id: dismiss
        interval: toast.timeoutMs
        onTriggered: toast.visible = false
    }

    Rectangle {
        id: card
        radius: 12
        color: Qt.rgba(Tokens.mantle.r, Tokens.mantle.g, Tokens.mantle.b, 0.92)
        border.color: Tokens.border2
        border.width: 1
        implicitWidth:  Math.min(420, layout.implicitWidth + 28)
        implicitHeight: layout.implicitHeight + 20

        // Left accent stripe — keeps the toast immediately legible.
        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 8 }
            width: 3
            radius: 2
            color: Tokens.accent
        }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.leftMargin: 22
            anchors.rightMargin: 14
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 2

            Text {
                text: toast.title
                color: Tokens.ink1
                font.family: Tokens.ffSans
                font.pixelSize: 12
                font.weight: Font.Medium
            }
            Text {
                text: toast.body
                color: Tokens.ink3
                font.family: Tokens.ffSans
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 380
                visible: text.length > 0
            }
        }
    }

    MultiEffect {
        anchors.fill: card
        source: card
        shadowEnabled: true
        shadowBlur: 0.7
        shadowVerticalOffset: 16
        shadowOpacity: 0.45
        shadowColor: "black"
        z: -1
    }
}
