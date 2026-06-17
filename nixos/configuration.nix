{ config, lib, pkgs, ... }:

{
  imports = [ ./packages.nix ];

  # ── Boot ──────────────────────────────────────────────────────────────────
  # Single OS + roomy ESP → systemd-boot (no rEFInd/GRUB chainloading needed).
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # keep last 5 generations in the menu
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # default is 5s — shave ~4s off the loader phase (hold a key to pause the menu)

  # Bleeding-edge Zen5 (Krackan Point) — ride the newest kernel. The hardware
  # module already bumps the kernel when < 6.15 (its suspend floor); force the
  # very latest here regardless.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  # Hibernate: disko marks the 36G swap partition resumeDevice=true, which sets
  # boot.resumeDevice. Swap is its own partition (not a btrfs CoW swapfile), so
  # resume-from-disk works without the usual btrfs swapfile gymnastics.

  # ── Networking / locale / time ──────────────────────────────────────────────
  networking.hostName = "r2d2";
  networking.networkmanager.enable = true;

  # mt7925e Wi-Fi (Framework 13 AMD): on a cold boot the first WPA 4-way
  # handshake times out (deauth Reason 15) and NetworkManager only reconnects
  # after a ~15s backoff — so Wi-Fi looks like it doesn't autoconnect. Disabling
  # PCIe ASPM on the card resolves the handshake race.
  boot.extraModprobeConfig = ''
    options mt7925e disable_aspm=1
  '';

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  # Default builds every glibc locale (~220MB). We only need en_US (+ C);
  # add e.g. "nl_NL.UTF-8/UTF-8" here if you want Dutch formats.
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];
  console.keyMap = "us";

  # ── Desktop: GNOME on Wayland (closest to the macOS feel) ───────────────────
  services.xserver.enable = true; # provides Xwayland for X11 apps
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";

  # GNOME Shell extensions — packages live in packages.nix; this flips them on in
  # the default dconf profile (a default, not a lock, so the GNOME Extensions app
  # and gnome-tweaks can still toggle/configure them and changes persist per-user).
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "blur-my-shell@aunetx"
          "just-perfection-desktop@just-perfection"
          "caffeine@patapon.info"
          "rounded-window-corners@fxgn"
          "dash-to-dock@micxgx.gmail.com"
        ];
      };
      # Dock on the left, floating + centered (not full-height), auto-hide; click
      # a running app to minimize/preview. Restores minimized windows.
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "LEFT";
        extend-height = false;
        dock-fixed = false;
        autohide = true;
        intellihide = false; # always hidden until you hover the edge (macOS-style)
        transparency-mode = "DYNAMIC";
        running-indicator-style = "DOTS";
        click-action = "minimize-or-previews";
        show-apps-at-top = false;
        show-mounts = false;
      };
      # macOS feel: Super+Q closes the focused window (≈ Cmd+Q). Super+Tab
      # (switch apps) and tap-Super (launcher/search) are already GNOME defaults.
      "org/gnome/desktop/wm/keybindings".close = [ "<Super>q" ];
      # Traffic-light window buttons on the left, like macOS.
      "org/gnome/desktop/wm/preferences".button-layout = "close,minimize,maximize:";
      # Inter (already in fonts.packages) ≈ SF Pro for UI/document text, plus
      # GNOME's built-in accent color. Monospace stays the default (JetBrains).
      "org/gnome/desktop/interface" = {
        font-name = "Inter 11";
        document-font-name = "Inter 11";
        accent-color = "blue";
      };
      # Snappier shell animations via Just Perfection (1 default, 2 fast,
      # 3 faster, 4 fastest). mkInt32 — the key is a GVariant 'i'.
      "org/gnome/shell/extensions/just-perfection".animation = lib.gvariant.mkInt32 2;
    };
  }];

  # Trim GNOME: drop default apps redundant with our real ones (browser = Zen/FF,
  # editor = nvim/Zed, terminal = Ghostty, …), plus the screen-reader/TTS stack
  # (orca → speech-dispatcher), which alone drags in ~645MB of mbrola voices.
  # Kept: loupe (image viewer) + seahorse (keyring GUI).
  environment.gnome.excludePackages = with pkgs; [
    orca
    speechd
    epiphany gnome-tour yelp simple-scan snapshot baobab
    gnome-maps gnome-weather gnome-contacts gnome-music gnome-calendar
    gnome-clocks gnome-characters gnome-logs gnome-connections
    gnome-font-viewer gnome-text-editor
  ];

  # Default browser = Zen (Firefox is gone). System-level default; a per-user
  # ~/.config/mimeapps.list still wins over this, so set both on existing hosts.
  xdg.mime.defaultApplications = {
    "text/html" = "zen-beta.desktop";
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
    "x-scheme-handler/about" = "zen-beta.desktop";
    "x-scheme-handler/unknown" = "zen-beta.desktop";
  };

  # Default terminal for `Terminal=true` apps (btop, etc.). GNOME launches them
  # via xdg-terminal-exec, which reads this list — without it, it grabs GNOME
  # Console. (User ~/.config/xdg-terminals.list overrides this if present.)
  environment.etc."xdg/xdg-terminals.list".text = "com.mitchellh.ghostty.desktop\n";

  # No screen reader / TTS here → keep speech-dispatcher (and its ~645MB mbrola
  # voices) out of the closure.
  services.speechd.enable = false;

  # AMD Framework: power-profiles-daemon, NOT tlp (per nixos-hardware guidance).
  services.power-profiles-daemon.enable = true;

  # Fingerprint reader (goodix) — not wired by the hardware module.
  services.fprintd.enable = true;

  # Firmware updates (also enabled by the hw module; explicit is fine).
  services.fwupd.enable = true;

  # Bluetooth.
  hardware.bluetooth.enable = true;

  # Framework 13 AMD trackpad: slow two-finger scroll (ported from the old
  # system/etc/libinput/local-overrides.quirks). Lower AttrScrollPixelDistance is
  # faster; 25 is a moderate slowdown from libinput's default of 15.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [FrameworkAMDTouchpadScrollSpeed]
    MatchUdevType=touchpad
    MatchDMIModalias=dmi:*svnFramework:*pnLaptop?13*Ryzen?AI?300*
    AttrScrollPixelDistance=25
  '';

  # ── Audio: PipeWire (matches the Arch stack) ────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Containers ──────────────────────────────────────────────────────────────
  virtualisation.docker.enable = true;

  # nix-ld: a real dynamic linker so prebuilt foreign binaries run (default
  # NixOS only ships a stub). Lets mise fetch prebuilt node/python (compile=false
  # in config/mise) instead of building from source, which needs a toolchain
  # we don't ship. Static binaries like Go already work without this.
  programs.nix-ld.enable = true;

  # ── Gaming (Steam + Proton, mirrors the Arch GAMING_PACKAGES) ───────────────
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode = {
    enable = true;
    # Ported from the old system/etc/gamemode.ini: with amd-pstate-epp the only
    # governors are performance/powersave; powersave keeps the fans calm without
    # hurting light games. (gamemode also nudges power-profiles-daemon.)
    settings.general.desiredgov = "powersave";
  };

  # ── Shell + user ────────────────────────────────────────────────────────────
  programs.zsh.enable = true; # login shell; the actual config is stowed (config/zsh)
  users.users.victortennekes = {
    isNormalUser = true;
    description = "Victor Tennekes";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # ── Fonts (Nerd Font + Inter, from the Arch manifest) ───────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
  ];

  # ── Nix daemon ──────────────────────────────────────────────────────────────
  # nixpkgs.config (unfree/insecure allowlists) lives in packages.nix, next to
  # the packages those permits exist for.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Set to the release you install from; check `nixos-version`. Do NOT bump on
  # upgrades — it pins stateful-data defaults.
  system.stateVersion = "26.05";
}
