/*
 * Media — MPRIS via playerctl.
 *
 * We could use Quickshell.Services.Mpris directly, but playerctl gives us
 * a single uniform CLI across players (spotify, browser, mpv, ncspot) and
 * keeps the QML free of Mpris-specific glue. Trade-off: a 1 s poll instead
 * of dbus signals — fine for a bar widget.
 *
 * Format spec passed to `playerctl metadata --format`:
 *   title|artist|status|position|length|arturl
 * Tab/newline-safe because we use a single-line `|` delimited shape.
 */

pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: media

    property bool   active:  false
    property string title:   ""
    property string artist:  ""
    property string status:  "Stopped"   // Playing | Paused | Stopped
    property string artUrl:  ""
    property real   position: 0          // seconds
    property real   length:   1          // seconds (1 to avoid div-by-zero)
    readonly property real progress: length > 0 ? position / length : 0
    readonly property bool playing:  status === "Playing"

    function init() { _poll.running = true; _read.running = true; }

    function playPause() { _action(["playerctl", "play-pause"]); }
    function next()      { _action(["playerctl", "next"]);       }
    function previous()  { _action(["playerctl", "previous"]);   }

    // ── Internals ───────────────────────────────────────────────────────
    property Process _writer: Process { }
    function _action(cmd) { _writer.command = cmd; _writer.running = true; }

    property Timer _poll: Timer {
        interval: 1000
        repeat: true
        onTriggered: media._read.running = true
    }

    // Microseconds → seconds for position/length (MPRIS reports µs).
    readonly property string _fmt:
        "{{title}}|{{artist}}|{{status}}|{{position}}|{{mpris:length}}|{{mpris:artUrl}}"

    property Process _read: Process {
        command: ["playerctl", "metadata", "--format", media._fmt]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                if (!t || t.indexOf("No players found") !== -1) {
                    media.active = false;
                    media.status = "Stopped";
                    return;
                }
                const parts = t.split("|");
                media.active  = true;
                media.title   = parts[0] || "";
                media.artist  = parts[1] || "";
                media.status  = parts[2] || "Stopped";
                media.position = (parseInt(parts[3]) || 0) / 1000000;
                media.length   = Math.max(1, (parseInt(parts[4]) || 0) / 1000000);
                media.artUrl  = parts[5] || "";
            }
        }
    }
}
