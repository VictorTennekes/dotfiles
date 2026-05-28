/*
 * Niri — IPC bridge to the niri compositor.
 *
 * Architecture: a single long-running `niri msg event-stream` Process
 * feeds a line-split parser (no polling). On init we also fire two
 * one-shot seeds so widgets render correct state immediately, before
 * the first event arrives.
 *
 * Exposes:
 *   workspaces          [{ id, idx, name, output, is_active, … }]
 *   focusedWorkspaceId  number
 *   focusedWindow       { id, app_id, title } | null
 *
 * Actions (fire-and-forget shell-outs):
 *   focusWorkspace(id)
 *   focusColumn(left|right)
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: niri

    // ── Public reactive state ───────────────────────────────────────────
    property var workspaces: []
    property int focusedWorkspaceId: -1
    property var focusedWindow: null

    function init() {
        _seedWorkspaces.running = true;
        _seedFocused.running    = true;
        _eventStream.running    = true;
    }

    // ── One-shot action dispatcher (used by focus* helpers) ─────────────
    // A single reusable Process — we mutate command + retoggle `running`.
    // Detached-style; we don't read stdout for actions.
    property Process _action: Process { }
    function _exec(args) {
        _action.command = args;
        _action.running = true;
    }

    function focusWorkspace(id) {
        _exec(["niri", "msg", "action", "focus-workspace", id.toString()]);
    }
    function focusColumnLeft()  { _exec(["niri", "msg", "action", "focus-column-left"]);  }
    function focusColumnRight() { _exec(["niri", "msg", "action", "focus-column-right"]); }

    // ── Seeds ───────────────────────────────────────────────────────────
    property Process _seedWorkspaces: Process {
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(this.text);
                    niri.workspaces = list;
                    const active = list.find(w => w.is_active);
                    if (active) niri.focusedWorkspaceId = active.id;
                } catch (e) {
                    console.warn("Niri: workspaces seed parse failed:", e);
                }
            }
        }
    }

    property Process _seedFocused: Process {
        command: ["niri", "msg", "--json", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { niri.focusedWindow = JSON.parse(this.text); }
                catch (e) { niri.focusedWindow = null; }
            }
        }
    }

    // ── Long-running event stream ───────────────────────────────────────
    // niri emits one JSON tagged object per line:
    //   {"WorkspacesChanged":{...}} | {"WorkspaceActivated":{...}}
    //   {"WindowFocusChanged":{...}} | {"WindowOpenedOrChanged":{...}}
    //   {"WindowClosed":{...}} | …
    property Process _eventStream: Process {
        command: ["niri", "msg", "event-stream"]
        stdout: SplitParser {
            onRead: line => niri._handleEvent(line)
        }
    }

    function _handleEvent(line) {
        if (!line) return;
        let ev;
        try { ev = JSON.parse(line); } catch (_) { return; }

        if (ev.WorkspacesChanged) {
            workspaces = ev.WorkspacesChanged.workspaces;
            const active = workspaces.find(w => w.is_active);
            if (active) focusedWorkspaceId = active.id;
        }
        else if (ev.WorkspaceActivated) {
            focusedWorkspaceId = ev.WorkspaceActivated.id;
            // Reflect the activation locally so the bar lights up before
            // the next WorkspacesChanged frame arrives.
            workspaces = workspaces.map(w =>
                Object.assign({}, w, { is_active: w.id === focusedWorkspaceId })
            );
        }
        else if (ev.WindowFocusChanged) {
            if (ev.WindowFocusChanged.id == null) focusedWindow = null;
            else _refreshFocused.running = true;
        }
        else if (ev.WindowOpenedOrChanged || ev.WindowsChanged) {
            _refreshFocused.running = true;
        }
        else if (ev.WindowClosed) {
            if (focusedWindow && focusedWindow.id === ev.WindowClosed.id)
                focusedWindow = null;
        }
    }

    property Process _refreshFocused: Process {
        command: ["niri", "msg", "--json", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { niri.focusedWindow = JSON.parse(this.text); }
                catch (_) { niri.focusedWindow = null; }
            }
        }
    }
}
