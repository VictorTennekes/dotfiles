# Dotfiles

Personal configuration for macOS and Fedora Linux (niri), managed with Make
and GNU Stow. XDG Base Directory compliant throughout.

---

## What's Inside

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for
  plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) on macOS
  (`packages/Brewfile`); dnf plus [Terra](https://terra.fyralabs.com) on
  Fedora (`packages/fedora.txt`).
- **Terminal:** [Ghostty](https://ghostty.org/) (per-OS config), plus
  [foot](https://codeberg.org/dnkl/foot) on Linux. Catppuccin Mocha.
- **Desktop (Linux):** [niri](https://github.com/YaLTeR/niri), Waybar,
  swaync, swayosd, fuzzel, swaylock/swayidle, swaybg, SDDM.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs, commit
  signing with a per-machine SSH key.
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `btop`, `fastfetch`; `yazi` on Linux; `k9s` on the work Mac.

---

## Installation

### Prerequisites

- **macOS:** Git and Command Line Tools (`xcode-select --install`)
- **Fedora:** a minimal install (Fedora Everything netinstall, "Minimal
  Install"), with network access. Install `git` and `make` first
  (`sudo dnf install git make`). Disk encryption is set up by the installer;
  TPM unlock is manual, see [Fedora boot notes](#fedora-boot-notes).

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
| `make dump`    | Brewfile export (macOS); unlisted packages (Fedora)|
| `make lint`    | Validate zsh, JSON, niri config and scripts        |
| `make clean`   | Remove all stow symlinks                           |
| `make brew`    | Install the Brewfile (macOS)                       |
| `make brew-sync` | Brewfile, then **remove** anything not in it (macOS) |

---

## Repository Structure

```txt
.dotfiles/
├── packages/
│   ├── Brewfile      # macOS: brew, casks, mas
│   └── fedora.txt    # Fedora: dnf (official repos + Terra)
├── config/           # Shared app configs → ~/.config/ (both OSes)
│   ├── bat/  btop/  fastfetch/  git/  k9s/  mise/
│   ├── nvim/  tmux/  zsh/
├── config-macos/     # macOS-only → ~/.config/
│   ├── ghostty/  swiftbar/
├── config-linux/     # Linux-only → ~/.config/
│   ├── niri/  waybar/  swaync/  swayosd/  swaylock/  swayidle/
│   ├── fuzzel/  foot/  yazi/  ghostty/
├── system-linux/     # /etc files + tailscaled polkit rule, installed by setup
├── home/             # Home-level dotfiles → ~/
│   └── .zshenv
├── scripts/
│   ├── setup           # Guided install / --check doctor (macOS + Fedora)
│   ├── install         # Symlink config/ + config-<os>/ via stow
│   ├── clean           # Remove stow symlinks
│   ├── tpm-enroll      # (Re-)enroll the TPM for LUKS unlock (Linux, manual)
│   └── macos-defaults  # Apply macOS system defaults
└── Makefile
```

Shared configs are one version for both systems: where they differ, they
check what's installed (`pbcopy` vs `wl-copy`, Homebrew vs a git clone of
antidote) instead of keeping per-OS copies. `up` is the one function that
branches on the OS (brew vs dnf).

---

## Notes

- **Clipboard.** The `clip` zsh function uses `pbcopy` (macOS) or `wl-copy`
  (Wayland), or OSC 52 over SSH so copies land on the local terminal.
- **Git key.** One `~/.ssh/id_ed25519` per machine for auth and signing,
  without a passphrase so remote sessions (T3 Code, SSH from a phone) can
  use it; disk encryption and the user login are what protect it. Per-machine
  git settings (signing key, gh credential helper) live in
  `~/.gitconfig.local`, written by setup.
- **Keyboard remapping.** Caps Lock → Escape via xkb `options` in niri
  on Linux; none on macOS.
- **macOS defaults.** Run `scripts/macos-defaults` after first install to
  apply sensible system preferences.
- **Wallpapers (Linux)** aren't in the repo. swaybg and swaylock both use
  `~/Pictures/Wallpapers/current`, a symlink to the chosen image.
- **Not packaged (Fedora).** Bitwarden desktop is the official AppImage in
  `~/.local/opt` (updates itself), installed by setup. `ls` colors are
  vivid's Catppuccin output, committed as `config/zsh/ls_colors`.

---

## Fedora boot notes

Disk and boot are machine-specific and a mistake can leave the machine
unbootable, so `make install` doesn't touch them. The Framework 13 layout,
as the Fedora installer made it:

- **Disk:** ESP on `nvme0n1p1` (`/boot/efi`), ext4 `/boot` on `nvme0n1p2`,
  LUKS2 on `nvme0n1p3` with one btrfs inside (Fedora's default `root` and
  `home` subvolumes). GRUB + shim boot it; kernels are managed by dnf.
- **Boot menu:** hidden (`sudo grub2-editenv - set menu_auto_hide=1`); it
  shows after a failed boot, or with Esc during startup.
- **Secure Boot on** (BIOS, Microsoft 3rd-party UEFI CA allowed: shim is
  signed with it) before enrolling the TPM. Without it, PCR 7 doesn't stop
  someone booting their own OS and unsealing the key.
- **TPM unlock** (passphrase stays as fallback). Once per install: append
  `,tpm2-device=auto` to the root volume's options in `/etc/crypttab`, add
  `add_dracutmodules+=" tpm2-tss "` to `/etc/dracut.conf.d/tpm2.conf`, and
  rebuild the initramfs (`sudo dracut -f`). Then enroll:

  ```sh
  sudo ~/.dotfiles/scripts/tpm-enroll
  ```

  It finds the LUKS device behind `/`, refuses while Secure Boot is off,
  replaces any old TPM slot and verifies the TPM unlock before you reboot.
  **After a BIOS update** or a Secure Boot change (both change PCR 7), the
  next boot asks for the passphrase: log in and run it again.
