/*
 * Volume — PipeWire/WirePlumber audio via wpctl.
 *
 *   wpctl get-volume @DEFAULT_AUDIO_SINK@   → "Volume: 0.62"  (or "0.62 [MUTED]")
 *   wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.62
 *   wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle
 *
 * Polled every 800 ms — pw doesn't emit cheap CLI events. Set-then-read
 * isn't quite atomic but the eventual-consistency feel is fine for a UI
 * slider (volumes settle in well under a poll interval).
 */

pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: volume

    property int  level: 60    // 0..100
    property bool muted: false

    function init() {
        _read.running = true;
        _poll.running = true;
    }

    function set(pct) {
        level = Math.max(0, Math.min(150, Math.round(pct))); // wpctl caps at 1.5
        _writer.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                           (level / 100).toFixed(2)];
        _writer.running = true;
    }

    function toggleMute() {
        muted = !muted;
        _writer.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
        _writer.running = true;
    }

    // ── Internals ───────────────────────────────────────────────────────
    property Process _writer: Process { }

    property Timer _poll: Timer {
        interval: 800
        repeat: true
        onTriggered: volume._read.running = true
    }

    property Process _read: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                // "Volume: 0.62" or "Volume: 0.62 [MUTED]"
                const m = t.match(/Volume:\s*([0-9.]+)(\s*\[MUTED\])?/);
                if (m) {
                    volume.level = Math.round(parseFloat(m[1]) * 100);
                    volume.muted = m[2] !== undefined;
                }
            }
        }
    }
}
