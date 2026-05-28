/*
 * Tokens — single source of truth for palette / geometry / type.
 *
 * Ported from the v3 HTML mockup's :root CSS variables. Every component
 * reads from this singleton, so a theme switch is just mutating
 * `themeName` (palette) or `accentName` (accent hue). Geometry and type
 * are intentionally fixed — the rice's identity is structure + spacing;
 * only colors swap between themes.
 *
 * The theme-switch shell script writes to /tmp/quickshell-theme.json and
 * a FileView in this singleton (added later) will reload on change —
 * for now the defaults below are sufficient and switching can be done
 * by editing this file in place.
 */

pragma Singleton

import QtQuick

QtObject {
    id: tokens

    // ── Theme selection (drives palette resolution) ─────────────────────
    property string themeName:  "mocha"     // "mocha" | "latte" | "tokyonight" | "gruvbox"
    property string accentName: "blue"      // "blue" | "green" | "purple" | "red" | "peach" | "teal"

    // ── Catppuccin Mocha (default) ──────────────────────────────────────
    readonly property color base:      "#1e1e2e"
    readonly property color mantle:    "#181825"
    readonly property color crust:     "#11111b"
    readonly property color surface0:  "#313244"
    readonly property color surface1:  "#45475a"
    readonly property color surface2:  "#585b70"
    readonly property color overlay0:  "#6c7086"
    readonly property color overlay1:  "#7f849c"
    readonly property color overlay2:  "#9399b2"
    readonly property color text:      "#cdd6f4"
    readonly property color subtext1:  "#bac2de"
    readonly property color subtext0:  "#a6adc8"
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo:  "#f2cdcd"
    readonly property color pink:      "#f5c2e7"
    readonly property color mauve:     "#cba6f7"
    readonly property color red:       "#f38ba8"
    readonly property color maroon:    "#eba0ac"
    readonly property color peach:     "#fab387"
    readonly property color yellow:    "#f9e2af"
    readonly property color green:     "#a6e3a1"
    readonly property color teal:      "#94e2d5"
    readonly property color sky:       "#89dceb"
    readonly property color sapphire:  "#74c7ec"
    readonly property color blue:      "#89b4fa"
    readonly property color lavender:  "#b4befe"

    // ── Semantic ink (text levels) ──────────────────────────────────────
    readonly property color ink1: text
    readonly property color ink2: subtext1
    readonly property color ink3: subtext0
    readonly property color ink4: overlay1
    readonly property color ink5: overlay0

    // ── Accent (single, resolved from accentName) ───────────────────────
    readonly property color accent: {
        switch (accentName) {
            case "green":  return green;
            case "purple": return mauve;
            case "red":    return red;
            case "peach":  return peach;
            case "teal":   return teal;
            default:       return blue;
        }
    }
    // Derived accent shades — alpha-mixed with the base text color to match
    // the mockup's `color-mix(in oklab, accent X%, transparent)` outputs.
    readonly property color accentSoft: Qt.rgba(accent.r, accent.g, accent.b, 0.18)
    readonly property color accentRing: Qt.rgba(accent.r, accent.g, accent.b, 0.42)
    readonly property color accentGlow: Qt.rgba(accent.r, accent.g, accent.b, 0.30)

    // ── Borders (translucent overlays of text color) ────────────────────
    readonly property color border1: Qt.rgba(text.r, text.g, text.b, 0.06)
    readonly property color border2: Qt.rgba(text.r, text.g, text.b, 0.11)
    readonly property color border3: Qt.rgba(text.r, text.g, text.b, 0.18)

    // ── Surface opacity (drives the floating-bar / popout translucency) ─
    property int opacityPct: 78
    readonly property real winAlpha: opacityPct / 100.0
    readonly property color surface:      Qt.rgba(surface0.r, surface0.g, surface0.b, winAlpha)
    readonly property color surfaceAlt:   Qt.rgba(surface1.r, surface1.g, surface1.b, winAlpha)
    readonly property color surfaceQuiet: Qt.rgba(mantle.r,   mantle.g,   mantle.b,   0.86)

    // ── Type ────────────────────────────────────────────────────────────
    readonly property string ffSans: "Inter"
    readonly property string ffMono: "JetBrains Mono"
    readonly property int  tBar:   13
    readonly property int  tUi:    14     // 13.5 in CSS — Qt int point sizing
    readonly property int  tMono:  13     // 12.5
    readonly property int  tLabel: 12     // 11.5

    // ── Geometry (density "regular" from the mockup) ────────────────────
    readonly property int barHeight: 30
    readonly property int gap:       14
    readonly property int pad:       16
    readonly property int colPad:    14
    readonly property int topPad:    24
    readonly property int bottomPad: 22

    // ── Radii ───────────────────────────────────────────────────────────
    readonly property int radiusXs: 4
    readonly property int radiusSm: 6
    readonly property int radius:   10
    readonly property int radiusLg: 14
    readonly property int radiusPill: 999

    // ── Depth ───────────────────────────────────────────────────────────
    readonly property int blurRadius: 20      // for QtMultiEffect on popouts
    readonly property real shadowOpacity: 0.55

    // ── Motion ──────────────────────────────────────────────────────────
    readonly property int   transFast:  120
    readonly property int   transMed:   180
    readonly property int   transSlow:  260
    // Qt easing — Easing.OutCubic matches the mockup's cubic-bezier feel.
    readonly property int   ease: Easing.OutCubic
}
