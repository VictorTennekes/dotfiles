/*
 * shell.qml — Quickshell entry point (host: r2d2, Framework 13 / niri).
 *
 * The whole shell is composed from three sibling modules:
 *   services/  singletons exposing reactive system state (Tokens, Niri, …)
 *   widgets/   leaf UI pieces (Workspaces, Clock, MediaPill, StatusItems)
 *   components/ assembled overlays (Bar, QuickSettings, Toast)
 *
 * Layout north-star: /data/Downloads/Arch setup(2)/Niri Desktop v3.html.
 * Theme tokens come from services/Tokens.qml (Catppuccin Mocha default);
 * the theme-switch script repoints the active theme by mutating
 * Tokens.themeName / Tokens.accentName at runtime.
 */

//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.components
import qs.services

ShellRoot {
    id: root

    // Boot services that need explicit init (poll loops, IPC subscribers).
    // Tokens is purely declarative state, no init required.
    Component.onCompleted: {
        Niri.init();
        Brightness.init();
        Volume.init();
        Battery.init();
        Network.init();
        Media.init();
    }

    // ── Top bar — one instance per connected screen ─────────────────────
    Variants {
        model: Quickshell.screens
        Bar { screen: modelData }
    }

    // ── Singleton overlays (visible on focused screen only) ─────────────
    // QuickSettings is the popout below the bar's right edge; toggled by
    // a niri keybind that runs `qs ipc call quickSettings toggle`.
    QuickSettings { id: quickSettings }

    // Toast is a layer-shell notification surface (mako delivers via dbus).
    Toast { id: toast }
}
