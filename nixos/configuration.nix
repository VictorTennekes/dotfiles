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
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "just-perfection-desktop@just-perfection"
        "caffeine@patapon.info"
      ];
    };
  }];

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
