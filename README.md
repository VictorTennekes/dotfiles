# Dotfiles

Personal configuration for macOS and Arch Linux (Hyprland), managed with Make
and GNU Stow. XDG Base Directory compliant throughout.

---

## What's Inside

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for
  plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) on macOS
  (`packages/Brewfile`); pacman + [paru](https://github.com/Morganamilo/paru)
  on Arch (`packages/arch.txt`, `packages/aur.txt`).
- **Terminal:** [Ghostty](https://ghostty.org/) on macOS,
  [foot](https://codeberg.org/dnkl/foot) on Linux. Catppuccin Mocha.
- **Desktop (Linux):** Hyprland (Lua config), Waybar, swaync, swayosd,
  fuzzel, hyprlock/hypridle, swaybg, SDDM.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs, commit
  signing with a per-machine SSH key.
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `btop`, `yazi`, `k9s`, `fastfetch`.

---

## Installation

### Prerequisites

- **macOS:** Git and Command Line Tools (`xcode-select --install`)
- **Arch:** a booted install with `git`, `sudo` and network access. The disk
  and boot setup is manual, see [Arch boot checklist](#arch-boot-checklist).

### Steps

```bash
git clone https://github.com/victortennekes/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

Work-only packages (dbt, terraform, k9s, Slack, …) are gated by a marker
file, `~/.work-laptop` (macOS). Create it once on the work machine:
`touch ~/.work-laptop`.

---

## Usage

| Command        | Description                                        |
|----------------|----------------------------------------------------|
| `make install` | Guided setup: packages, links, keys, remote access |
| `make doctor`  | Same checks as install, report only                |
| `make update`  | Pull dotfiles, update packages, re-link configs    |
| `make dump`    | Brewfile export (macOS); unlisted packages (Arch)  |
| `make lint`    | Validate zsh, JSON, Lua and scripts                |
| `make clean`   | Remove all stow symlinks                           |

---

## Repository Structure

```txt
.dotfiles/
├── packages/
│   ├── Brewfile      # macOS: brew, casks, mas
│   ├── arch.txt      # Arch: official repos
│   └── aur.txt       # Arch: AUR (paru)
├── config/           # Shared app configs → ~/.config/ (both OSes)
│   ├── bat/  btop/  fastfetch/  git/  k9s/  mise/
│   ├── nvim/  tmux/  yazi/  zsh/
├── config-macos/     # macOS-only → ~/.config/
│   ├── ghostty/  swiftbar/
├── config-linux/     # Linux-only → ~/.config/
│   ├── hypr/  waybar/  swaync/  swayosd/  fuzzel/  foot/
├── system-linux/     # /etc files installed by setup on Arch
├── home/             # Home-level dotfiles → ~/
│   └── .zshenv
├── scripts/
│   ├── setup         # Guided install / --check doctor (macOS + Arch)
│   ├── install       # Symlink config/ + config-<os>/ via stow
│   ├── clean         # Remove stow symlinks
│   └── macos-defaults # Apply macOS system defaults
└── Makefile
```

Shared configs are one version for both systems: where they differ, they
check what's installed (`pbcopy` vs `wl-copy`, Homebrew vs a git clone of
antidote) instead of keeping per-OS copies. `up` is the one function that
branches on the OS (brew vs paru).

---

## Notes

- **Clipboard.** The `clip` zsh function uses `pbcopy` (macOS) or `wl-copy`
  (Wayland), or OSC 52 over SSH so copies land on the local terminal.
- **Git key.** One plain `~/.ssh/id_ed25519` per machine for auth and
  signing; it keeps working with the screen locked, so T3 Code and phone
  sessions can push while you're away. Per-machine git settings (signing
  key, gh credential helper) live in `~/.gitconfig.local`, written by setup.
- **Keyboard remapping.** Caps Lock → Escape via `kb_options` in Hyprland
  on Linux; none on macOS.
- **macOS defaults.** Run `scripts/macos-defaults` after first install to
  apply sensible system preferences.
- **Wallpapers (Linux)** aren't in the repo. swaybg and hyprlock both use
  `~/Pictures/Wallpapers/current`, a symlink to the chosen image.

---

## Arch boot checklist

Disk and boot are machine-specific and a mistake can leave the machine
unbootable, so `make install` doesn't touch them. The Framework 13 layout:

- **Disk:** LUKS2 on `nvme0n1p2`, one btrfs inside with subvolumes `@arch`
  (`/`) and `@arch-home` (`/home`). ESP on `nvme0n1p1`, mounted at `/efi`.
- **Kernel + initramfs** go straight to `/efi/arch` (not a `/boot` bind
  mount, which breaks fwupd's ESP detection). In
  `/etc/mkinitcpio.d/linux.preset`: `ALL_kver="/efi/arch/vmlinuz-linux"`,
  `default_image` and `rescue_image` under `/efi/arch`, and
  `PRESETS=('default' 'rescue')`.
- **Initramfs hooks** in `/etc/mkinitcpio.conf` (a rescue copy with the
  busybox `encrypt` hook lives in `/etc/mkinitcpio-rescue.conf`):

  ```txt
  base systemd autodetect microcode modconf kms keyboard sd-vconsole
  block sd-encrypt filesystems
  ```

- **Limine** (`/efi/limine.conf`): an "Arch" entry with this kernel
  command line (one line in the file), plus an "Arch (rescue)" entry using
  the rescue initramfs with `cryptdevice=PARTUUID=<partuuid>:root`:

  ```txt
  rd.luks.name=<luks-uuid>=root rd.luks.options=tpm2-device=auto,discard
  root=/dev/mapper/root rootflags=subvol=@arch rootfstype=btrfs rw
  rtc_cmos.use_acpi_alarm=1 quiet loglevel=3
  ```

- **TPM unlock:**

  ```sh
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
  ```

  A BIOS update changes PCR 7: once booted with the passphrase, re-run it
  with `--wipe-slot=tpm2`, and check it before rebooting with
  `sudo cryptsetup open --test-passphrase --token-only /dev/nvme0n1p2`.
- **fwupd:** `sudo fwupdmgr modify-config fwupd EspLocation /efi`.
