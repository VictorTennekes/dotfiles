/*
 * Network — NetworkManager state via nmcli.
 *
 *   nmcli -t -g STATE,CONNECTIVITY general
 *     → "connected:full" | "disconnected:none" | "connecting:limited" | …
 *   nmcli -t -g NAME,TYPE connection show --active
 *     → "Wired connection 1:802-3-ethernet\nVUMC-iot:802-11-wireless"
 *
 * Poll every 5 s. nmcli has a `monitor` mode but its output is awkward
 * to parse; a simple poll is plenty for an icon + status badge.
 */

pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: network

    property string state: "unknown"         // connected | disconnected | connecting
    property string connectivity: "unknown"  // full | limited | portal | none
    property string activeName: ""           // primary active connection name (for tooltip)
    property string activeType: ""           // wifi | ethernet | … (derived from nmcli type)

    readonly property bool online: state === "connected" && connectivity === "full"
    readonly property bool isWifi: activeType === "wifi"

    function init() {
        _readGeneral.running = true;
        _readActive.running  = true;
        _poll.running = true;
    }

    property Timer _poll: Timer {
        interval: 5000
        repeat: true
        onTriggered: { network._readGeneral.running = true;
                       network._readActive.running  = true; }
    }

    property Process _readGeneral: Process {
        command: ["nmcli", "-t", "-g", "STATE,CONNECTIVITY", "general"]
        stdout: StdioCollector {
            onStreamFinished: {
                // multi-line: "connected\nfull" (terse mode separates with newlines)
                const lines = this.text.trim().split("\n");
                if (lines.length >= 1) network.state        = lines[0];
                if (lines.length >= 2) network.connectivity = lines[1];
            }
        }
    }

    property Process _readActive: Process {
        command: ["nmcli", "-t", "-g", "NAME,TYPE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: {
                // pick the first non-loopback active connection
                const lines = this.text.trim().split("\n").filter(l => l && !l.startsWith("lo:"));
                if (lines.length === 0) {
                    network.activeName = "";
                    network.activeType = "";
                    return;
                }
                const [name, type] = lines[0].split(":");
                network.activeName = name || "";
                // nmcli types: 802-11-wireless, 802-3-ethernet → friendlier label
                network.activeType =
                    type && type.indexOf("wireless") !== -1 ? "wifi" :
                    type && type.indexOf("ethernet") !== -1 ? "ethernet" : (type || "");
            }
        }
    }
}
