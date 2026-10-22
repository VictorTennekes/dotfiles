# Dotfiles

Personal configuration for **macOS** and **CachyOS** (Framework 13),
managed with Make and GNU Stow. XDG Base Directory compliant throughout.

---

## What's Inside

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for
  plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) (`packages/Brewfile`) on
  macOS; pacman/AUR via `paru` on Linux (no manifest, installed by hand).
- **Terminal:** [Ghostty](https://ghostty.org/) with Catppuccin Mocha theme.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs, commit
  signing via Bitwarden SSH agent (macOS).
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `btop`, `yazi`, `k9s`, `fastfetch`.
- **Linux Desktop:** KDE Plasma on Wayland (CachyOS), themed with a
  Mac OS 9 Platinum look
  ([nielsvm/kde-look-and-feel-platinum](https://github.com/nielsvm/kde-look-and-feel-platinum)).

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

`make install` auto-detects the OS via `uname -s`:

| Platform | Package manager      | Package manifest    |
|----------|----------------------|---------------------|
| macOS    | Homebrew             | `packages/Brewfile` |
| CachyOS  | `paru` (pacman+AUR)  | none (by hand)      |

Work-only packages (dbt, terraform, k9s, Slack, …) are gated by a marker
file, `~/.work-laptop`. Create it once on the work machine: `touch ~/.work-laptop`.

---

## Usage

| Command        | Description                                       |
|----------------|---------------------------------------------------|
| `make install` | Full setup: packages + symlinks (per OS)          |
| `make update`  | Pull dotfiles, update packages, re-link configs   |
| `make dump`    | macOS: export current brew packages to Brewfile   |
| `make lint`    | Validate zsh, JSON, and install scripts           |
| `make clean`   | Remove all stow symlinks                          |

---

## Repository Structure

```txt
.dotfiles/
├── packages/
│   └── Brewfile      # macOS (brew, casks, mas)
├── config/           # Cross-platform app configs → ~/.config/
│   ├── bat/
│   ├── btop/
│   ├── fastfetch/
│   ├── ghostty/
│   ├── git/
│   ├── k9s/
│   ├── mise/
│   ├── nvim/
│   ├── yazi/
│   └── zsh/
├── darwin/           # macOS-only configs → ~/.config/
│   └── karabiner/
├── home/             # Home-level dotfiles → ~/
│   └── .zshenv
├── scripts/
│   ├── install       # Symlink dotfiles via stow
│   ├── clean         # Remove stow symlinks
│   └── macos-defaults # Apply macOS system defaults
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
- **Nerd Fonts.** Brew cask installs them on macOS; on CachyOS install via
  the `ttf-nerd-fonts-symbols` (or per-font) AUR/pacman package.
- **macOS defaults.** Run `scripts/macos-defaults` after first install to
  apply sensible system preferences.
