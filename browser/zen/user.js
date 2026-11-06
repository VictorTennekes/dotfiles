// Zen: performance and battery. scripts/install links this into each
// profile; applied at every startup, so about:config changes to these revert.

// YouTube prefers AV1, which the M1 Pro can only decode in software. Without
// it YouTube serves VP9: same resolutions, hardware-decoded on both machines.
user_pref("media.av1.enabled", false);

// Up to 2 content processes per site instead of 4: less RAM.
user_pref("dom.ipc.processCount.webIsolated", 2);

// No translucent window: macOS otherwise keeps compositing what's behind it.
// (macOS-only pref; ignored on Linux.)
user_pref("zen.widget.macos.window-vibrancy", false);

// Fewer animations
user_pref("zen.view.compact.animate-sidebar", false);
user_pref("zen.glance.enabled", false);

// userChrome.css / userContent.css in the profile's chrome/ dir, and the
// Browser Toolbox to inspect the UI while writing them.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("devtools.chrome.enabled", true);
