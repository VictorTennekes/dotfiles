/*
 * Bar — the top floating panel (one instance per screen).
 *
 * Geometry matches the v3 mockup's `data-bar="floating"`:
 *   – anchored top + left + right with side and top margins,
 *   – a single rounded surface (translucent), border + drop shadow,
 *   – three regions: workspaces (left), clock+media (center), status (right).
 *
 * `exclusiveZone` reserves the bar's vertical footprint so niri tiles
 * windows below it; we add the top margin to it so the gap is also
 * respected, not just the bar height.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.services
import qs.widgets

PanelWindow {
    id: bar

    // The window itself is invisible; the visible bar is the inner rect.
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }
    margins.top:   Tokens.topPad
    margins.left:  Tokens.gap
    margins.right: Tokens.gap

    implicitHeight: Tokens.barHeight
    exclusiveZone:  Tokens.barHeight + Tokens.topPad

    // Hint to layer-shell which namespace we own (helps debuggers/tools).
    WlrLayershell.namespace: "qs-bar"

    Rectangle {
        id: chrome
        anchors.fill: parent
        radius: Tokens.radius
        color: Tokens.surface
        border.color: Tokens.border2
        border.width: 1

        // Subtle inner highlight (matches the mockup's inset top-edge sheen).
        Rectangle {
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                margins: 1
            }
            height: 1
            color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.05)
            radius: parent.radius
        }

        RowLayout {
            id: row
            anchors.fill: parent
            anchors.leftMargin:  Tokens.pad - 4
            anchors.rightMargin: Tokens.pad - 4
            spacing: Tokens.gap

            // ── LEFT: workspace pills ───────────────────────────────────
            Workspaces {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            // Spring spacer (pushes center to true middle).
            Item { Layout.fillWidth: true }

            // ── CENTER: clock + (when active) media pill ────────────────
            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignVCenter

                Clock {}
                MediaPill { visible: Media.active }
            }

            // Spring spacer.
            Item { Layout.fillWidth: true }

            // ── RIGHT: status icons ─────────────────────────────────────
            StatusItems {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }
    }

    // Drop shadow — MultiEffect renders the bar's silhouette as a shadow
    // behind it. We use MultiEffect because layer-surface compositor
    // shadows aren't available on niri (no blur/shadow layer protocol).
    MultiEffect {
        anchors.fill: chrome
        source: chrome
        shadowEnabled: true
        shadowBlur: 0.6
        shadowVerticalOffset: 14
        shadowOpacity: 0.45
        shadowColor: "black"
        z: -1
    }
}
