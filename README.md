# Dotfiles

Personal cross-platform configuration for **macOS** and **Fedora Linux**,
managed with Make and structured for XDG compliance.

---

## What's Inside?

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote)
  for plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) (`Brewfile`) on macOS;
  `dnf` + COPR + Flatpak (`Packages.fedora`) on Fedora.
- **Terminal:** [Ghostty](https://ghostty.org/) with Catppuccin Mocha theme.
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs,
  commit signing via Bitwarden SSH agent (macOS).
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `lazygit`, `btop`, `yazi`, `k9s`.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).

---

## Installation

### Prerequisites

- Git
- macOS: Command Line Tools (`xcode-select --install`)
- Fedora: `sudo` access (for `dnf`)

### Steps

```bash
git clone https://github.com/victortennekes/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

`make install` auto-detects the OS via `uname -s`:

- **Darwin** — installs Homebrew, runs `brew bundle` against `Brewfile`,
  stows `config/` and `home/`.
- **Linux** — runs `scripts/install-fedora` against `Packages.fedora`
  (dnf + COPR + flatpak + cargo + npm + curl installers), then stows
  `config/` while skipping `karabiner` (macOS-only).

Work-only packages (dbt, terraform, k9s, slack, …) are gated by hostname
prefix `PC-` on both platforms. Override on Linux with
`IS_WORK=true make install`.

---

## Usage

| Command         | Description                                           |
|-----------------|-------------------------------------------------------|
| `make install`  | Full setup: packages + symlinks (per OS)              |
| `make update`   | Pull dotfiles, update packages, re-link configs       |
| `make dump`     | macOS: export current brew packages to Brewfile       |
| `make lint`     | Validate zsh, json, and install scripts               |
| `make clean`    | Remove all stow symlinks                              |

---

## Repository Structure

```txt
.dotfiles/
├── Brewfile          # macOS packages (brew, casks, mas)
├── Packages.fedora   # Linux packages (dnf, copr, flatpak, cargo, npm, curl)
├── Makefile          # OS-aware setup orchestrator
├── config/           # App configs, symlinked to ~/.config/
│   ├── bat/
│   ├── btop/
│   ├── ghostty/
│   ├── git/
│   ├── k9s/
│   ├── karabiner/    # macOS only — skipped by stow on Linux
│   ├── mise/
│   ├── nvim/
│   ├── opencode/
│   ├── yazi/
│   └── zsh/
├── home/             # Home-level dotfiles, symlinked to ~/
│   └── .zshenv
└── scripts/
    ├── install        # Symlink dotfiles via stow (cross-platform)
    ├── install-fedora # Install dnf/copr/flatpak/cargo/npm/curl packages
    └── clean          # Symlink removal
```

---

## Cross-platform notes

- **Clipboard.** The `clip` zsh function transparently dispatches to
  `pbcopy` on macOS, `wl-copy` on Wayland, or `xclip` on X11.
- **SSH agent.** macOS uses Bitwarden's containerized socket; on Linux
  fall back to `ssh-agent` or run Bitwarden CLI separately.
- **Karabiner.** macOS-only; on Linux use [`kanata`](https://github.com/jtroo/kanata)
  for keyboard remapping (not currently configured here).
- **Nerd Fonts.** Brew cask installs them on macOS; on Fedora install via
  [`getnf`](https://github.com/getnf/getnf) or download manually into
  `~/.local/share/fonts`.
- **Ghostty options.** `config/ghostty/config` keeps a few `macos-*` keys.
  They're cosmetic on macOS and Ghostty no-ops them on Linux (may print a
  startup warning); split into a darwin-only include if it becomes noisy.

### First Fedora run

Linux package names drift between releases. The `Packages.fedora` manifest
is a starting point — expect to tweak some entries on first install:

- `glab` lives in core repos on Fedora 39+, COPR earlier.
- `tree-sitter-devel` may need to become `tree-sitter` depending on Fedora version.
- `com.mitchellh.ghostty` may not be on Flathub yet; build from source if needed.
- COPR repos (`atim/lazygit`, `lihaohong/yazi`) require `dnf-plugins-core`.
- Some flatpak app IDs change over time — `flatpak search <name>` to verify.
