/*
 * Brightness — screen + keyboard backlight via brightnessctl.
 *
 * brightnessctl outputs `current,max` with `-m` (machine-readable).
 * We poll every 2 s as a cheap fallback in case something else (the
 * laptop's Fn keys, mostly) mutates brightness behind our back —
 * brightnessctl itself doesn't emit events. Writes go straight through.
 *
 * Exposes:
 *   screen      0..100 (rounded percent)
 *   keyboard    0..100
 *   kbdSteps    integer step (Framework 13: 0..3) for the qs panel dots
 */

pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: brightness

    property int screen: 50
    property int keyboard: 0
    // Framework 13 keyboard backlight has 4 levels (0..3). Expose discrete
    // step count alongside the percent so the qs panel dots map cleanly.
    property int kbdSteps: 0
    readonly property int kbdMaxSteps: 3

    function init() {
        _readScreen.running = true;
        _readKbd.running = true;
        _poll.running = true;
    }

    function setScreen(pct) {
        screen = Math.max(0, Math.min(100, Math.round(pct)));
        _writer.command = ["brightnessctl", "-q", "s", screen + "%"];
        _writer.running = true;
    }

    function setKeyboard(pct) {
        keyboard = Math.max(0, Math.min(100, Math.round(pct)));
        // Map 0..100 → 0..kbdMaxSteps for the EC's discrete levels.
        kbdSteps = Math.round((keyboard / 100) * kbdMaxSteps);
        _writer.command = ["brightnessctl", "-d", "framework_laptop::kbd_backlight",
                           "-q", "s", keyboard + "%"];
        _writer.running = true;
    }

    // Cycle kbd: 0 → 1 → 2 → 3 → 0 (bound to Fn key in niri config).
    function cycleKeyboard() {
        const next = (kbdSteps + 1) % (kbdMaxSteps + 1);
        setKeyboard(Math.round((next / kbdMaxSteps) * 100));
    }

    // ── Internals ───────────────────────────────────────────────────────
    property Process _writer: Process { }

    property Timer _poll: Timer {
        interval: 2000
        repeat: true
        onTriggered: { brightness._readScreen.running = true;
                       brightness._readKbd.running    = true; }
    }

    property Process _readScreen: Process {
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                // CSV: name,class,current,percent,max
                const parts = this.text.trim().split(",");
                if (parts.length >= 4) {
                    const pct = parseInt(parts[3]);
                    if (!isNaN(pct)) brightness.screen = pct;
                }
            }
        }
    }

    property Process _readKbd: Process {
        command: ["brightnessctl", "-d", "framework_laptop::kbd_backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",");
                if (parts.length >= 5) {
                    const cur = parseInt(parts[2]);
                    const max = parseInt(parts[4]);
                    if (!isNaN(cur) && !isNaN(max) && max > 0) {
                        brightness.keyboard = Math.round((cur / max) * 100);
                        brightness.kbdSteps = cur;          // EC reports raw step
                    }
                }
            }
        }
    }
}
