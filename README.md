# Dotfiles

Personal configuration for **macOS** and **Linux** (Arch, Fedora, Void),
managed with Make and GNU Stow. XDG Base Directory compliant throughout.

---

## What's Inside

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for
  plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) (`packages/Brewfile`) on
  macOS; pacman/paru, dnf, or xbps on Linux.
- **Terminal:** [Ghostty](https://ghostty.org/) with Catppuccin Mocha theme.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs, commit
  signing via Bitwarden SSH agent (macOS).
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `lazygit`, `btop`, `yazi`, `k9s`, `fastfetch`.
- **Linux Desktop:** [Niri](https://github.com/YaLTeR/niri) (tiling Wayland
  compositor) with Noctalia theme.

---

## Installation

### Prerequisites

- Git
- macOS: Command Line Tools (`xcode-select --install`)
- Linux: `sudo` access

### Steps

```bash
git clone https://github.com/victortennekes/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

`make install` auto-detects the OS via `uname -s`, then routes by distro on Linux:

| Platform | Package manager | Package manifest |
|----------|----------------|-----------------|
| macOS    | Homebrew       | `packages/Brewfile` |
| Arch     | pacman + paru  | `packages/arch` |
| Fedora   | dnf + flatpak  | `packages/fedora` |
| Void     | xbps           | `packages/void` |

Work-only packages (dbt, terraform, k9s, Slack, …) are gated by hostname
prefix `PC-` on all platforms. Override with `IS_WORK=true make install`.

---

## Usage

| Command        | Description                                       |
|----------------|---------------------------------------------------|
| `make install` | Full setup: packages + symlinks (per OS/distro)   |
| `make update`  | Pull dotfiles, update packages, re-link configs   |
| `make dump`    | macOS: export current brew packages to Brewfile   |
| `make lint`    | Validate zsh, JSON, and install scripts           |
| `make clean`   | Remove all stow symlinks                          |

---

## Repository Structure

```txt
.dotfiles/
├── packages/
│   ├── Brewfile      # macOS (brew, casks, mas)
│   ├── arch          # Arch Linux (pacman + paru + npm + curl)
│   ├── fedora        # Fedora (dnf + copr + flatpak + cargo + npm + curl)
│   └── void          # Void Linux (xbps + runit)
├── config/           # Cross-platform app configs → ~/.config/
│   ├── bat/
│   ├── btop/
│   ├── fastfetch/
│   ├── ghostty/
│   ├── git/
│   ├── k9s/
│   ├── lazygit/
│   ├── mise/
│   ├── nvim/
│   ├── yazi/
│   └── zsh/
├── darwin/           # macOS-only configs → ~/.config/
│   └── karabiner/
├── linux/            # Linux-only configs → ~/.config/
│   ├── niri/
│   └── noctalia/
├── home/             # Home-level dotfiles → ~/
│   └── .zshenv
├── system/           # System-level config (gamemode, libinput, tlp)
│   └── etc/
├── scripts/
│   ├── install       # Symlink dotfiles via stow
│   ├── install-arch  # Arch package installer
│   ├── install-fedora # Fedora package installer
│   ├── install-void  # Void package installer
│   ├── clean         # Remove stow symlinks
│   ├── macos-defaults # Apply macOS system defaults
│   └── lib/
│       └── common.sh # Shared shell helpers
└── Makefile
```

---

## Cross-platform Notes

- **Clipboard.** The `clip` zsh function dispatches to `pbcopy` on macOS,
  `wl-copy` on Wayland, or `xclip` on X11.
- **SSH agent.** macOS uses Bitwarden's containerized socket; on Linux fall
  back to `ssh-agent` or run Bitwarden CLI separately.
- **Keyboard remapping.** macOS uses Karabiner (`darwin/`); Linux equivalent
  ([`kanata`](https://github.com/jtroo/kanata)) is not currently configured.
- **Nerd Fonts.** Brew cask installs them on macOS; on Arch/Fedora install via
  [`getnf`](https://github.com/getnf/getnf) or drop fonts into
  `~/.local/share/fonts`.
- **macOS defaults.** Run `scripts/macos-defaults` after first install to
  apply sensible system preferences.
