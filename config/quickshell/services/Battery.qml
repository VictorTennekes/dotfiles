/*
 * Battery — sysfs reader for r2d2 (Framework 13 → BAT1).
 *
 * Reads /sys/class/power_supply/BAT1/{capacity,status}. The status string
 * is one of Charging / Discharging / Full / Not charging / Unknown.
 * Poll every 10 s — battery percentage doesn't move faster than that and
 * we don't want to wake the CPU more than necessary on a battery widget.
 */

pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: battery

    property int    capacity: 100
    property string status: "Unknown"
    readonly property bool charging: status === "Charging"
    readonly property bool full:     status === "Full"

    function init() {
        _readCapacity.running = true;
        _readStatus.running   = true;
        _poll.running = true;
    }

    property Timer _poll: Timer {
        interval: 10000
        repeat: true
        onTriggered: { battery._readCapacity.running = true;
                       battery._readStatus.running   = true; }
    }

    property Process _readCapacity: Process {
        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(this.text.trim());
                if (!isNaN(n)) battery.capacity = n;
            }
        }
    }

    property Process _readStatus: Process {
        command: ["cat", "/sys/class/power_supply/BAT1/status"]
        stdout: StdioCollector {
            onStreamFinished: battery.status = this.text.trim()
        }
    }
}
