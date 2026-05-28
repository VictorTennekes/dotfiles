/*
 * MediaPill — the small "now playing" pill that sits next to the clock.
 *
 * Composition: square album cover (real artwork when MPRIS provides a
 * URL, otherwise a generative gradient swatch) · title · "— artist" ·
 * animated 4-bar EQ. The EQ animates only while Media.status === Playing.
 *
 * Clicking the pill toggles play/pause; right-click skips. Keeps the
 * interaction local — no popout required.
 */

import QtQuick
import qs.services

Rectangle {
    id: pill
    height: 20
    radius: Tokens.radiusPill
    color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.04)
    border.color: Tokens.border1
    border.width: 1

    // Width fits the row of children + 8 px padding on both sides.
    implicitWidth: contentRow.implicitWidth + 16

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        spacing: 8

        // ── Cover art (image when available, gradient stub otherwise) ───
        Item {
            width: 16; height: 16
            anchors.verticalCenter: parent.verticalCenter

            // Gradient stub — visible when no artUrl or while it loads.
            Rectangle {
                anchors.fill: parent
                radius: 4
                visible: !art.visible
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Tokens.accent }
                    GradientStop { position: 1.0; color: Tokens.mauve }
                }
                // Inner hole (matches the mockup's record-disc affectation).
                Rectangle {
                    anchors.centerIn: parent
                    width: 8; height: 8; radius: 4
                    color: Qt.rgba(Tokens.mantle.r, Tokens.mantle.g, Tokens.mantle.b, 0.85)
                    border.color: Qt.rgba(Tokens.text.r, Tokens.text.g, Tokens.text.b, 0.30)
                    border.width: 1
                }
            }

            Image {
                id: art
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: Media.artUrl.length > 0 && status === Image.Ready
                // Round the corners — Image doesn't have radius, so a clip.
                layer.enabled: true
            }
        }

        // ── Title · artist ──────────────────────────────────────────────
        Text {
            text: Media.title
            color: Tokens.ink1
            font.family: Tokens.ffSans
            font.pixelSize: 11
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            // Cap the title width so a long song doesn't shove the bar.
            width: Math.min(implicitWidth, 140)
        }
        Text {
            text: "— " + Media.artist
            color: Tokens.ink4
            font.family: Tokens.ffSans
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 90)
            visible: Media.artist.length > 0
        }

        // ── Animated EQ bars ────────────────────────────────────────────
        Row {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: 4
                delegate: Rectangle {
                    required property int index
                    width: 2
                    radius: 1
                    color: Tokens.accent
                    // Each bar has its own resting height and animation phase.
                    readonly property var heights: [6, 10, 4, 8]
                    height: heights[index]
                    transformOrigin: Item.Bottom
                    SequentialAnimation on scale {
                        running: Media.playing
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.4; duration: 450
                                          easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 450
                                          easing.type: Easing.InOutSine }
                        PauseAnimation { duration: index * 75 }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) Media.next();
            else Media.playPause();
        }
    }
}
