# System packages for r2d2 — translated from packages/Brewfile + packages/arch.
#
# Philosophy: NixOS installs *packages* declaratively here; your *dotfiles*
# stay plain files managed by GNU Stow (config/), identical to macOS/Arch — so
# nothing here knows about nvim/zsh/ghostty configs. Languages (node/python/go)
# stay on mise, exactly as elsewhere.
#
# A few tools are intentionally left to the post-install bootstrap (curl/npm),
# mirroring the Arch SHELL_INSTALLERS/NPM_PACKAGES — see the bottom comment.
{ pkgs, lib, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ── Core CLI ──────────────────────────────────────────────────────────────
    bat
    eza
    fd
    delta # git-delta
    fzf
    jq
    gh
    glab
    git
    git-machete
    ripgrep
    stow
    gnumake # `make install` / `make update` from the dotfiles Makefile
    tealdeer # tldr
    vivid
    hyperfine
    fastfetch
    inputs.areofyl-fetch.packages.${pkgs.stdenv.hostPlatform.system}.default # `fetch` — 3D spinning logo + live sysinfo, pairs with fastfetch
    mise
    starship
    zoxide
    btop
    lazygit
    yazi
    neovim
    tree-sitter
    repomix

    # ── Terminal ────────────────────────────────────────────────────────────────
    ghostty

    # ── Editors ─────────────────────────────────────────────────────────────────
    zed-editor

    # ── AI / local inference ────────────────────────────────────────────────────
    # NOTE: gfx1152 has a known ROCm GPU-hang bug. Plain `ollama` (CPU) is safe;
    # switch to `ollama-rocm` only once that lands a fix for Krackan Point.
    ollama
    claude-code
    gemini-cli # `gemini` — was `npm i -g @google/gemini-cli` on Arch
    opencode

    # ── Desktop apps ──────────────────────────────────────────────────────────
    firefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # Zen (stable), via flake
    bitwarden-desktop
    bitwarden-cli # `bw` — SSH agent + secrets; was `npm i -g @bitwarden/cli` on Arch
    obsidian
    signal-desktop
    spotify

    # ── GNOME tweaking + Shell extensions (enabled in configuration.nix dconf) ──
    gnome-tweaks
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.caffeine

    # ── Audio / hardware utils (from the Arch niri stack worth keeping) ─────────
    pavucontrol
    wl-clipboard
    brightnessctl
    smartmontools
    pciutils
    usbutils

    # ── Misc base ───────────────────────────────────────────────────────────────
    wget
    curl
    unzip
    file
    tree
  ];

  # ── Nixpkgs policy ──────────────────────────────────────────────────────────
  # Unfree is opt-in per package rather than a blanket allowUnfree — a surprise
  # unfree pull fails loud instead of sliding in. `nixos-rebuild` prints the exact
  # name to add on refusal. Keep this list in sync with the packages above.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
    "spotify"
    "claude-code"
    # programs.steam fans out into several unfree derivations.
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
  # Pulled in by an Electron desktop app (obsidian/signal); EOL upstream.
  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  # ── Post-install / not-from-nixpkgs (do these after first boot) ─────────────
  # Bits that have no clean nixpkgs equivalent or want their vendor installer:
  #   • antidote        → git clone (zsh plugin manager; your .zshrc bootstraps it)
  #   • framework_tool  → cargo install --git FrameworkComputer/framework-system
  #   • nordvpn         → nixpkgs `nordvpn` is unfree; verify + add if wanted
  #   • proton-ge       → via ProtonUp / programs.steam protontricks
  #
  # Node/Python via mise need prebuilt binaries to run → enabled by nix-ld in
  # configuration.nix; mise is set to prebuilt (compile=false) in config/mise.
}
