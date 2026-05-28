/*
 * Clock — center cluster's primary item.
 *
 * Two-line-feeling layout in a single row (matches v3): time, thin dot
 * separator, then date. Time is mono (numbers shouldn't shift width),
 * date is sans. Ticks every 1 s.
 */

import QtQuick
import qs.services

Row {
    id: clock
    spacing: 6

    property var _now: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: clock._now = new Date()
    }

    Text {
        text: Qt.formatTime(clock._now, "HH:mm")
        color: Tokens.ink1
        font.family: Tokens.ffMono
        font.pixelSize: Tokens.tBar
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: "·"
        color: Tokens.ink5
        font.pixelSize: Tokens.tBar
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Qt.formatDate(clock._now, "ddd d MMM")
        color: Tokens.ink3
        font.family: Tokens.ffSans
        font.pixelSize: Tokens.tLabel
        anchors.verticalCenter: parent.verticalCenter
    }
}
